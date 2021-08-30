class HeloCombatMutator extends ROMutator
    config(Mutator_HeloCombat);

function PreBeginPlay()
{
    super.PreBeginPlay();

    `log("mutator init",, 'HeloCombatMutator');

    ROGameInfo(WorldInfo.Game).PlayerControllerClass = class'HCPlayerController';
    SetHUD();
    // SetAllRolesPilot();
}

function ModifyPlayer(Pawn Other)
{
    SetPilot(Other.Controller);
    ClientSetPilot(Other.Controller);

    super.ModifyPlayer(Other);
}

function NotifyLogin(Controller NewPlayer)
{
    ClientSedHUD();
    // ClientSetPilot(NewPlayer);

    super.NotifyLogin(NewPlayer);
}

function PawnSetPilot(Pawn P, optional bool bIsPilot = True)
{
    ROPawn(P).bIsPilot = bIsPilot;
}

function SetPilot(Controller C, optional bool bIsPilot = True)
{
    ROPlayerReplicationInfo(C.PlayerReplicationInfo).RoleInfo.bIsPilot = bIsPilot;
    PawnSetPilot(ROPawn(C.Pawn), bIsPilot);
}

function ModifyPreLogin(string Options, string Address, out string ErrorMessage)
{
    local string UniqueID;
    local bool bIDIsAllowed;

    UniqueID = class'GameInfo'.static.ParseOption(Options, "UniqueID");
    bIDIsAllowed = class'CustomAccessControl'.static.CheckUniqueID(UniqueID);

    // No matching ID found, deny access.
    if (!bIDIsAllowed)
    {
        ErrorMessage = "Only whitelisted players allowed.";
    }

    super.ModifyPreLogin(Options, Address, ErrorMessage);
}

/*
simulated function SetAllRolesPilot()
{
    local int i;
    local ROMapInfo ROMI;

    ROMI = ROMapInfo(WorldInfo.GetMapInfo());

    for (i = 0; i < ROMI.SouthernRoles.Length; i++)
    {
        switch ROMI.SouthernRoles[i].RoleInfoClass:
            case '':
    }
    for (i = 0; i < ROMI.NorthernRoles.Length; i++)
    {
        switch ROMI.NorthernRoles[i].RoleInfoClass:
            case '':
    }
}
*/

function SetHUD()
{
    ROGameInfo(WorldInfo.Game).HUDType = class'HCHUD';
}

reliable client function ClientSedHUD()
{
    SetHUD();
}

reliable client function ClientSetPilot(Controller C)
{
    SetPilot(C);
    // SetAllRolesPilot();
}
