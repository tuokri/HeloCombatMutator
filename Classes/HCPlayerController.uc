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
    local HeloCombatMutator HCM;
    local Mutator Mut;

    Mut = WorldInfo.Game.BaseMutator;
    while (HCM == None && Mut != None)
    {
        HCM = HeloCombatMutator(Mut);
        Mut = Mut.NextMutator;
    }

    return HCM;
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
// TODO: Parachutes!
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

        if (ROVEH != none)
        {
            if (ROVEH.bInfantryCanUse)
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
                SetTimer(0.25, false, NameOf(ExitVehicle));
                return;
            }
        }
        else // We aren't a pilot
        {
            ROWP = ROWeaponPawn(Pawn);

            if (ROWP != none && ROWP.MyVehicle != none && ROWP.MyVehicle.bInfantryCanUse)
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
                SetTimer(0.25, false, NameOf(ExitVehicle));
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
    else if (NewMode == 'free')
    {
        NewMode = 'FreeCam';
    }
    else if (NewMode == 'fixed')
    {
        NewMode = 'Fixed';
    }
    else
    {
        NewMode = '';
    }

    if (NewMode != '')
    {
        SetCameraMode(NewMode);
    }
}

simulated exec function GiveStrela()
{
    if (WorldInfo.NetMode == NM_Standalone || WorldInfo.IsPlayInEditor()
        || class'HeloCombatMutator'.static.IsDebugBuild())
    {
        ROPawn(Pawn).LoadAndCreateInventory("HeloCombat.HCWeap_MANPADS_9K32Strela2_Content");
        ServerGiveStrela(ROPawn(Pawn));
    }
}

reliable private server function ServerGiveStrela(ROPawn ROP)
{
    ROP.LoadAndCreateInventory("HeloCombat.HCWeap_MANPADS_9K32Strela2_Content");
}

exec function ForceGunshipOrbit()
{
    if (WorldInfo.NetMode == NM_Standalone || WorldInfo.IsPlayInEditor()
        || class'HeloCombatMutator'.static.IsDebugBuild())
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
        `hclog("Error Spawning Support Aircraft");
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

simulated exec function ExplodeMissiles()
{
    if (WorldInfo.NetMode == NM_Standalone || WorldInfo.IsPlayInEditor()
        || class'HeloCombatMutator'.static.IsDebugBuild())
    {
        ServerExplodeMissiles();
    }
}

private reliable server function ServerExplodeMissiles()
{
    local HCHeatSeekingProjectile Proj;

    ForEach WorldInfo.AllActors(class'HCHeatSeekingProjectile', Proj)
    {
        Proj.Explode(Proj.Location, vect(0,0,0));
    }
}

exec function ForceNapalmStrike(optional bool bLockX, optional bool bLockY)
{
    if (WorldInfo.NetMode == NM_Standalone || WorldInfo.IsPlayInEditor()
        || class'HeloCombatMutator'.static.IsDebugBuild())
    {
        DoTestNapalmStrike(bLockX, bLockY);
    }
}

reliable private server function DoTestNapalmStrike(bool bLockX, bool bLockY)
{
    local vector TargetLocation, SpawnLocation;
    local class<RONapalmStrikeAircraft> AircraftClass;
    local RONapalmStrikeAircraft Aircraft;
    local ROTeamInfo ROTI;
    local ROMapInfo ROMI;

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

    ROMI = ROMapInfo(WorldInfo.GetMapInfo());

    if( ROMI != none && ROMI.SouthernForce == SFOR_ARVN )
        AircraftClass = class'RONapalmStrikeAircraftARVN';
    else
        AircraftClass = class'RONapalmStrikeAircraft';

    SpawnLocation = GetBestAircraftSpawnLoc(TargetLocation, ROMapInfo(WorldInfo.GetMapInfo()).NapalmStrikeHeightOffset, AircraftClass);
    TargetLocation.Z = SpawnLocation.Z;

    Aircraft = Spawn(AircraftClass,self,, SpawnLocation, rotator(TargetLocation - SpawnLocation));

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

        Aircraft.SetDropPoint();
    }

    KillsWithCurrentNapalm = 0; // Reset Napalm Kills as We call it in!!!
}

exec function ForceCanberraStrike(optional float XDir, optional float YDir)
{
    local vector2D StrikeDir;

    StrikeDir.X = XDir;
    StrikeDir.Y = YDir;

    if (WorldInfo.NetMode == NM_Standalone || WorldInfo.IsPlayInEditor()
        || class'HeloCombatMutator'.static.IsDebugBuild())
    {
        DoTestCanberraStrike(StrikeDir);
    }
}

reliable private server function DoTestCanberraStrike(optional vector2D StrikeDir)
{
    local vector TargetLocation, SpawnLocation;
    local ROCarpetBomberAircraft Aircraft;
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

    SpawnLocation = GetSupportAircraftSpawnLoc(TargetLocation, class'ROCarpetBomberAircraft', StrikeDir);

    if( ROMapInfo(WorldInfo.GetMapInfo()).bUseNapalmHeightOffsetForAll )
        SpawnLocation.Z += ROMapInfo(WorldInfo.GetMapInfo()).NapalmStrikeHeightOffset;
    else
        SpawnLocation.Z += ROMapInfo(WorldInfo.GetMapInfo()).CarpetBomberHeightOffset;

    TargetLocation.Z = SpawnLocation.Z;

    Aircraft = Spawn(class'ROCarpetBomberAircraft',self,, SpawnLocation, rotator(TargetLocation - SpawnLocation));

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

        Aircraft.SetDropPoint();
        Aircraft.SetOffset(1);
    }

    Aircraft = Spawn(class'ROCarpetBomberAircraft',self,, SpawnLocation, rotator(TargetLocation - SpawnLocation));

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

        Aircraft.InboundDelay += 1;
        Aircraft.SetDropPoint();
        Aircraft.SetOffset(2);
    }

    // Tell this commander to update his ability widget
    NotifyAbilityActive();
}
