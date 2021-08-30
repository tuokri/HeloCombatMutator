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
}
