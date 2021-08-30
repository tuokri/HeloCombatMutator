class HCVehicleFactory_UH1H_Gunship extends HCVehicleFactory_AH1G;

DefaultProperties
{
    Begin Object Name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'VH_VN_AUS_Bushranger.Mesh.AUS_Bushranger_Rig_Master'
        Materials[0]=MaterialInstanceConstant'HC_VH_TintedHelicopters.Materials.HC_M_Bushranger'
        Materials[4]=MaterialInstanceConstant'HC_VH_TintedHelicopters.Materials.HC_M_Bushranger_Armament'
        Translation=(X=0.0,Y=0.0,Z=0.0)
    End Object

    DrawScale=1.0

    VehicleClass=class'HCHeli_UH1H_Gunship_Content'
    EnemyVehicleClass=class'HCHeli_UH1H_Gunship_Allies_Content'
}
