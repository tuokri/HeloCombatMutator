class HCWeapAttach_9K32Strela2_MANPADS extends ROWeaponAttachmentRocket;

DefaultProperties
{
    ThirdPersonHandsAnim=RPG7_Handpose
    IKProfileName=Kar98

    // Weapon SkeletalMesh
    Begin Object Name=SkeletalMeshComponent0
        SkeletalMesh=SkeletalMesh'WP_VN_3rd_Master.Mesh.RPG7_3rd_Master'
        AnimSets(0)=AnimSet'WP_VN_3rd_Master.Anim.RPG7_3rd_Anim'
        PhysicsAsset=PhysicsAsset'WP_VN_3rd_Master.Phy_Bounds.RPG7_3rd_Bounds_Physics'
        CullDistance=5000
    End Object

    MuzzleFlashSocket=MuzzleFlashSocket
    MuzzleFlashPSCTemplate=ParticleSystem'FX_VN_Weapons.MuzzleFlashes.FX_VN_RPG_1stP_3rdP_frontblast'
    MuzzleFlashDuration=2.0
    MuzzleFlashLightClass=class'ROGame.RORifleMuzzleFlashLight'

    BackBlastSocket=BackBlastSocket
    BackBlastPSCTemplate=ParticleSystem'FX_VN_Weapons.MuzzleFlashes.FX_VN_RPG_3rdP_blueBackblast'
    BackBlastDuration=3.5
    BackBlastLightClass=none //class'ROGame.RORifleMuzzleFlashLight'

    WeaponClass=class'ROWeap_RPG7_RocketLauncher'

    bVisibleProj=true
    WeaponProjBone=Warhead

    // Shell eject FX
    ShellEjectSocket=ShellEjectSocket
    ShellEjectPSCTemplate=none
    bNoShellEjectOnFire=true

    // ROPawn weapon specific animations
    CHR_AnimSet=AnimSet'CHR_VN_Playeranim_Master.Weapons.CHR_RPG7'

    // Firing animations
    FireAnim=Shoot
    FireLastAnim=Shoot_Last
    IdleAnim=Idle
    IdleEmptyAnim=Idle_Empty
}
