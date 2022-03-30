class HCPlayerController extends ROPlayerController
    config(Mutator_HeloCombat_Client);

var int LastSpecialMessageTime;

simulated function PostBeginPlay()
{
    super.PostBeginPlay();

    if (WorldInfo.NetMode == NM_Standalone)
    {
        GetHCM().SetPilot(self);
        GetHCM().SetHUD();
    }
}

function PawnDied(Pawn P)
{
    super.PawnDied(P);

    // Attempt to fix bugged spawning.
    GetHCM().SetPilot(self, False);
}

function HeloCombatMutator GetHCM()
{
    return HeloCombatMutator(WorldInfo.Game.BaseMutator);
}

reliable client event ReceiveLocalizedMessage(class<LocalMessage> Message, optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject)
{
    // Limit message spam from destroyed projectiles.
    if (Message == class'HCLocalMessageHelicopterBase' && Switch == HCMSGHELOBASE_ProjectileDestroyed)
    {
        if ((LastSpecialMessageTime + Message.static.GetLifeTime(Switch)) < WorldInfo.TimeSeconds)
        {
            super.ReceiveLocalizedMessage(Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
            LastSpecialMessageTime = WorldInfo.TimeSeconds;
        }
    }
    else
    {
        super.ReceiveLocalizedMessage(Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
    }
}

// TODO: Do a seat ejection thingy.
state PlayerDriving
{
    unreliable protected server function ServerUse()
    {
        local ROVehicle ROVEH;
        local ROWeaponPawn ROWP;
        // local ROVehicleHelicopter ROVH;
        local Rotator ViewRotation;
        local Vector ViewLocation;

        ROVEH = ROVehicle(Pawn);

        GetPlayerViewPoint(ViewLocation, ViewRotation);

        if( ROVEH != none )
        {
            if( ROVEH.bInfantryCanUse )
            {
                // ROVH = ROVehicleHelicopter(Pawn);
                //ROVEH.DriverLeave(false);

                /* Allow unsafe exit!
                if( ROVH != none )
                {

                    if( !ROVH.bWasChassisTouchingGroundLastTick && !ROVH.bVehicleOnGround )
                    {
                        ReceiveLocalizedMessage(class'ROLocalMessageVehicleTwo', ROMSGVEH_Airborne);
                        return;
                    }
                    else if ( (!bFreeLooking && !ROVH.SafeToExit()) || !ROVH.IsSafeExitVector(ViewLocation, ViewRotation) )
                    {
                        ReceiveLocalizedMessage(class'ROLocalMessageVehicleTwo', ROMSGVEH_UnsafeToExit);
                        return;
                    }
                }
                */

                // Safe to exit

                ClientStartExitVehicleFadeOut();
                SetTimer(0.25, false, 'ExitVehicle');
                return;
            }
        }
        else // We aren't a pilot
        {
            ROWP = ROWeaponPawn(Pawn);

            if( ROWP != none && ROWP.MyVehicle != none && ROWP.MyVehicle.bInfantryCanUse )
            {
                // ROVH = ROVehicleHelicopter(ROWP.MyVehicle);

                /* Allow unsafe exit!
                if( ROVH != none  )
                {
                    if( !ROVH.bWasChassisTouchingGroundLastTick && !ROVH.bVehicleOnGround )
                    {
                        if( ROWP.MySeatIndex == ROVH.SeatIndexCopilot )
                        {
                            ReceiveLocalizedMessage(class'ROLocalMessageVehicleTwo', ROMSGVEH_Airborne);
                            return;
                        }
                        else if ( !ROVH.IsSafeExitVector(ViewLocation, ViewRotation) )
                        {
                            // if we aren't a copilot or pilot, we must be a passenger. So, let us exit if it's safe
                            ReceiveLocalizedMessage(class'ROLocalMessageVehicleTwo', ROMSGVEH_UnsafeToExit);
                            return;
                        }
                    }
                    else if ( !ROVH.IsSafeExitVector(ViewLocation, ViewRotation) )
                    {
                        // Heli is on the ground, but we still need to check for safe speeds
                        ReceiveLocalizedMessage(class'ROLocalMessageVehicleTwo', ROMSGVEH_UnsafeToExit);
                        return;
                    }
                }
                */

                //ROWP.DriverLeave(false);
                ClientStartExitVehicleFadeOut();
                SetTimer(0.25, false, 'ExitVehicle');
                return;
            }
        }

        // Do nothing - ROVehicle interactions are initiated clientside
    }
}

exec function DrawHeloCrosshair(bool bDraw)
{
    if (ROVehicleHelicopter(Pawn) != None && HCHUD(MyROHUD) != None)
    {
        HCHUD(MyROHUD).HelicopterCrosshairWidget.bEnabled = bDraw;
    }
}

exec function Camera(name NewMode)
{
    ServerCamera(NewMode);
}

reliable server function ServerCamera(name NewMode)
{
    if (NewMode == '1st')
    {
        NewMode = 'FirstPerson';
    }
    else if (NewMode == '3rd')
    {
        NewMode = 'ThirdPerson';
    }
    else
    {
        NewMode = '';
    }
    /*
    else if (NewMode == 'free')
    {
        NewMode = 'FreeCam';
    }
    else if (NewMode == 'fixed')
    {
        NewMode = 'Fixed';
    }
    */

    if (NewMode != '')
    {
        SetCameraMode(NewMode);
    }
}

simulated exec function GiveStrela()
{
    if (WorldInfo.NetMode == NM_Standalone || WorldInfo.IsPlayInEditor())
    {
        ROPawn(Pawn).LoadAndCreateInventory("HeloCombat.HCWeap_9K32Strela2_MANPADS_Content");
    }
}

exec function ForceGunshipOrbit()
{
    if (WorldInfo.NetMode == NM_Standalone || WorldInfo.IsPlayInEditor())
    {
        DoGunshipTestOrbit();
    }
    /*
    else
    {
        Pawn.TakeDamage();
        PlayerCamera.PlayCameraShake(Shake);
    }
    */
}

reliable private server function DoGunshipTestOrbit()
{
    local vector TargetLocation, SpawnLocation;
    local ROGunshipAircraft Aircraft;
    local ROTeamInfo ROTI;

    if ( ROPlayerReplicationInfo(PlayerReplicationInfo) == none ||
         ROPlayerReplicationInfo(PlayerReplicationInfo).RoleInfo == none ||
         Pawn == none )
    {
        return;
    }

    ROTI = ROTeamInfo(PlayerReplicationInfo.Team);

    if ( ROTI != none )
    {
        ROTI.ArtyStrikeLocation = ROTI.SavedArtilleryCoords;
    }

    if( ROTI.ArtyStrikeLocation != vect(-999999.0,-999999.0,-999999.0) )
        TargetLocation = ROTI.ArtyStrikeLocation;
    else
        TargetLocation = Pawn.Location;

    SpawnLocation = GetBestAircraftSpawnLoc(TargetLocation, class'ROGunshipAircraft'.default.Altitude, class'ROGunshipAircraft');
    TargetLocation.Z = SpawnLocation.Z;

    Aircraft = Spawn(class'ROGunshipAircraft',self,, SpawnLocation, rotator(TargetLocation - SpawnLocation));

    if ( Aircraft == none )
    {
        `log("Error Spawning Support Aircraft");
    }
    else
    {
        if( ROTI.ArtyStrikeLocation != vect(-999999.0,-999999.0,-999999.0) )
            Aircraft.TargetLocation = ROTI.ArtyStrikeLocation;
        else
            Aircraft.TargetLocation = Pawn.Location;

        Aircraft.CalculateOrbit();
    }
}
