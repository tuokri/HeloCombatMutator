/*
 * Copyright (c) 2021-2024 Tuomo Kriikkula <tuokri@tuta.io>
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
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
