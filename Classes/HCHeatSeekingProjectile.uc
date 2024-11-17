/*
 * Copyright (c) 2021-2024 Tuomo Kriikkula <tuokri@tuta.io>
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

// Good audio reference: https://www.youtube.com/watch?v=4j45oh32JeI
// https://www.youtube.com/watch?v=FEBwYtW_VTA
// https://www.youtube.com/watch?v=WBqDCO4bV4g
// https://www.youtube.com/watch?v=1iSKNXpBaKY

// Custom projectile class that attempts to guide itself to a locked target.
// https://en.wikipedia.org/wiki/Proportional_navigation
// https://www.ijser.org/researchpaper/Performance-Evaluation-of-Proportional-Navigation-Guidance-for-Low-Maneuvering-Targets.pdf
// https://eprints.ugd.edu.mk/7501/2/MK-CN-TR-002_GELEV%20-%20XU%20et%20al_FuzzyLogic%20in%20Firecontrol%20for%20AirDefence-koregirano27%255B1%255D.03.2007.pdf
// https://youtu.be/yUlC6GZEUVs?t=143
// Uses proportional navigation (PN).
// Assumes the seeker head is able to rotate.
// TODO: minimum arming distance!
class HCHeatSeekingProjectile extends PG7VRocket;

const AIR_DENSITY = 0.001293;
const UU_TO_MS = 50;
const UU_TO_M = 50;
// Mirrored from ROVehicleHelicopter. 9.81 m/s^2 -> Unreal units.
const ACCEL_G = 490.5;

// TODO: MAYBE CHANGE ALL UNITS TO RADS OR UNRROTS?

// Cached squared explosion damage radius.
var() float DamageRadiusSq;
// The actor this projectile is currently tracking.
var() Actor LockedTarget;
// Flag set to True on explosion to stop tracking calculations.
var() bool bExploded;
// Flag to control when missile can begin performing tracking calculations.
var() bool bCanUpdateTracking;
// Scale the force by which the missile is able to correct
// its trajectory. I.e. the closer the missile is to max speed,
// the faster it is able to turn.
// TODO: maybe combine this with maximum turn G force?
var() float TrackingForceScaler;
// How many degrees per second the projectile can track.
// Essentially how fast the seeker head can turn on its gimbal.
var() float TrackingMaxDegPerSecond;
// Seeker head field of view in degrees. Note that the seeker
// head can turn on its gimbal, the maximum angle of which
// is controlled by SeekerMaxBearingAngleDeg.
var() float SeekerDegFOV;
// Maximum seeker head bearing angle. How much the seeker head can rotate
// relative to the missile's longitudinal axis (forward axis).
var() float SeekerMaxBearingAngleDeg;
// The N constant in the proportional navigation formula.
// Usually between 3-5.
// TODO: should be an integer?
var() int EffectiveNavigationRatio;
// According to this: https://www.quora.com/What-are-the-acceleration-capabilities-of-surface-to-air-missiles
// Early MANPADS maximum would be 4-6 G.
var() float MaximumTurnG;
// Calculated MaximumTurnG force in engine units.
var() float MaximumTurnGGame;
// Cached maximum speed squared.
var() float MaxSpeedSq;
// Maneuvering induces a drag force on the missile. The area from which the drag
// force is calculated is simulated by multiplying PNAccel magnitude by DampingForceScaler.
// TODO: maybe give this a better name?
var() float DampingForceScaler;
// TODO: comment.
var() float FinArea;

// Simulate onboard computer errors, acceleration error multiplier range minimum.
var() float RandomErrorMin;
// Simulate onboard computer errors, acceleration error multiplier range maximum.
var() float RandomErrorMax;

// TODO: maneuvering induces drag on the missile. The missile must burn more
// fuel to sustain velocity after maneuvering. Simulate this by having a fuel
// budget that the missile can use to accelerate back to maximum speed. After
// all fuel is depleted, maneuvering will gradually slow down the missile.
var() float Fuel;

var() float MaxForwardAccelPerSecond;

// Current speed relative to MaxSpeed [0.0, 1.0] to allowed
// maximum PN acceleration. Limits missile steering capabilities
// at lower speeds to make it feel more realistic.
var() InterpCurveFloat SpeedPctToTrackingForceScaler;

var ParticleSystemComponent SmokeTrailComponent;
var ParticleSystem SmokeTrailTemplate;

// TODO: think about this.
var vector SeekerHeadCurrentHeading;
var vector SeekerHeadDesiredHeading;
var vector RelativeVelocity;
var vector MissileToTarget;
var vector RotationVector;
var vector PreviousRotationVector;
var float PreviousLOSAngle;

var float CurrentSpeedSquared;
var float CurrentSpeed;
// var float AccelTimeLeft;

var float ForwardAccelStartTime;
var bool bDebugLoggedAccel;
var vector DebugLocLastTick;

// var() StaticMeshComponent ProjMesh;

// TODO: need to be able to configure seeker offset relative to mesh center?
//       - or just assume seeker head is at the center of the missile to simplify things?

event PreBeginPlay()
{
    // local StaticMeshComponent MeshComp;

    super.PreBeginPlay();

    // We estimate how much we can accelerate forward per second when no drag
    // force or other external forces are applied on the missile, based on how
    // long it would take to accelerate from initial launch speed to maximum speed.
    MaxForwardAccelPerSecond = (MaxSpeed - Speed) / InitialAccelerationTime;
    `hcdebug("MaxForwardAccelPerSecond=" $ MaxForwardAccelPerSecond);

    MaximumTurnGGame = MaximumTurnG * ACCEL_G;
    DamageRadiusSq = DamageRadius * DamageRadius;

    MaxSpeedSq = (MaxSpeed * MaxSpeed);

    // TODO: for some reason our calcs make it so the missile accelerates a bit
    //       faster than it is supposed to. Increase the time here just a little bit.
    // AccelTimeLeft = InitialAccelerationTime * 1.2;

    // Ignore gravity in the beginning to prevent the missile from drooping.
    // TODO: there is most likely a better solution to this!
    //       Set physics to PHYS_None?
    // ForEach AllOwnedComponents(class'StaticMeshComponent', MeshComp)
    // {
    //     `hcdebug("MeshComp=" $ MeshComp @ "Name=" $ MeshComp.Name);

    //     // TODO: for now, assuming the missile only has a single mesh comp.
    //     // TODO: maybe refactor this? Add a named variable that is the component.
    //     // TODO: need to rip out some stuff from the inheritance chain for this!

    //     // if (MeshComp.Name == 'ProjectileMesh')
    //     // {
    //         `hcdebug("Found MeshComp=" $ MeshComp);
    //         ProjMesh.GetRootBodyInstance().CustomGravityFactor = 0.0;
    //         ProjMesh = MeshComp;
    //         break;
    //     // }
    // }
}

simulated function ProcessBulletTouch(Actor Other, Vector HitLocation, Vector HitNormal, PrimitiveComponent OtherComp)
{
    `hcdebug("Other=" $ Other @ "HitLocation=" $ HitLocation
        @ "HitNormal=" $ HitNormal @ "OtherComp=" $ OtherComp);

    if (HCHelicopterBaseProtection(Other) != None
        && HCPlayerController(InstigatorController) != None)
    {
        Destroy();
        HCPlayerController(InstigatorController).ReceiveLocalizedMessage(
            class'HCLocalMessageHelicopterBase', HCMSGHELOBASE_ProjectileDestroyed);
    }
    else
    {
        super.ProcessBulletTouch(Other, HitLocation, HitNormal, OtherComp);
    }
}

function StartRocketEngine()
{
    `hcdebug("rocket engine started");

    // ProjMesh.GetRootBodyInstance().CustomGravityFactor = 1.0;

    bCanUpdateTracking = True;
    TrackingForceScaler = 0.001;

    // TODO: is there a better place to do this?
    // Need to initialize these before starting tracking calcs else we will pull massive Gs on first tick.
    RelativeVelocity = LockedTarget.Velocity - Velocity;
    MissileToTarget = LockedTarget.Location - Location;
    SeekerHeadCurrentHeading = MissileToTarget;
    RotationVector = (MissileToTarget cross RelativeVelocity) / VSizeSq(RelativeVelocity);

    ForwardAccelStartTime = WorldInfo.TimeSeconds;

    SpawnFlightEffects();
    SetTimer(FueledFlightTime, false, NameOf(CutRocketEngine));
}

function CutRocketEngine()
{
    if (WorldInfo.NetMode != NM_DedicatedServer && ProjEffects != None)
    {
        ProjEffects.SetActive(false);
    }

    if (WorldInfo.NetMode != NM_DedicatedServer && SmokeTrailComponent != None)
    {
        SmokeTrailComponent.SetActive(false);
    }

    // TODO: NetMode check here?
    if (AmbientComponent != None)
    {
        AmbientComponent.StopEvents();
    }

    bTrueBallistics = true;
}

simulated function MyOnParticleSystemFinished(ParticleSystemComponent PSC)
{
    if (PSC == ProjEffects)
    {
        if (bWaitForEffects)
        {
            if (bShuttingDown)
            {
                // it is not safe to destroy the actor here because other threads are doing stuff, so do it next tick.
                LifeSpan = 0.01;
            }
            else
            {
                bWaitForEffects = false;
            }
        }
        // clear component and return to pool
        DetachComponent(ProjEffects);
        WorldInfo.MyEmitterPool.OnParticleSystemFinished(ProjEffects);
        ProjEffects = None;
    }
    else if (PSC == SmokeTrailComponent)
    {
        if (bWaitForEffects)
        {
            if (bShuttingDown)
            {
                // it is not safe to destroy the actor here because other threads are doing stuff, so do it next tick.
                LifeSpan = 0.01;
            }
            else
            {
                bWaitForEffects = false;
            }
        }
        // clear component and return to pool
        DetachComponent(SmokeTrailComponent);
        WorldInfo.MyEmitterPool.OnParticleSystemFinished(SmokeTrailComponent);
        SmokeTrailComponent = None;
    }
}

simulated function SpawnFlightEffects()
{
    // Start effects when the sustainer engine is started.
    // TODO: add separate effects for the initial booster!
    if (!bCanUpdateTracking)
    {
        return;
    }

    if (WorldInfo.NetMode != NM_DedicatedServer && ProjFlightTemplate != None)
    {
        ProjEffects = WorldInfo.MyEmitterPool.SpawnEmitterCustomLifetime(ProjFlightTemplate);
        ProjEffects.SetAbsolute(false, false, false);
        ProjEffects.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
        ProjEffects.OnSystemFinished = MyOnParticleSystemFinished;
        ProjEffects.bUpdateComponentInTick = true;
        ProjEffects.SetTranslation(ProjFlightFXOffset);
        if (bFlipFlightEffect)
        {
            ProjEffects.SetRotation(rot(0,32768,0));
        }
        AttachComponent(ProjEffects);
    }

    if (WorldInfo.NetMode != NM_DedicatedServer && SmokeTrailTemplate != None)
    {
        SmokeTrailComponent = WorldInfo.MyEmitterPool.SpawnEmitterCustomLifetime(SmokeTrailTemplate);
        SmokeTrailComponent.SetAbsolute(false, false, false);
        SmokeTrailComponent.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
        SmokeTrailComponent.OnSystemFinished = MyOnParticleSystemFinished;
        SmokeTrailComponent.bUpdateComponentInTick = true;
        SmokeTrailComponent.SetTranslation(ProjFlightFXOffset);
        // if (bFlipFlightEffect)
        // {
        //     SmokeTrailComponent.SetRotation(rot(0,32768,0));
        // }
        AttachComponent(SmokeTrailComponent);
    }
}

simulated function UpdateTrackingParams(float DeltaTime, out float OutDistanceSq, out float OutAngle, out vector OutSelfToTarget)
{
    local float RotationVectorSizeDelta;
    local float RotationVectorSize;
    local vector X;
    local vector Y;
    local vector Z;
    local vector PNAccel;
    local vector DragForce;
    local vector ForwardAccel;
    // local float LOSRate;
    // local float LOSAngleDelta;
    // local float LOSAngle;
    local float SeekerHeadAngle;
    local float RandomError;
    local float PNAccelSize;

    GetAxes(Rotation, X, Y, Z);

    RelativeVelocity = LockedTarget.Velocity - Velocity;
    `hcdebug("RelativeVelocity=" $ RelativeVelocity / UU_TO_MS @ "m/s");

    MissileToTarget = LockedTarget.Location - Location;

    // A rotation vector is a compact representation of a 3D rotation.
    // It is a 3-element vector whose direction represents the axis of
    // rotation and whose magnitude represents the angle of rotation
    // in radians. This representation is also known as the axis-angle representation.
    RotationVector = (MissileToTarget cross RelativeVelocity) / VSizeSq(RelativeVelocity);

    RotationVectorSize = VSize(RotationVector);
    RotationVectorSizeDelta = VSize(PreviousRotationVector) - RotationVectorSize;

    `hcdebug("RotationVectorSize=" $ RotationVectorSize @ "rad?"
        @ RotationVectorSize * DegToRad @ "deg?"
        @ "RotationVectorSizeDelta=" $ RotationVectorSizeDelta
        @ (RotationVectorSizeDelta * DegToRad) / DeltaTime @ "deg/s"
    );

    PreviousRotationVector = RotationVector;

    // TODO: can we clamp RotationVector length to respect limits?
    // TODO: how do we tie DeltaTime into this?

    DrawDebugLine(Location, Location + Normal(RotationVector)  * 9000,          255, 165, 000); // Orange.
    DrawDebugLine(Location, Location + Normal(MissileToTarget) * 9000,          255, 015, 015);
    DrawDebugLine(Location, LockedTarget.Location,                              255, 015, 015);
    DrawDebugLine(Location, Location + Normal(SeekerHeadCurrentHeading) * 9000, 015, 255, 015);
    DrawDebugLine(Location, Location + Normal(Velocity) * 9000,                 255, 000, 255); // Magenta.

    // LOSAngleDelta = ACos(Normal(MissileToTarget) dot Normal(SeekerHeadCurrentHeading));
    SeekerHeadAngle = ACos(X dot Normal(SeekerHeadCurrentHeading));
    // LOSRate = LOSAngleDelta / DeltaTime;
    // `hcdebug("LOSAngleDelta=" $ LOSAngleDelta @ "rad" @ LOSAngleDelta * RadToDeg @ "deg");
    `hcdebug("SeekerHeadAngle=" $ SeekerHeadAngle @ "rad" @ SeekerHeadAngle * RadToDeg @ "deg");
    // `hcdebug("LOSRate=" $ LOSRate @ "rad/s" @ LOSRate * RadToDeg @ "deg/s");
    SeekerHeadCurrentHeading = MissileToTarget;

    RandomError = RandRange(RandomErrorMin, RandomErrorMax);
    `hcdebug("RandomError=" $ RandomError);

    // TODO:
    // 1. Check that target is within seeker head's FoV.
    // 2. Based on target location and seeker location, check how much we have to rotate
    //    to keep direct LoS to target.
    // 3. Limit seeker head rotator angle to SeekerMaxBearingAngleDeg, limit the amount
    //    seeker head rotates by TrackingMaxDegPerSecond.
    // 4. Verify that current target is within allowed seeker head params!
    // 5. Calculate and apply PN acceleration.

    // Wikipedia, energy conserving control.
    // NOTE: is this pure PN?
    PNAccel = (-EffectiveNavigationRatio * VSize(RelativeVelocity)
        * ((Velocity / CurrentSpeed) cross RotationVector)) * RandomError;

    DrawDebugLine(Location, Location + Normal(PNAccel) * 9000, 015, 015, 255);

    // TODO: remove multiple calculations of PNAccelSize once less debugging is needed!

    PNAccelSize = VSize(PNAccel);
    `hcdebug("(RAW)    PNAccel=" $ PNAccel @ "[" $ PNAccelSize / ACCEL_G $ "] G");
    PNAccel = ClampLength(PNAccel, MaximumTurnGGame * TrackingForceScaler);
    PNAccelSize = VSize(PNAccel);
    `hcdebug("(CLAMP)  PNAccel=" $ PNAccel @ "[" $ PNAccelSize / ACCEL_G $ "] G");

    `hcdebug("DistanceToTarget=" $ VSize(MissileToTarget) / UU_TO_M @ "meters");

    // TODO: how the fuck do we apply this correctly?
    // TODO: DeltaTime should be part of this equation somewhere!
    Acceleration += PNAccel;

    // TODO: factor Fuel into this equation!
    // Accelerate forward using rocket engine.
    if (CurrentSpeed < MaxSpeed)
    {
        ForwardAccel = (X * MaxForwardAccelPerSecond) * DeltaTime;
        `hcdebug("ForwardAccel=" $ ForwardAccel @ "VSize(ForwardAccel)=" $ VSize(ForwardAccel));
        Acceleration += ForwardAccel;

        DrawDebugLine(Location, Location + Normal(ForwardAccel) * 9000, 000, 000, 000);
    }

    // TODO: REWRITE COMMENTS WHEN THIS FUCKER IS GOOD!

    // Apply small damping force to simulate drag induced by using control surfaces!
    // Simulates control fin / missile surface area:
    //  - If the missile is turning hard the PN accel is high therefore, the fins are
    //    inducing more drag and the missile's own surface area is also contributing
    //    more to the drag, since it is flying "sideways" while turning. DampingForceScaler
    //    is a scaler chosen by practical experiments. Higher scaler value simulates higher
    //    fin and missile surface area that contributes to drag.

    // Drag equation with simplifications and approximations.
    DragForce = (-Normal(Velocity) * AIR_DENSITY * BallisticCoefficient
        * CurrentSpeedSquared * 0.5
        * (ACos(X dot Normal(Velocity)) * FinArea * DampingForceScaler) // TODO: PLUG IN AREA HERE!
        * DeltaTime);
    Acceleration += DragForce;
    `hcdebug("VSize(DragForce)=" $ VSize(DragForce) @ "PNAccelSize=" $ PNAccelSize);
    DrawDebugLine(Location, Location + Normal(DragForce) * 9000, 255, 255, 255);
}

simulated function Shutdown()
{
    local vector HitLocation;
    local vector HitNormal;

    bExploded = True;
    bCanUpdateTracking = False;

    bShuttingDown = True;
    HitNormal = normal(Velocity * -1);
    Trace(HitLocation,HitNormal,(Location + (HitNormal*-32)), Location + (HitNormal*32),true,vect(0,0,0));

    SetPhysics(PHYS_None);

    if (ProjEffects != None)
    {
        ProjEffects.DeactivateSystem();
    }

    // Leave SmokeTrailComponent active here!

    if (!bSuppressExplosionFX)
    {
        SpawnExplosionEffects(Location, HitNormal);
    }

    if (bStopAmbientSoundOnExplode
        && AmbientSound != none
        && AmbientComponent != none
        && AmbientComponent.IsPlaying())
    {
        StopAmbientSound();
    }

    HideProjectile();
    SetCollision(false,false);

    // If we have to wait for effects, tweak the death conditions

    `hcdebug("bWaitForEffects=" $ bWaitForEffects @ "bNetTemporary=" $ bNetTemporary);
    if (bWaitForEffects)
    {
        if (bNetTemporary)
        {
            if (WorldInfo.NetMode == NM_DedicatedServer)
            {
                // We are on a dedicated server and not replicating anything nor do we have effects so destroy right away
                Destroy();
            }
            else
            {
                // We can't die right away but make sure we don't replicate to anyone
                RemoteRole = ROLE_None;
                // make sure we leave enough lifetime for the effect to play
                LifeSpan = FMax(LifeSpan, 15.0);
            }
        }
        else
        {
            bTearOff = true;
            if (WorldInfo.NetMode == NM_DedicatedServer)
            {
                LifeSpan = 0.15;
            }
            else
            {
                // make sure we leave enough lifetime for the effect to play
                LifeSpan = FMax(LifeSpan, 15.0);
            }
        }
    }
    else if (bWaitForInitialReplication && Role == ROLE_Authority)
    {
        Lifespan = 0.15; // Necessary when spawn/shutdown in same tick.
    }
    else
    {
        Destroy();
    }

    `hcdebug("SmokeTrailComponent=" $ SmokeTrailComponent);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    `hcdebug("HitLocation=" $ HitLocation @ "HitNormal=" $ HitNormal);

    bExploded = True;
    bCanUpdateTracking = False;
    super.Explode(HitLocation, HitNormal);
}

simulated function Destroyed()
{
    `hcdebug("SmokeTrailComponent=" $ SmokeTrailComponent);

    if (SmokeTrailComponent != None)
    {
        SmokeTrailComponent.DeactivateSystem();
        WorldInfo.MyEmitterPool.OnParticleSystemFinished(SmokeTrailComponent);
        SmokeTrailComponent = None;
    }

    super.Destroyed();
}

simulated function Tick(float DeltaTime)
{
    local float DistanceSq;
    local float Angle;
    local PlayerController PC;
    local vector SelfToTarget;

    local float DistanceTraveledSinceLastTick;

    super.Tick(DeltaTime);

    CurrentSpeedSquared = VSizeSq(Velocity);
    CurrentSpeed = VSize(Velocity);

    if (!IsZero(DebugLocLastTick))
    {
        DistanceTraveledSinceLastTick = VSize(Location - DebugLocLastTick);
        `hcdebug("DistanceTraveledSinceLastTick=" $ DistanceTraveledSinceLastTick
            @ "UU" @ DistanceTraveledSinceLastTick / UU_TO_M @ "m"
            @ "Speed=" $ (DistanceTraveledSinceLastTick / UU_TO_M) / DeltaTime @ "m/s"
        );
    }
    DebugLocLastTick = Location;

    // TODO: DEBUG ONLY!
    if (CurrentSpeed >= MaxSpeed && !bDebugLoggedAccel)
    {
        bDebugLoggedAccel = True;
        `hcdebug("### ### ACCEL TIME:"
            @ WorldInfo.TimeSeconds - ForwardAccelStartTime);
        ForEach LocalPlayerControllers(class'PlayerController', PC)
        {
            PC.ClientMessage("### ### ACCEL TIME:"
                @ WorldInfo.TimeSeconds - ForwardAccelStartTime);
        }
    }

    if (bExploded)
    {
        return;
    }

    `hclog("Acceleration=" $ Acceleration $ ", AccelG=" $ ACCEL_G / VSize(Acceleration)
        @ "Speed=" $ CurrentSpeed / UU_TO_MS @ "m/s"
    );

    ForEach LocalPlayerControllers(class'PlayerController', PC)
    {
        PC.ClientMessage("Speed=" $ CurrentSpeed / UU_TO_MS @ "m/s");
    }

    if (!bCanUpdateTracking)
    {
        return;
    }

    // TrackingForceScaler = FClamp((CurrentSpeed / MaxSpeed), 0.01, 1.0);
    // TrackingForceScaler = FClamp((VSizeSq(Velocity) / MaxSpeedSqForTrackingScaler), 0.001, 1.0);
    TrackingForceScaler = EvalInterpCurveFloat(SpeedPctToTrackingForceScaler, CurrentSpeedSquared / MaxSpeedSq);
    UpdateTrackingParams(DeltaTime, DistanceSq, Angle, SelfToTarget);

    if (bTrueBallistics || LockedTarget == None || Angle == 0)
    {
        return;
    }

    // TODO: cleanup!
    return;

    // if (Angle <= MaxAngleDelta)
    // {
    //     // TODO: this is stupid!
    //     // Velocity = Speed * Normal(SelfToTarget);
    //     Velocity = VSize(Velocity) * Normal(SelfToTarget);
    // }
    // else
    // {
    //     ForEach LocalPlayerControllers(class'PlayerController', PC)
    //     {
    //         PC.ClientMessage("Using custom angle calc...");
    //     }

    //     TargetRot = rotator(Normal(SelfToTarget));
    //     LerpedRot = RLerp(Rotation, TargetRot, 0.95, True); // TODO: Stupid?
    //     PitchDiff = LerpedRot.Pitch - Rotation.Pitch;
    //     YawDiff = LerpedRot.Yaw - Rotation.Yaw;
    //     RollDiff = LerpedRot.Roll - Rotation.Roll;

    //     ForEach LocalPlayerControllers(class'PlayerController', PC)
    //     {
    //         PC.ClientMessage("RotDiff P Y R          : " @ PitchDiff @ YawDiff @ RollDiff);
    //     }

    //     PitchDiff = Clamp(PitchDiff, -MaxAngleDeltaUnrRot, MaxAngleDeltaUnrRot);
    //     YawDiff = Clamp(YawDiff, -MaxAngleDeltaUnrRot, MaxAngleDeltaUnrRot);
    //     RollDiff = Clamp(RollDiff, -MaxAngleDeltaUnrRot, MaxAngleDeltaUnrRot);

    //     ForEach LocalPlayerControllers(class'PlayerController', PC)
    //     {
    //         PC.ClientMessage("RotDiff P Y R (Clamped): " @ PitchDiff @ YawDiff @ RollDiff);
    //     }

    //     NewRot = Rotation;
    //     NewRot.Pitch += PitchDiff;
    //     NewRot.Yaw += YawDiff;
    //     NewRot.Roll += RollDiff;

    //     // TODO: this is stupid!
    //     // Velocity = (Speed * Normal(vector(NewRot))) /*>> Rotation*/;
    //     Velocity = (VSize(Velocity) * Normal(vector(NewRot))) /*>> Rotation*/;
    //     // SetRotation(NewRot);

    //     // RED   = Loc -> Target.
    //     // GREEN = Loc -> NewRot.
    //     // BLUE  = Loc -> TargetRot.
    //     DrawDebugLine(Location, LockedTarget.Location, 255, 15, 15, False);
    //     DrawDebugLine(Location, (Normal(vector(NewRot)) * VSize(SelfToTarget) /*>> Rotation */), 15, 255, 15, False);
    //     DrawDebugLine(Location, (Normal(vector(TargetRot)) * VSize(SelfToTarget) /*>> Rotation */), 15, 15, 255, False);
    //     DrawDebugLine(Location, (Normal(vector(Rotation)) * VSize(SelfToTarget) /*>> Rotation */), 255, 255, 255, False);
    // }

    // // Tolerance for near misses.
    // // TODO: don't check this like this! Check for collision OR near collision!
    // // TODO: also, we can pre-calculate DamageRadiusSq * 0.25! If we really need it!
    // if (DistanceSq <= (DamageRadiusSq * 0.25))
    // {
    //     `hcdebug("close enough, exploding, DistanceSq=" $ DistanceSq);
    //     Explode(Location, Normal(Velocity));
    // }
}

DefaultProperties
{
    bTrueBallistics=False
    bExplodeOnDeflect=True
    bRotationFollowsVelocity=True
    EffectiveNavigationRatio=5
    MaximumTurnG=6
    DampingForceScaler=0.001

    bWaitForEffects=True

    SpeedPctToTrackingForceScaler={(Points=(
        (InVal=0.00,OutVal=0.005),
        (InVal=0.25,OutVal=0.010),
        (InVal=0.50,OutVal=0.350),
        (InVal=0.75,OutVal=0.750),
        (InVal=0.80,OutVal=0.800),
        (InVal=0.95,OutVal=1.000),
        (InVal=1.00,OutVal=1.000)
        )
    )}

    SmokeTrailTemplate=ParticleSystem'HC_FX.Emitter.FX_Strela2_SmokeTrail'

    RandomErrorMin=1.20
    RandomErrorMax=0.80
}
