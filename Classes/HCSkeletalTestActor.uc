class HCSkeletalTestActor extends SkeletalMeshActor;

DefaultProperties
{
    Begin Object Name=MyLightEnvironment
        bSynthesizeSHLight=True
        bIsCharacterLightEnvironment=True
        bDynamic=True
    End Object

    Begin Object Name=SkeletalMeshComponent0
        SkeletalMesh=SkeletalMesh'CHR_VN_AUS_Heads.Mesh.AUS_Head10_Mesh'
        LightEnvironment=MyLightEnvironment
        bCastDynamicShadow=True
        bAcceptsDynamicLights=True
        CastShadow=True
    End Object
    bNoDelete=False
    LifeSpan=0
}
