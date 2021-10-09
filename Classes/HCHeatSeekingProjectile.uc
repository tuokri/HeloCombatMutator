class HCHeatSeekingProjectile extends PG7VRocket;

var float MaxAngleDelta;
var Actor LockedTarget;

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

simulated function UpdateTrackingParams(float DeltaTime, out float OutDistance, out float OutAngle)
{
    local vector Direction;
    local vector V;
    local vector HitLoc;
    local vector HitNormal;
    // local float D;
    local float Distance;
    local float Angle;

    Direction = Normal(Vector(Rotation));
    // D = -(Direction dot Location); // TODO: What the fuck is D? Some kind of "padding"?

    /*
    if ((Direction dot LockedTarget.Location + D) > 0.0)
    {
        // Candidate is in front semisphere of the missile.
    */
        V = LockedTarget.Location - Location;
        Distance = VSize(V);
        OutDistance = Distance;

        // Can't see target.
        if (Trace(HitLoc, HitNormal, LockedTarget.Location, Location, True, vect(1,1,1)) != LockedTarget)
        {
            OutAngle = 0;
        }
        else
        {
            Angle = Acos(Direction dot Normal(V));
            OutAngle = Angle;
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

simulated function Tick(float DeltaTime)
{
    local float Distance;
    local float Angle;
    local float Lambda;

    super.Tick(DeltaTime);

    UpdateTrackingParams(DeltaTime, Distance, Angle);

    if (bTrueBallistics || LockedTarget == None || Angle == 0)
    {
        return;
    }

    if (Angle <= MaxAngleDelta)
    {
        Velocity = VSize(Velocity) * Normal(LockedTarget.Location - Location);
    }
    else
    {
        Lambda = MaxAngleDelta / (Angle - MaxAngleDelta);
        Velocity = Normal(((Normal(Vector(Rotation)) * Distance + Location)
            + Lambda * LockedTarget.Location) * (1.0 / (1.0 + Lambda)) - Location) * VSize(Velocity);
    }

    Speed = VSize(Velocity);
    SetRotation (rotator(Velocity));

    if (Distance <= (DamageRadius / 3))
    {
        Explode(Location, -Normal(LockedTarget.Location - Location));
    }
}

DefaultProperties
{
    MaxAngleDelta=0.0080
}
