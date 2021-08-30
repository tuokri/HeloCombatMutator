class HCVehicleFactory_AH1G_Allies extends ROVehicleFactory_AH1G;

simulated function PostBeginPlay()
{
    local ROGameInfo ROGI;

    super(ROTransportVehicleFactory).PostBeginPlay();

    ROGI = ROGameInfo(WorldInfo.Game);
    if( ROGI != none && ROGI.bCampaignGame )
    {
        if( WorldInfo.NetMode != NM_Standalone )
            VehicleClass = (ROGI.CurrentSouthernFaction == SFOR_AusArmy) ? CampaignAusVehicleClass : CampaignNonAusVehicleClass;

        if( ROGI.CampaignWarPhase == ROCWP_Early )
            bDisableForCampaign = true;
        else
            bDisableForCampaign = false;
    }
    else
        bDisableForCampaign = false;
}

DefaultProperties
{
    VehicleClass=class'HCHeli_AH1G_Allies_Content'
    EnemyVehicleClass=class'HCHeli_AH1G_Content'
    // For campaign
    CampaignNonAusVehicleClass=class'HCHeli_AH1G_Content'
    CampaignAusVehicleClass=class'HCHeli_UH1H_Gunship_Content'
}
