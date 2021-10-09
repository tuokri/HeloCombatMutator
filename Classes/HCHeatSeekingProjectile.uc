class HCHeatSeekingProjectile extends PG7VRocket;

var float MaxAngleDelta;
var ROVehicle LockedTarget;

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
    local float D;
    local float Distance;
    local float Angle;

    Direction = Normal(Vector(Rotation));
    D = -(Direction dot Location); // TODO: What the fuck is D? Some kind of "padding"?

    if ((Direction dot LockedTarget.Location + D) > 0.0)
    {
        // Candidate is in front semisphere of the missile.
        V = LockedTarget.Location - Location;
        Distance = VSize(V);
        Angle = Acos(Direction dot Normal(V));

        /* NOTE: For choosing another target if current is "unreachable".
         *       Not needed for our use case.
        if (((Distance / Speed) / DeltaTime) * MaxAngleDelta >= Angle)
        {
            OutAngle = Angle;
        }
        */

        OutAngle = Angle;
        OutDistance = Distance;
    }
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
}

DefaultProperties
{
    MaxAngleDelta=0.0050
    InitialAccelerationTime=1.5
}
