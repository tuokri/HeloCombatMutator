/*
 * Copyright (c) 2021-2025 Tuomo Kriikkula <tuokri@tuta.io>
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
