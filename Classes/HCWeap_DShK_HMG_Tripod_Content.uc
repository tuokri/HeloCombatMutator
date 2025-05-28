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
