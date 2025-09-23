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

final function bool AllowDebugCommand()
{
    return WorldInfo.NetMode == NM_Standalone
        || WorldInfo.IsPlayInEditor()
        || class'HeloCombatMutator'.static.IsDebugBuild();
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

DefaultProperties
{
}
