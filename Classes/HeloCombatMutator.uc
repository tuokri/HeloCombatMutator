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
class HeloCombatMutator extends ROMutator
    config(Mutator_HeloCombat);

final static function bool IsDebugBuild()
{
`if(`isdefined(HC_DEBUG))
    return True;
`else
    return False;
`endif
}

function PreBeginPlay()
{
    super.PreBeginPlay();

    `hclog("mutator init, version=" $ `HC_VERSION_STRING);

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
    ClientSetHUD();

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

reliable client function ClientSetHUD()
{
    SetHUD();
}

reliable client function ClientSetPilot(Controller C)
{
    SetPilot(C);
}

// TODO: maybe remove these material debug helpers entirely!
// function ROMutate(string MutateString, PlayerController Sender, out string ResultMsg)
// {
//     local array<string> Args;
//     local Actor A;
//     local Material Mat;
//     local MaterialInstanceConstant MIC;

//     Args = SplitString(MutateString);

//     // Example commands:
//     // romutate spawn,static,VNTE-MaterialContainer.BlinkingTestMat
//     // romutate spawn,skeletal,VNTE-MaterialContainer.TestMat
//     // romutate spawn,skeletal,PackageName.MaterialName
//     if (Locs(Args[0]) == "spawn")
//     {
//         Mat = Material(DynamicLoadObject(Args[2], class'Material'));
//         MIC = new(self) class'MaterialInstanceConstant';
//         MIC.SetParent(Mat);
//         SpawnTestActor(Sender, Locs(Args[1]), MIC);
//     }
//     // romutate setmat,VNTE-MaterialContainer.TestMat
//     // romutate setmat,PackageName.MaterialName
//     if (Locs(Args[0]) == "setmat")
//     {
//         Mat = Material(DynamicLoadObject(Args[1], class'Material'));
//         ForEach TestActors(A)
//         {
//             MIC = new(self) class'MaterialInstanceConstant';
//             MIC.SetParent(Mat);
//             `hclog("setting " $ A $ " material to: " $ MIC);

//             if (A.IsA('HCStaticTestActor'))
//             {
//                 HCStaticTestActor(A).StaticMeshComponent.SetMaterial(0, MIC);
//             }
//             else if (A.IsA('HCSkeletalTestActor'))
//             {
//                 HCSkeletalTestActor(A).SkeletalMeshComponent.SetMaterial(0, MIC);
//             }
//         }
//     }
//     // romutate spawn2
//     if (Locs(Args[0]) == "spawn2")
//     {
//         SpawnTestActor(Sender, "nodynamicmaterial");
//     }

//     super.ROMutate(MutateString, Sender, ResultMsg);
// }

// simulated function SpawnTestActor(PlayerController Player, string Type, optional MaterialInstanceConstant MaterialToApply)
// {
//     local Actor SpawnedActor;
//     local vector Loc;

//     Loc = Player.Pawn.Location + (Normal(vector(Player.Pawn.Rotation)) * 100);
//     `hclog("spawning test actor at " $ Loc);
//     if (MaterialToApply != None)
//     {
//         Player.ClientMessage("[HeloCombatMutator]: spawning test actor at: " $ Loc $ " with material: " $ MaterialToApply);
//     }

//     if (Type == "static")
//     {
//         SpawnedActor = Spawn(class'HCStaticTestActor', Self,, Loc, Player.Pawn.Rotation);
//         HCStaticTestActor(SpawnedActor).StaticMeshComponent.SetMaterial(0, MaterialToApply);
//     }
//     else if (Type == "skeletal")
//     {
//         SpawnedActor = Spawn(class'HCSkeletalTestActor', Self,, Loc, Player.Pawn.Rotation);
//         HCSkeletalTestActor(SpawnedActor).SkeletalMeshComponent.SetMaterial(0, MaterialToApply);
//     }
//     else if (Type == "nodynamicmaterial")
//     {
//         SpawnedActor = Spawn(class'HCSkeletalTestActor2', Self,, Loc, Player.Pawn.Rotation);
//     }
//     else
//     {
//         `hclog("invalid type: " $ Type);
//     }

//     if (SpawnedActor != None)
//     {
//         TestActors.AddItem(SpawnedActor);
//     }
// }

DefaultProperties
{
}
