class HCLocalMessageHelicopterBase extends ROLocalMessage
    abstract;

// TODO: Localized?
var string ProjectileDestroyedString;
var string AccessDeniedString;

enum EProjectileMessage
{
    HCMSGHELOBASE_ProjectileDestroyed,
    HCMSGHELOBASE_AccessDenied,
};

static function string GetString(
    optional int Switch,
    optional bool bPRI1HUD,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    switch (Switch)
    {
        case HCMSGHELOBASE_ProjectileDestroyed:
            return default.ProjectileDestroyedString;
        case HCMSGHELOBASE_AccessDenied:
            return default.AccessDeniedString;
        default:
            return "WHAT THE FUCK?";
    }
}

static function float GetLifeTime(int Switch)
{
    /*
    switch (Switch)
    {
        case HCMSGHELOBASE_ProjectileDestroyed:
            return default.LifeTime;
        case HCMSGHELOBASE_AccessDenied:
            return default.LifeTime;
        default:
            return default.LifeTime;
    }
    */

    return default.LifeTime;
}

static function float GetTextScaleBoost(int Switch)
{
    switch (Switch)
    {
        case HCMSGHELOBASE_AccessDenied:
            return 1.35;
        default:
            return 1.0;
    }
}

DefaultProperties
{
    ProjectileDestroyedString="HELICOPTER BASE PROTECTION, PROJECTILE DESTROYED"
    AccessDeniedString="ACCESS TO ENEMY HELICOPTER BASE DENIED"

    bLowerAlert=False
    bTickDown=False
    bRedAlert=True
    LifeTime=5.0
}
