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

// Custom projectile class that attempts to guide itself to a locked target.
// TODO: fix rotation calcs (use quaternions)!
// https://en.wikipedia.org/wiki/Proportional_navigation
// https://www.ijser.org/researchpaper/Performance-Evaluation-of-Proportional-Navigation-Guidance-for-Low-Maneuvering-Targets.pdf
// https://eprints.ugd.edu.mk/7501/2/MK-CN-TR-002_GELEV%20-%20XU%20et%20al_FuzzyLogic%20in%20Firecontrol%20for%20AirDefence-koregirano27%255B1%255D.03.2007.pdf
// Currently uses proportional navigation.
// Assumes the seeker head is able to rotate.
class HCHeatSeekingProjectile extends PG7VRocket;

// TODO: MAYBE CHANGE ALL UNITS TO RADS OR UNRROTS?

// Cached squared explosion damage radius.
var() float DamageRadiusSq;
// TODO: double-check this!
var() float MaxAngleDelta;
// TODO: double-check this!
var() float MaxAngleDeltaUnrRot;
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

// TODO: HOW FAST CAN THE MISSILE TURN?
// - Add configurable maximum turn rate.
// According to this: https://www.quora.com/What-are-the-acceleration-capabilities-of-surface-to-air-missiles
// Early MANPADS maximum would be 4-6 G.

// TODO: need to be able to configure seeker offset relative to mesh center?
//       - or just assume seeker head is at the center of the missile to simplify things?

event PreBeginPlay()
{
    super.PreBeginPlay();

    DamageRadiusSq = DamageRadius * DamageRadius;
    MaxAngleDeltaUnrRot = MaxAngleDelta * RadToUnrRot;
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
    TrackingForceScaler = 0.0;

    if (Speed < MaxSpeed)
    {
        Acceleration += Normal(Velocity) * (MaxSpeed - Speed) / InitialAccelerationTime;
        `hcdebug("applied acceleration");
    }

    SpawnFlightEffects();
    SetTimer(FueledFlightTime, false, NameOf(CutRocketEngine));
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
    super.Explode(HitLocation, HitNormal);
}

// TODO: Simplify this to simply rotate towards the target, but limit rotation rate.
// TODO: FIXME: Doesn't work properly yet. (Rotator calcs).
simulated function Tick(float DeltaTime)
{
    local int PitchDiff;
    local int YawDiff;
    local int RollDiff;
    local float DistanceSq;
    local float Angle;
    local PlayerController PC;
    local rotator TargetRot;
    local rotator NewRot;
    local rotator LerpedRot;
    local vector SelfToTarget;

    `hclog("Acceleration=" $ Acceleration
        $ ", AccelG=" $ class'ROVehicleHelicopter'.const.ACCEL_G / VSize(Acceleration)
    );

    super.Tick(DeltaTime);

    ForEach LocalPlayerControllers(class'PlayerController', PC)
    {
        PC.ClientMessage("Speed=" $ VSize(Velocity) / 50 @ "m/s");
    }

    if (bExploded)
    {
        return;
    }

    if (!bCanUpdateTracking)
    {
        return;
    }

    TrackingForceScaler = FClamp((Speed / MaxSpeed), 0.0, 1.0);
    UpdateTrackingParams(DeltaTime, DistanceSq, Angle, SelfToTarget);

    if (bTrueBallistics || LockedTarget == None || Angle == 0)
    {
        return;
    }

    if (Angle <= MaxAngleDelta)
    {
        // TODO: this is stupid!
        // Velocity = Speed * Normal(SelfToTarget);
        Velocity = VSize(Velocity) * Normal(SelfToTarget);
    }
    else
    {
        ForEach LocalPlayerControllers(class'PlayerController', PC)
        {
            PC.ClientMessage("Using custom angle calc...");
        }

        TargetRot = rotator(Normal(SelfToTarget));
        LerpedRot = RLerp(Rotation, TargetRot, 0.95, True); // TODO: Stupid?
        PitchDiff = LerpedRot.Pitch - Rotation.Pitch;
        YawDiff = LerpedRot.Yaw - Rotation.Yaw;
        RollDiff = LerpedRot.Roll - Rotation.Roll;

        ForEach LocalPlayerControllers(class'PlayerController', PC)
        {
            PC.ClientMessage("RotDiff P Y R          : " @ PitchDiff @ YawDiff @ RollDiff);
        }

        PitchDiff = Clamp(PitchDiff, -MaxAngleDeltaUnrRot, MaxAngleDeltaUnrRot);
        YawDiff = Clamp(YawDiff, -MaxAngleDeltaUnrRot, MaxAngleDeltaUnrRot);
        RollDiff = Clamp(RollDiff, -MaxAngleDeltaUnrRot, MaxAngleDeltaUnrRot);

        ForEach LocalPlayerControllers(class'PlayerController', PC)
        {
            PC.ClientMessage("RotDiff P Y R (Clamped): " @ PitchDiff @ YawDiff @ RollDiff);
        }

        NewRot = Rotation;
        NewRot.Pitch += PitchDiff;
        NewRot.Yaw += YawDiff;
        NewRot.Roll += RollDiff;

        // TODO: this is stupid!
        // Velocity = (Speed * Normal(vector(NewRot))) /*>> Rotation*/;
        Velocity = (VSize(Velocity) * Normal(vector(NewRot))) /*>> Rotation*/;
        // SetRotation(NewRot);

        // RED   = Loc -> Target.
        // GREEN = Loc -> NewRot.
        // BLUE  = Loc -> TargetRot.
        DrawDebugLine(Location, LockedTarget.Location, 255, 15, 15, False);
        DrawDebugLine(Location, (Normal(vector(NewRot)) * VSize(SelfToTarget) /*>> Rotation */), 15, 255, 15, False);
        DrawDebugLine(Location, (Normal(vector(TargetRot)) * VSize(SelfToTarget) /*>> Rotation */), 15, 15, 255, False);
        DrawDebugLine(Location, (Normal(vector(Rotation)) * VSize(SelfToTarget) /*>> Rotation */), 255, 255, 255, False);
    }

    // Tolerance for near misses.
    // TODO: don't check this like this! Check for collision OR near collision!
    // TODO: also, we can pre-calculate DamageRadiusSq * 0.25! If we really need it!
    if (DistanceSq <= (DamageRadiusSq * 0.25))
    {
        `hcdebug("close enough, exploding, DistanceSq=" $ DistanceSq);
        Explode(Location, Normal(Velocity));
    }
}

DefaultProperties
{
    MaxAngleDelta=0.0120
    bRotationFollowsVelocity=True
    bCanUpdateTracking=False
    TrackingForceScaler=0.0
}
