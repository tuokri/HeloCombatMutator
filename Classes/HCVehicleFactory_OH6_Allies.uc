class HCVehicleFactory_OH6_Allies extends ROVehicleFactory_OH6;

simulated function PostBeginPlay()
{
    local ROGameInfo ROGI;

    super(ROTransportVehicleFactory).PostBeginPlay();

    ROGI = ROGameInfo(WorldInfo.Game);

    if(ROGI != none && ROGI.bCampaignGame)
    {
        if(ROGI.CampaignWarPhase == ROCWP_Early)
        {
            bDisableForCampaign = true;
            return;
        }
        else
            bDisableForCampaign = false;
    }

    if( ROMapInfo(WorldInfo.GetMapInfo()) != none && ROMapInfo(WorldInfo.GetMapInfo()).SouthernForce == SFOR_AusArmy )
        VehicleClass = AusLoachClass;
    else
        VehicleClass = USLoachClass;
}

DefaultProperties
{
    USLoachClass=class'HCHeli_OH6_Allies_Content'
    AusLoachClass=class'HCHeli_OH6_Allies_Content'
    EnemyVehicleClass=class'HCHeli_OH6_Content'
    DrawScale=1.0

    bTransportHeloFactory=true
}
