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
class HCItem_PlaceableRocketHMG_Content extends ROItem_PlaceableHMG_Content;

DefaultProperties
{
    Begin Object Name=FirstPersonMesh
        DepthPriorityGroup=SDPG_Foreground
        SkeletalMesh=SkeletalMesh'WP_VN_VC_DshK_Portable.Mesh.WP_VN_VC_DshK_Portable'
        PhysicsAsset=PhysicsAsset'WP_VN_VC_DshK_HMG.Phy.VC_DshK_Physics'
        AnimSets(0)=AnimSet'WP_VN_VC_DshK_Portable.Animation.WP_DshKhands_Portable'
        AnimTreeTemplate=AnimTree'WP_VN_VC_DshK_Portable.Animation.DshKPortableAnimTree'
        Scale=1.0
        FOV=70
    End Object

    // Pickup staticmesh
    Begin Object Name=PickupMesh
        SkeletalMesh=SkeletalMesh'WP_VN_3rd_Master.Mesh.DshK_PickUp_3rd_Master'
        PhysicsAsset=PhysicsAsset'WP_VN_3rd_Master.Phy.DshK_Portable_3rd_Master_Physics'
        //AnimTreeTemplate=AnimTree'WP_VN_3rd_Master.AnimTree.Tripwire_Trap_3rd_Tree'
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

    AttachmentClass=class'ROGameContent.ROItemAttach_PlaceableHMG'

    // Arms
    ArmsAnimSet=AnimSet'WP_VN_VC_DshK_Portable.Animation.WP_DshKhands_Portable'

    HMGClass=class'HeloCombat.HCTurret_RocketDShK_HMG_Destroyable'
}
