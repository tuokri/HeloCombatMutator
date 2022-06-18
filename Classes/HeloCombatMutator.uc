class HeloCombatMutator extends ROMutator
    config(Mutator_HeloCombat);

// Map(s) that contain our custom materials.
var array<name> LevelsToPreload;

var array<Actor> TestActors;

function PreBeginPlay()
{
    // local Object Obj;

    PreloadLevels(LevelsToPreload);

    super.PreBeginPlay();

    `hclog("mutator init");

    // Obj = DynamicLoadObject("UnrealEd.EditorEngine", class'Class');
    // `hclog(Obj);

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
    ClientPreloadLevels(LevelsToPreload);
    ClientPreloadCustomMaterials();
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

// Preload level(s) that contain custom materials.
function PreloadLevels(array<name> Levels)
{
    local int Idx;

    for (Idx = 0; Idx < Levels.Length; Idx++)
    {
        `hclog("Levels[" $ Idx $ "]: " $ Levels[Idx]);
    }
    WorldInfo.PrepareMapChange(Levels);
}

// Preload the actual materials.
function PreloadCustomMaterials()
{
    DelayedPreloadCustomMaterials();
}

function DelayedPreloadCustomMaterials()
{
    local Material Mat;
    local ROMapInfo ROMI;
    local Actor A;
    local CustomMaterialContainer CMM;
    local MaterialMapping MM;

    // Wait until PrepareMapChange() finishes (it's async)...
    if (WorldInfo.IsPreparingMapChange())
    {
        SetTimer(0.01, False, NameOf(DelayedPreloadCustomMaterials));
    }
    else
    {
        ROMI = ROMapInfo(WorldInfo.GetMapInfo());

        // TODO:
        // Yikes, triple nested loop... Try to find a better way of doing this.
        // Pre-defined hard-coded list of materials to pre-load?
        ForEach WorldInfo.AllActors(class'Actor', A)
        {
            ForEach A.ComponentList(class'CustomMaterialContainer', CMM)
            {
                `hclog("preloading materials for " $ A $ " " $ CMM);
                ForEach CMM.MaterialMappings(MM)
                {
                    Mat = Material(DynamicLoadObject(MM.MaterialName, class'Material'));
                    `hclog("preloaded " $ Mat);
                    ROMI.SharedContentReferences.AddItem(Mat);
                }
            }
        }
    }
}

reliable client function ClientPreloadCustomMaterials()
{
    PreloadCustomMaterials();
}

reliable client function ClientPreloadLevels(array<name> Levels)
{
    PreLoadLevels(Levels);
}

function ROMutate(string MutateString, PlayerController Sender, out string ResultMsg)
{
    local array<string> Args;
    local Actor A;
    local Material Mat;
    local MaterialInstanceConstant MIC;

    Args = SplitString(MutateString);

    // Example commands:
    // romutate spawn,static,VNTE-MaterialContainer.BlinkingTestMat
    // romutate spawn,skeletal,VNTE-MaterialContainer.TestMat
    // romutate spawn,skeletal,PackageName.MaterialName
    if (Locs(Args[0]) == "spawn")
    {
        Mat = Material(DynamicLoadObject(Args[2], class'Material'));
        MIC = new(self) class'MaterialInstanceConstant';
        MIC.SetParent(Mat);
        SpawnTestActor(Sender, Locs(Args[1]), MIC);
    }
    // romutate setmat,VNTE-MaterialContainer.TestMat
    // romutate setmat,PackageName.MaterialName
    if (Locs(Args[0]) == "setmat")
    {
        Mat = Material(DynamicLoadObject(Args[1], class'Material'));
        ForEach TestActors(A)
        {
            MIC = new(self) class'MaterialInstanceConstant';
            MIC.SetParent(Mat);
            `hclog("setting " $ A $ " material to: " $ MIC);

            if (A.IsA('HCStaticTestActor'))
            {
                HCStaticTestActor(A).StaticMeshComponent.SetMaterial(0, MIC);
            }
            else if (A.IsA('HCSkeletalTestActor'))
            {
                HCSkeletalTestActor(A).SkeletalMeshComponent.SetMaterial(0, MIC);
            }
        }
    }
    // romutate spawn2
    if (Locs(Args[0]) == "spawn2")
    {
        SpawnTestActor(Sender, "nodynamicmaterial");
    }

    super.ROMutate(MutateString, Sender, ResultMsg);
}

simulated function SpawnTestActor(PlayerController Player, string Type, optional MaterialInstanceConstant MaterialToApply)
{
    local Actor SpawnedActor;
    local vector Loc;

    Loc = Player.Pawn.Location + (Normal(vector(Player.Pawn.Rotation)) * 100);
    `hclog("spawning test actor at " $ Loc);
    if (MaterialToApply != None)
    {
        Player.ClientMessage("[HeloCombatMutator]: spawning test actor at: " $ Loc $ " with material: " $ MaterialToApply);
    }

    if (Type == "static")
    {
        SpawnedActor = Spawn(class'HCStaticTestActor', Self,, Loc, Player.Pawn.Rotation);
        HCStaticTestActor(SpawnedActor).StaticMeshComponent.SetMaterial(0, MaterialToApply);
    }
    else if (Type == "skeletal")
    {
        SpawnedActor = Spawn(class'HCSkeletalTestActor', Self,, Loc, Player.Pawn.Rotation);
        HCSkeletalTestActor(SpawnedActor).SkeletalMeshComponent.SetMaterial(0, MaterialToApply);
    }
    else if (Type == "nodynamicmaterial")
    {
        SpawnedActor = Spawn(class'HCSkeletalTestActor2', Self,, Loc, Player.Pawn.Rotation);
    }
    else
    {
        `hclog("invalid type: " $ Type);
    }

    if (SpawnedActor != None)
    {
        TestActors.AddItem(SpawnedActor);
    }
}

DefaultProperties
{
    LevelsToPreload(0)="VNTE-MaterialContainer"
}
