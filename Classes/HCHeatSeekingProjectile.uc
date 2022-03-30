class HCHeatSeekingProjectile extends PG7VRocket;

var float DamageRadiusSq;
var float MaxAngleDelta;
var float MaxAngleDeltaUnrRot;
var Actor LockedTarget;
var bool bExploded;

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
    if( Speed < MaxSpeed )
    {
        Acceleration += Normal(Velocity) * (MaxSpeed - Speed) / InitialAccelerationTime;
    }
    /*

    if(SpreadStartDelay > 0)
    {
        SetTimer(SpreadStartDelay, false, 'StartFlightDeviation');
    }
    else
    {
        StartFlightDeviation();
    }
    */

    SetTimer(FueledFlightTime, false, 'CutRocketEngine');
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

    super.Tick(DeltaTime);

    if (bExploded)
    {
        return;
    }

    UpdateTrackingParams(DeltaTime, DistanceSq, Angle, SelfToTarget);

    if (bTrueBallistics || LockedTarget == None || Angle == 0)
    {
        return;
    }

    if (Angle <= MaxAngleDelta)
    {
        Velocity = Speed * Normal(SelfToTarget);
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

        Velocity = (Speed * Normal(vector(NewRot))) /*>> Rotation*/;
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
    if (DistanceSq <= (DamageRadiusSq * 0.25))
    {
        Explode(Location, Normal(Velocity));
    }
}

DefaultProperties
{
    MaxAngleDelta=0.0120
    bRotationFollowsVelocity=True
}
