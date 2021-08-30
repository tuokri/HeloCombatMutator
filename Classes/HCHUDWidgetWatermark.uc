class HCHUDWidgetWatermark extends ROHUDWidgetWatermark;

function Initialize(PlayerController HUDPlayerOwner)
{
    super.Initialize(HUDPlayerOwner);

    HUDComponents[ROHUDWC_GameVersion].Text = "Helicopter Combat Mutator";
    HUDComponents[ROHUDWC_Website].Text = "Version 0.4";
    HUDComponents[ROHUDWC_BuildID].Text = "";
}
