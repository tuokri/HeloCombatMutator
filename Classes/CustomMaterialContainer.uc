class CustomMaterialContainer extends Object;

struct MaterialMapping
{
    var MeshComponent TargetComp;
    var int MaterialIndex;
    var string MaterialName;
};

var array<MaterialMapping> MaterialMappings;

simulated function ApplyMaterials()
{
    local MaterialMapping MP;
    local MaterialInstanceConstant MIC;
    local Material Mat;

    ForEach MaterialMappings(MP)
    {
        Mat = Material(DynamicLoadObject(MP.MaterialName, class'Material'));
        MIC = new(self) class'MaterialInstanceConstant';
        MIC.SetParent(Mat);
        MP.TargetComp.SetMaterial(MP.MaterialIndex, MIC);
    }
}

DefaultProperties
{
}
