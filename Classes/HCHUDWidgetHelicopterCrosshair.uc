class HCHUDWidgetHelicopterCrosshair extends ROHUDWidget;

var ROVehicleHelicopter MyHelo;

var(HeloCrosshair) bool bEnabled;

var(HeloCrosshair) int CrossHairAlpha;
var(HeloCrosshair) int CrosshairSize;
var(HeloCrosshair) int CrossHairSpread;

// How far in front of the helicopter the crosshair is.
// The crosshair is actually drawn on the 2D canvas, but we use this value in
// the 3D third person crosshair calculations.
var(HeloCrosshair) int CrossHairDistance;

var int CenterX;
var int CenterY;
var int OffsetX;
var int OffsetY;

const Sin90 = 1;
const Rad90 = 1.57079633; // 90 degrees in radians.

function PostBeginPlay()
{
    super.PostBeginPlay();

    UpdateCrosshairPos();
}

function UpdateCrosshairPos()
{
    local rotator CamRot;
    local rotator GunSocketRot;

    local vector CamTraceHitLoc;
    local vector CamTraceHitNorm;
    local vector GunTraceHitNorm;
    local vector End;
    local vector GunSocketLoc;
    local vector CamLoc;
    local vector GunTraceHitLoc;
    local vector CamToGunTraceHitLoc;
    local vector CamToCamTraceHitLoc;

    // The angle between CamToGunTraceHitLoc and CamToCamTraceHitLoc.
    local float Theta;
    local float K;

    local float DistToGunTrace; // From CamLoc.
    local float DistToCamTrace; // From CamLoc.

    local float OffsetMult;

    if (PlayerOwner == None || MyHelo == None || MyHelo.Mesh == None || MyHelo.Controller == None)
    {
        return;
    }

    // Trace helicopter weapon muzzle and calculate crosshair offset.
    MyHelo.Mesh.GetSocketWorldLocationAndRotation(MyHelo.Seats[0].GunSocket[0], GunSocketLoc, GunSocketRot);
    End = GunSocketLoc + (Normal(vector(GunSocketRot)) * 1000000);
    Trace(GunTraceHitLoc, GunTraceHitNorm, End, GunSocketLoc, False, vect(1,1,1));

    if (IsZero(GunTraceHitLoc))
    {
        PlayerOwner.ClientMessage("GunTraceHitLoc is zero");
        `log("GunTraceHitLoc is zero");
        CenterX = PlayerOwner.myROHUD.CenterX;
        CenterY = PlayerOwner.myROHUD.CenterY;
        return;
    }

    ROPlayerController(MyHelo.Controller).GetPlayerViewPoint(CamLoc, CamRot);

    End = CamLoc + (Normal(vector(CamRot)) * 1000000);
    Trace(CamTraceHitLoc, CamTraceHitNorm, End, CamLoc, False, vect(1,1,1));

    if (IsZero(CamTraceHitLoc))
    {
        PlayerOwner.ClientMessage("CamTraceHitLoc is zero");
        `log("CamTraceHitLoc is zero");
        CenterX = PlayerOwner.myROHUD.CenterX;
        CenterY = PlayerOwner.myROHUD.CenterY;
        return;
    }

    CamToGunTraceHitLoc = GunTraceHitLoc - CamLoc;
    CamToCamTraceHitLoc = CamTraceHitLoc - CamLoc;
    DistToGunTrace = VSize(CamToGunTraceHitLoc);
    DistToCamTrace = VSize(CamToCamTraceHitLoc);

    `log("DistToGunTrace = " $ DistToGunTrace);
    `log("DistToCamTrace = " $ DistToCamTrace);

    Theta = Acos((CamToGunTraceHitLoc dot CamToCamTraceHitLoc) / (DistToGunTrace * DistToCamTrace));
    K = Rad90 - Theta;

    PlayerOwner.ClientMessage("Theta = " $ Theta * RadToDeg $ " deg");
    `log("Theta = " $ Theta * RadToDeg $ " deg");
    `log("K     = " $ K * RadToDeg $ " deg");

    OffsetMult = (DistToCamTrace > DistToGunTrace) ? 1 : -1;

    OffsetY = (CrossHairDistance / Sin(K)) * Sin(Theta) * OffsetMult;
    OffsetX = 0;

    // DrawDebugLine(CamLoc, GunTraceHitLoc, 255, 15, 15, False);  // Red.
    // DrawDebugLine(CamLoc, CamTraceHitLoc, 255, 255, 15, False);  // Yellow.
    // DrawDebugSphere(GunTraceHitLoc, 8, 8, 255, 15, 15);
    // DrawDebugSphere(CamTraceHitLoc, 8, 8, 255, 255, 15);

    `log("CamLoc = " $ CamLoc);

    CenterX = PlayerOwner.myROHUD.CenterX + OffsetX;
    CenterY = PlayerOwner.myROHUD.CenterY + OffsetY;

    PlayerOwner.ClientMessage("OffsetX = " $ OffsetX);
    PlayerOwner.ClientMessage("OffsetY = " $ OffsetY);
    `log("OffsetX = " $ OffsetX);
    `log("OffsetY = " $ OffsetY);
}

/*
function HandleCanvasSizeChange(Canvas HUDCanvas, float ScaleX, float ScaleY)
{
    super.HandleCanvasSizeChange(HUDCanvas, ScaleY, ScaleY);

    UpdateCrosshairPos();
}
*/

function UpdateWidget()
{
    local bool bPilot;

    if (PlayerOwner == none || PlayerOwner.Pawn == none || !bEnabled)
    {
        bVisible = false;
        return;
    }

    // Pilot.
    if (ROVehicleHelicopter(PlayerOwner.Pawn) != none)
    {
        MyHelo = ROVehicleHelicopter(PlayerOwner.Pawn);
        bPilot = true;
    }
    /*
    // Copilot in control.
    else if (ROHelicopterWeaponPawn(PlayerOwner.Pawn) != none)
    {
        MyHelo = ROVehicleHelicopter(ROHelicopterWeaponPawn(PlayerOwner.Pawn).MyVehicle);

        if (MyHelo != none && MyHelo.Seats[ROHelicopterWeaponPawn(
            PlayerOwner.Pawn).MySeatIndex].SeatPositions[MyHelo.SeatPositionIndex(
            ROHelicopterWeaponPawn(PlayerOwner.Pawn).MySeatIndex,,true)].bCanFlyHelo)
        {
            bPilot = true;
        }
    }
    */

    // Hide everything if we're not a pilot.
    if (!bPilot)
    {
        bVisible = false;
        return;
    }
    else
    {
        bVisible = true;
        if (PlayerOwner.myROHUD != none && PlayerOwner.myROHUD.CompassWidget != none)
        {
            PlayerOwner.myROHUD.CompassWidget.Show();
        }
    }

    if (MyHelo != None && bPilot)
    {
        UpdateCrosshairPos();

        Canvas.SetDrawColor(255, 255, 255, CrossHairAlpha);
        Canvas.SetPos(CenterX, CenterY);
        Canvas.DrawRect(1, 1);

        // Left side
        // Drop shadow
        Canvas.SetDrawColor(0, 0, 0, CrossHairAlpha);
        Canvas.SetPos(CenterX - (CrosshairSize + CrossHairSpread) - 1, CenterY - 1);
        Canvas.DrawRect(CrosshairSize + 1, 3);
        // Crosshair
        Canvas.SetDrawColor(255, 255, 255, CrossHairAlpha);
        Canvas.SetPos(CenterX - (CrosshairSize + CrossHairSpread), CenterY);
        Canvas.DrawRect(CrosshairSize, 1);

        // Right side
        // Drop shadow
        Canvas.SetDrawColor(0, 0, 0, CrossHairAlpha);
        Canvas.SetPos(CenterX + CrossHairSpread + 1, CenterY - 1);
        Canvas.DrawRect(CrosshairSize + 1, 3);
        // Crosshair
        Canvas.SetDrawColor(255, 255, 255, CrossHairAlpha);
        Canvas.SetPos(CenterX + CrossHairSpread + 1, CenterY);
        Canvas.DrawRect(CrosshairSize, 1);

        // Top
        // Drop shadow
        Canvas.SetDrawColor(0, 0, 0, CrossHairAlpha);
        Canvas.SetPos(CenterX - 1, CenterY - (CrosshairSize + CrossHairSpread) - 1);
        Canvas.DrawRect(3, CrosshairSize + 1);
        // Crosshair
        Canvas.SetDrawColor(255, 255, 255, CrossHairAlpha);
        Canvas.SetPos(CenterX, CenterY - (CrosshairSize + CrossHairSpread));
        Canvas.DrawRect(1, CrosshairSize);

        // Bottom
        // Drop shadow
        Canvas.SetDrawColor(0, 0, 0, CrossHairAlpha);
        Canvas.SetPos(CenterX - 1, CenterY + CrossHairSpread + 1);
        Canvas.DrawRect(3, CrosshairSize + 1);
        // Crosshair
        Canvas.SetDrawColor(255, 255, 255, CrossHairAlpha);
        Canvas.SetPos(CenterX, CenterY + CrossHairSpread + 1);
        Canvas.DrawRect(1, CrosshairSize);
    }

    super.UpdateWidget();
}

DefaultProperties
{
    bEnabled=True
    CrosshairSize=25
    CrossHairSpread=32
    CrossHairAlpha=195
    CrossHairDistance=500 // 10m.
}
