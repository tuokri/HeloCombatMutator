/*
 * Copyright (c) 2021-2025 Tuomo Kriikkula <tuokri@tuta.io>
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

// Custom DShK that fires Mk40 rockets.
class HCWeap_DShK_HMG_Tripod extends ROWeap_DShK_HMG_Tripod;

DefaultProperties
{
    WeaponContentClass(0)="HeloCombat.HCWeap_DShK_HMG_Tripod_Content"

    FiringStatesArray(0)=WeaponFiring
    WeaponFireTypes(0)=EWFT_Projectile
    WeaponProjectiles(0)=class'HCProjectile_Mk40DShKRocket'
    FireInterval(0)=+0.45
    Spread(0)=0.0055
    // AmmoDisplayNames(0)="FFAR"

    InstantHitDamageTypes(0)=class'HCDmgType_Mk40DShKRocket'
    InstantHitDamageTypes(1)=class'HCDmgType_Mk40DShKRocket'

    PreFireTraceLength=1

    WeaponFireSnd.Empty
    WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Mk40.Play_WEP_Mk40_Fire_3P')

    bLoopingFireSnd(DEFAULT_FIREMODE)=false
    bLoopHighROFSounds(DEFAULT_FIREMODE)=false

    WeaponFireLoopEndSnd.Empty
    WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=None,FirstPersonCue=None)

    TracerClass=None
    TracerFrequency=0

    FireModeCanUseClientSideHitDetection[0]=False
    FireModeCanUseClientSideHitDetection[1]=False
    FireModeCanUseClientSideHitDetection[2]=False

    WeaponReloadSpeedModifier=1.5
}
