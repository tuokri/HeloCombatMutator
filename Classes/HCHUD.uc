class HCHUD extends ROHUD
    config(Mutator_HeloCombat_Client);

event PostBeginPlay()
{
    super.PostBeginPlay();

    if (WatermarkWidget == none)
    {
        WatermarkWidget = Spawn(DefaultWatermarkWidget, PlayerOwner);

        HUDWidgetList.AddItem(WatermarkWidget);
    }
}

exec function ToggleHUD()
{
    super.ToggleHUD();

    WatermarkWidget.bVisible = !WatermarkWidget.bVisible;
}

DefaultProperties
{
    DefaultWatermarkWidget=class'HCHUDWidgetWatermark'

    WeaponUVs(74)=(WeaponClass=HCWeap_DShK_HMG_Tripod_Content,WeaponTexture=none,KillMessageTexture=Texture2D'VN_UI_Textures.HUD.DeathMessage.UI_Kill_Icon_DShK',KillMessageWidth=128,KillMessageHeight=64)
}
