class HCHelicopterBaseProtection extends Trigger_Projectile
    placeable;

/** Owning team index. 0 = Axis, 1 = Allies. */
var() int OwningTeam;


event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    local ROPlayerController DriverPC;
    local ROVehicleHelicopter ROVH;
    local VehicleSeat Seat;

    // `log("HCHelicopterBaseProtection.Touch(): Other=" $ Other);

    ROVH = ROVehicleHelicopter(Other);

    // `log("HCHelicopterBaseProtection.Touch(): ROVH=" $ ROVH);

    if (ROVH == None)
    {
        return;
    }

    DriverPC = ROPlayerController(ROVH.Controller);

    // `log("HCHelicopterBaseProtection.Touch(): DriverPC=" $ DriverPC);

    // TODO: Push vehicle away from trigger.
    if (DriverPC != None && DriverPC.GetTeamNum() != OwningTeam)
    {
        ROVH.ApplyLiftAndTorque(-HitNormal * 1000000, HitNormal * 100);

        ForEach ROVH.Seats(Seat)
        {
            if (Seat.SeatPawn != None)
            {
                if (Seat.SeatPawn.Controller != None)
                {
                    HCPlayerController(Seat.SeatPawn.Controller).ReceiveLocalizedMessage(
                        Class'HCLocalMessageHelicopterBase', HCMSGHELOBASE_AccessDenied);
                }
            }
        }
    }

    super.Touch(Other, OtherComp, HitLocation, HitNormal);
}

/*
simulated function bool StopsProjectile(Projectile P)
{
    `log("HCHelicopterBaseProtection.StopsProjectile(): P=" $ P);

    return super.StopsProjectile(P);
}
*/

DefaultProperties
{
    OwningTeam=`AXIS_TEAM_INDEX

    // bColored=true
    // BrushColor=(R=35,G=255,B=35,A=255)

    bProjTarget=true
    bCollideActors=true
    bBlockActors=false

    CollisionType=COLLIDE_TouchAll

    SupportedEvents.Empty
    SupportedEvents(0)=class'SeqEvent_Touch'
    SupportedEvents(1)=class'SeqEvent_TakeDamage'
}
