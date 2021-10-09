class HCWeap_9K32Strela2_MANPADS_Content extends HCWeap_9K32Strela2_MANPADS;

DefaultProperties
{
    // Arms.
    ArmsAnimSet=AnimSet'WP_VN_VC_RPG7.Animation.VC_RPG7hands'

    // Weapon SkeletalMesh.
    Begin Object Name=FirstPersonMesh
        DepthPriorityGroup=SDPG_Foreground
        SkeletalMesh=SkeletalMesh'WP_VN_VC_RPG7.Mesh.VC_RPG7'
        PhysicsAsset=PhysicsAsset'WP_VN_VC_RPG7.Phys.VC_RPG7_Physics'
        AnimSets(0)=AnimSet'WP_VN_VC_RPG7.Animation.VC_RPG7hands'
        AnimTreeTemplate=AnimTree'WP_VN_VC_RPG7.Animation.VC_RPG7_Tree'
        Scale=1.0
        FOV=70
    End Object

    // Pickup staticmesh.
    Begin Object Name=PickupMesh
        SkeletalMesh=SkeletalMesh'WP_VN_3rd_Master.Mesh.RPG7_3rd_Master'
        PhysicsAsset=PhysicsAsset'WP_VN_3rd_Master.Phy.RPG7_3rd_Master_Physics'
        CollideActors=true
        BlockActors=true
        BlockZeroExtent=true
        BlockNonZeroExtent=true//false
        BlockRigidBody=true
        bHasPhysicsAssetInstance=false
        bUpdateKinematicBonesFromAnimation=false
        PhysicsWeight=1.0
        RBChannel=RBCC_GameplayPhysics
        RBCollideWithChannels=(Default=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE)
        bSkipAllUpdateWhenPhysicsAsleep=TRUE
        bSyncActorLocationToRootRigidBody=true
    End Object

    AttachmentClass=class'HCWeapAttach_9K32Strela2_MANPADS'
}
