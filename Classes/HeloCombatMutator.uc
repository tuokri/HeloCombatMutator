class HeloCombatMutator extends ROMutator
    config(Mutator_HeloCombat);

function PreBeginPlay()
{
    super.PreBeginPlay();

    `log("mutator init",, 'HeloCombatMutator');

    ROGameInfo(WorldInfo.Game).PlayerControllerClass = class'HCPlayerController';
    SetHUD();
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
}
