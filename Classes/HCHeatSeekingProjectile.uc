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

// Custom projectile class that attempts to guide itself to a locked target.
// https://en.wikipedia.org/wiki/Proportional_navigation
// https://www.ijser.org/researchpaper/Performance-Evaluation-of-Proportional-Navigation-Guidance-for-Low-Maneuvering-Targets.pdf
// https://eprints.ugd.edu.mk/7501/2/MK-CN-TR-002_GELEV%20-%20XU%20et%20al_FuzzyLogic%20in%20Firecontrol%20for%20AirDefence-koregirano27%255B1%255D.03.2007.pdf
// https://youtu.be/yUlC6GZEUVs?t=143
// Uses proportional navigation (PN).
// Assumes the seeker head is able to rotate.
// TODO: minimum arming distance!
class HCHeatSeekingProjectile extends PG7VRocket;

const UU_TO_MS = 50;
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

// Current speed relative to MaxSpeed [0.0, 1.0] to allowed
// maximum PN acceleration. Limits missile steering capabilities
// at lower speeds to make it feel more realistic.
var() InterpCurveFloat SpeedPctToTrackingForceScaler;

// TODO: think about this.
var vector SeekerHeadCurrentHeading;
var vector SeekerHeadDesiredHeading;
var vector RelativeVelocity;
var vector MissileToTarget;
var vector RotationVector;
var float PreviousLOSAngle;

var float CurrentSpeed;
var float AccelTimeLeft;

var float ForwardAccelStartTime;
var bool bDebugLoggedAccel;

// TODO: need to be able to configure seeker offset relative to mesh center?
//       - or just assume seeker head is at the center of the missile to simplify things?

event PreBeginPlay()
{
    super.PreBeginPlay();

    MaximumTurnGGame = MaximumTurnG * ACCEL_G;
    DamageRadiusSq = DamageRadius * DamageRadius;

    MaxSpeedSq = (MaxSpeed * MaxSpeed);

    // TODO: for some reason our calcs make it so the missile accelerates a bit
    //       faster than it is supposed to. Increase the time here just a little bit.
    AccelTimeLeft = InitialAccelerationTime * 1.5;
}

simulated function ProcessBulletTouch(Actor Other, Vector HitLocation, Vector HitNormal, PrimitiveComponent OtherComp)
{
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

    bCanUpdateTracking = True;
    TrackingForceScaler = 0.001;

    // TODO: is there a better place to do this?
    // Need to initialize these before starting tracking calcs else we will pull massive Gs on first tick.
    RelativeVelocity = LockedTarget.Velocity - Velocity;
    MissileToTarget = LockedTarget.Location - Location;
    SeekerHeadCurrentHeading = MissileToTarget;

    if (Speed < MaxSpeed)
    {
        ForwardAccelStartTime = WorldInfo.TimeSeconds;
        // Acceleration += Normal(Velocity) * (MaxSpeed - Speed) / InitialAccelerationTime;
        `hcdebug("started accelerating");
    }

    SpawnFlightEffects();
    SetTimer(FueledFlightTime, false, NameOf(CutRocketEngine));
}

function CutRocketEngine()
{
    if (WorldInfo.NetMode != NM_DedicatedServer && ProjEffects != None)
    {
        ProjEffects.SetActive(false);
    }

    // TODO: NetMode check here?
    if (AmbientComponent != None)
    {
        AmbientComponent.StopEvents();
    }

    bTrueBallistics = true;
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
}

simulated function UpdateTrackingParams(float DeltaTime, out float OutDistanceSq, out float OutAngle, out vector OutSelfToTarget)
{
    local vector Direction;
    local vector V;
    local vector HitLoc;
    local vector HitNormal;
    local float Angle;
    local PlayerController PC;

    local vector X;
    local vector Y;
    local vector Z;
    local vector PNAccel;
    local float LOSRate;
    local float LOSAngleDelta;
    local float LOSAngle;
    local float SeekerHeadAngle;

    GetAxes(Rotation, X, Y, Z);

    RelativeVelocity = LockedTarget.Velocity - Velocity;
    `hcdebug("RelativeVelocity=" $ RelativeVelocity / UU_TO_MS @ "m/s");

    MissileToTarget = LockedTarget.Location - Location;
    // RotationVector = (MissileToTarget cross RelativeVelocity) / (RelativeVelocity dot RelativeVelocity);
    RotationVector = (MissileToTarget cross RelativeVelocity) / VSizeSq(RelativeVelocity);
    // TODO: is this right?
    // RotationVector *= DeltaTime;

    DrawDebugLine(Location, Location + Normal(MissileToTarget) * 9000,          255, 015, 015);
    DrawDebugLine(Location, LockedTarget.Location,                              255, 015, 015);
    DrawDebugLine(Location, Location + Normal(SeekerHeadCurrentHeading) * 9000, 015, 255, 015);
    DrawDebugLine(Location, Location + Normal(Velocity) * 9000,                 255, 000, 255); // Magenta.

    // LosAngle =
    // TODO: LOS ANGLE CALC HERE IS WRONG!!!

    LOSAngleDelta = ACos(Normal(MissileToTarget) dot Normal(SeekerHeadCurrentHeading));
    SeekerHeadAngle = ACos(X dot Normal(SeekerHeadCurrentHeading));
    LOSRate = LOSAngleDelta / DeltaTime;
    `hcdebug("LOSAngleDelta=" $ LOSAngleDelta @ "rad" @ LOSAngleDelta * RadToDeg @ "deg");
    `hcdebug("SeekerHeadAngle=" $ SeekerHeadAngle @ "rad" @ SeekerHeadAngle * RadToDeg @ "deg");
    `hcdebug("LOSRate=" $ LOSRate @ "rad/s" @ LOSRate * RadToDeg @ "deg/s");
    SeekerHeadCurrentHeading = MissileToTarget;

    // 1. Check that target is within seeker head's FoV.
    // 2. Based on target location and seeker location, check how much we have to rotate
    //    to keep direct LoS to target.
    // 3. Limit seeker head rotator angle to SeekerMaxBearingAngleDeg, limit the amount
    //    seeker head rotates by TrackingMaxDegPerSecond.
    // 4. Calculate and apply PN acceleration.

    // TODO: NEED TO TIE DELTATIME INTO THIS SOMEHOW!!!???

    // Wikipedia, acceleration normal to the instantaneous velocity difference.
    // PNAccel = EffectiveNavigationRatio * (RelativeVelocity cross RotationVector);

    // Wikipedia, dependence is only on the change of the line of sight
    // and the magnitude of the closing velocity.
    // PNAccel = -EffectiveNavigationRatio * VSize(RelativeVelocity)
    //     * ((MissileToTarget / VSize(MissileToTarget)) cross RotationVector);

    // Wikipedia, energy conserving control.
    // TODO: is this pure PN?
    // PNAccel = -EffectiveNavigationRatio * VSize(RelativeVelocity)
    //     * (((Velocity / CurrentSpeed) cross RotationVector) * DeltaTime);
    PNAccel = -EffectiveNavigationRatio * VSize(RelativeVelocity)
        * ((Velocity / CurrentSpeed) cross RotationVector);

    DrawDebugLine(Location, Location + Normal(PNAccel) * 9000, 015, 015, 255);

    `hcdebug("(RAW)    PNAccel=" $ PNAccel @ "[" $ VSize(PNAccel) / ACCEL_G $ "] G");
    // PNAccel *= TrackingForceScaler;
    // `hcdebug("(SCALED) PNAccel=" $ PNAccel @ "[" $ VSize(PNAccel) / ACCEL_G $ "] G");
    // PNAccel *= DeltaTime;
    // `hcdebug("(Delta)   PNAccel=" $ PNAccel @ "[" $ VSize(PNAccel) / ACCEL_G $ "] G");
    PNAccel = ClampLength(PNAccel, MaximumTurnGGame * TrackingForceScaler);
    `hcdebug("(CLAMP)  PNAccel=" $ PNAccel @ "[" $ VSize(PNAccel) / ACCEL_G $ "] G");

    // TODO: how the fuck do we apply this correctly?
    // Apply a force equal to PNAccel magnitude in the direction???
    // We do NOT want PNAccel to accelerate the missile in the forward direction!!!
    Acceleration += PNAccel;

    // Accelerate forward using rocket engine.
    if (AccelTimeLeft > 0)
    {
        // Get desired speed after this tick?
        // Add accel to reach desired speed after this tick?

        Acceleration += (X * (MaxSpeed - CurrentSpeed) / AccelTimeLeft) * DeltaTime;
        AccelTimeLeft -= DeltaTime;
    }

    // TODO: cleanup!
    return;

    Direction = Normal(Vector(Rotation));
    // D = -(Direction dot Location); // TODO: What the fuck is D? Some kind of "padding"?

    /*
    if ((Direction dot LockedTarget.Location + D) > 0.0)
    {
        // Candidate is in front semisphere of the missile.
    */
        V = LockedTarget.Location - Location;
        OutSelfToTarget = V;
        OutDistanceSq = VSizeSq(V);

        // Can't see target.
        if (Trace(HitLoc, HitNormal, LockedTarget.Location, Location + (1000 * Normal(V)), True, vect(1,1,1)) != LockedTarget)
        {
            OutAngle = 0;
        }
        else
        {
            Angle = Acos(Direction dot Normal(V));
            OutAngle = Angle;

            ForEach LocalPlayerControllers(class'PlayerController', PC)
            {
                PC.ClientMessage("Angle = " $ Angle * RadToDeg);
            }
        }

        // NOTE: For choosing another target if current is "unreachable".
        //       Not needed for our use case.
        // TODO: Actually, maybe this is needed after all! Flares?
        // if (((Distance / Speed) / DeltaTime) * MaxAngleDelta >= Angle)
        // {
        //     OutAngle = Angle;
        // }

    /*
    }
    */
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    bExploded = True;
    bCanUpdateTracking = False;
    super.Explode(HitLocation, HitNormal);
}

simulated function Tick(float DeltaTime)
{
    // local int PitchDiff;
    // local int YawDiff;
    // local int RollDiff;
    local float DistanceSq;
    local float Angle;
    local PlayerController PC;
    // local rotator TargetRot;
    // local rotator NewRot;
    // local rotator LerpedRot;
    local vector SelfToTarget;

    super.Tick(DeltaTime);

    CurrentSpeed = VSize(Velocity);

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

    `hclog("Acceleration=" $ Acceleration $ ", AccelG=" $ ACCEL_G / VSize(Acceleration));

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
    TrackingForceScaler = EvalInterpCurveFloat(SpeedPctToTrackingForceScaler, VSizeSq(Velocity) / MaxSpeedSq);
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
    bExplodeOnDeflect=True
    bRotationFollowsVelocity=True
    EffectiveNavigationRatio=5
    MaximumTurnG=6

    SpeedPctToTrackingForceScaler={(Points=(
        (InVal=0.00,OutVal=0.001),
        (InVal=0.25,OutVal=0.005),
        (InVal=0.50,OutVal=0.250),
        (InVal=0.75,OutVal=0.750),
        (InVal=0.80,OutVal=1.000),
        (InVal=1.00,OutVal=1.000)
        )
    )}
}
