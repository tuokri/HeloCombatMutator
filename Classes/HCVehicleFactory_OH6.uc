class HCVehicleFactory_OH6 extends ROVehicleFactory_OH6;

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

    /*
    if(ROMapInfo(WorldInfo.GetMapInfo()) != none && ROMapInfo(WorldInfo.GetMapInfo()).SouthernForce == SFOR_AusArmy)
    {
        EnemyVehicleClass = AusLoachClass;
    }
    else
    {
        EnemyVehicleClass = USLoachClass;
    }
    */
}

DefaultProperties
{
    Begin Object Name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'VH_VN_US_OH6.Mesh.US_OH6_Rig_Master'
        Materials[4]=MaterialInstanceConstant'HC_VH_TintedHelicopters.Materials.HC_VH_US_OH6_Mic'
        Translation=(X=0.0,Y=0.0,Z=0.0)
    End Object

    // Components.Remove(Sprite)

    Begin Object Name=CollisionCylinder
        CollisionHeight=+100.0
        CollisionRadius=+400.0
        Translation=(X=0.0,Y=0.0,Z=0.0)
    End Object

    VehicleClass=class'HCHeli_OH6_Content'
    EnemyVehicleClass=class'HCHeli_OH6_Allies_Content'
    DrawScale=1.0

    bTransportHeloFactory=true
}
