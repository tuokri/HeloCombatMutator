class CustomMaterialContainer extends ActorComponent;

struct MaterialMapping
{
    var MeshComponent TargetComp;
    var int MaterialIndex;
    var string MaterialName;
};

var array<MaterialMapping> MaterialMappings;

// TODO: instead of calling DynamicLoadObject here, do the dynamic loading
// at startup for all custom materials, then just fetch the reference to the
// material here and apply it on the target mesh component.
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
