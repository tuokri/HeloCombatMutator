class HCHUD extends ROHUD
    config(Mutator_HeloCombat_Client);

var HCHUDWidgetHelicopterCrosshair HelicopterCrosshairWidget;
var class<HCHUDWidgetHelicopterCrosshair> DefaultHelicopterCrosshairWidget;

event PostBeginPlay()
{
    super.PostBeginPlay();

    if (WatermarkWidget == none)
    {
        WatermarkWidget = Spawn(DefaultWatermarkWidget, PlayerOwner);

        HUDWidgetList.AddItem(WatermarkWidget);
    }

    HelicopterCrosshairWidget = Spawn(DefaultHelicopterCrosshairWidget, PlayerOwner);
    HelicopterCrosshairWidget.Initialize(PlayerOwner);
    HUDWidgetList.AddItem(HelicopterCrosshairWidget);
}

exec function ToggleHUD()
{
    super.ToggleHUD();

    WatermarkWidget.bVisible = !WatermarkWidget.bVisible;
}

DefaultProperties
{
    DefaultWatermarkWidget=class'HCHUDWidgetWatermark'

    DefaultHelicopterCrosshairWidget=class'HCHUDWidgetHelicopterCrosshair'

    WeaponUVs(74)=(WeaponClass=HCWeap_DShK_HMG_Tripod_Content,WeaponTexture=none,KillMessageTexture=Texture2D'VN_UI_Textures.HUD.DeathMessage.UI_Kill_Icon_DShK',KillMessageWidth=128,KillMessageHeight=64)
}
