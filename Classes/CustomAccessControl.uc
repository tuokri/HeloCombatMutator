class CustomAccessControl extends Object
    config(Mutator_AccessControl);

var config array<string> AllowedIDs;

static function bool CheckUniqueID(string UniqueID)
{
    local string Comparison;

    ForEach default.AllowedIDs(Comparison)
    {
        `log("Comparing ID = " $ UniqueID $ " to " $ Comparison);

        // ID matches, allow player in.
        if (UniqueID ~= Comparison)
        {
            return True;
        }
    }

    return False;
}
