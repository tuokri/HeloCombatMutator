class CustomMaterialContainer extends ActorComponent;

struct MaterialMapping
{
    var MeshComponent TargetComp;
    var int MaterialIndex;
    var string MaterialName;
};

var array<MaterialMapping> MaterialMappings;

simulated function ApplyMaterials()
{
    local MaterialMapping MM;
    local MaterialInstanceConstant MIC;
    local Material Mat;

    ForEach MaterialMappings(MM)
    {
        Mat = Material(DynamicLoadObject(MM.MaterialName, class'Material'));
        MIC = new(self) class'MaterialInstanceConstant';
        MIC.SetParent(Mat);
        `hclog("setting MIC: " $ MIC $ " on: " $ MM.TargetComp $ " index: " $ MM.MaterialIndex);
        MM.TargetComp.SetMaterial(MM.MaterialIndex, MIC);
    }
}

DefaultProperties
{
}
