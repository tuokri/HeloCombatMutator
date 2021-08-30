class HCWeap_DShK_HMG_Tripod_Content extends HCWeap_DShK_HMG_Tripod;

DefaultProperties
{
    ArmsAnimSet=AnimSet'WP_VN_VC_DshK_HMG.Animation.WP_DshKhands'

    // Weapon SkeletalMesh
    Begin Object Name=FirstPersonMesh
        SkeletalMesh=SkeletalMesh'WP_VN_VC_DshK_HMG.Mesh.VC_DshK'
        PhysicsAsset=PhysicsAsset'WP_VN_VC_DshK_HMG.Phy.VC_DshK_Physics'
        AnimSets(0)=AnimSet'WP_VN_VC_DshK_HMG.Animation.WP_DshKhands'
        AnimTreeTemplate=AnimTree'WP_VN_VC_DshK_HMG.Animation.DshKTurretAnimtree'
    End Object

    // Arms SkeletalMesh
    Begin Object Name=FirstPersonArmsMesh
        AnimSets(1)=AnimSet'WP_VN_VC_DshK_HMG.Animation.WP_DshKhands'
    End Object

    // Ammo belt SkeletalMesh
    Begin Object Name=AmmoBelt0
        SkeletalMesh=SkeletalMesh'WP_VN_VC_DshK_HMG.Mesh.VC_DshK_Belt'
        PhysicsAsset=PhysicsAsset'WP_VN_VC_DshK_HMG.Phy.VC_DShK_Bullets_Physics'
        AnimSets.Add(AnimSet'WP_VN_VC_DshK_HMG.Animation.WP_DshKhands')
        DepthPriorityGroup=SDPG_Foreground
        bOnlyOwnerSee=true
        MaxAmmoShown=18
    End Object
    AmmoBeltMesh=AmmoBelt0

    AttachmentClass=class'HeloCombat.HCWeapAttach_DShK_HMG_Tripod'
}
