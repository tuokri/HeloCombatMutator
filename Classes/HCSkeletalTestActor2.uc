class HCSkeletalTestActor2 extends SkeletalMeshActor;

var CustomMaterialContainer CustomMaterialContainer;

event PreBeginPlay()
{
    super.PreBeginPlay();

    CustomMaterialContainer.ApplyMaterials();
}

DefaultProperties
{
    Begin Object Name=MyLightEnvironment
        bSynthesizeSHLight=True
        bIsCharacterLightEnvironment=True
        bDynamic=True
    End Object

    Begin Object Name=SkeletalMeshComponent0
        SkeletalMesh=SkeletalMesh'CHR_VN_AUS_Heads.Mesh.AUS_Head10_Mesh'
        // Can't set this here because we get an external reference error on compilation.
        // Materials(0)='VNTE-MaterialContainer.TestMat'
        // Materials(1)='VNTE-MaterialContainer.TestMat1'
        // Materials(2)='VNTE-MaterialContainer.TestMatasdasdasd'
        Materials.Empty
        LightEnvironment=MyLightEnvironment
        bCastDynamicShadow=True
        bAcceptsDynamicLights=True
        CastShadow=True
    End Object

    Begin Object Class=CustomMaterialContainer Name=CustomMaterialContainer0
        MaterialMappings(0)=(TargetComp=SkeletalMeshComponent0,MaterialIndex=0,MaterialName="VNTE-MaterialContainer.TestMat")
        // MaterialMappings(1)=(TargetComp=SkeletalMeshComponent0,MaterialIndex=1,MaterialName="VNTE-MaterialContainer.TestMat1")
        // MaterialMappings(2)=(TargetComp=SkeletalMeshComponent0,MaterialIndex=2,MaterialName="VNTE-MaterialContainer.TestMatasdasdasd")
    End Object
    CustomMaterialContainer=CustomMaterialContainer0
    Components.Add(CustomMaterialContainer0)

    bNoDelete=False
    LifeSpan=0
}
