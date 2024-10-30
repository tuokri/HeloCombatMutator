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
class HCWeapAttach_MANPADS_9K32Strela2 extends ROWeaponAttachmentRocket;

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
        CachedMaxDrawDistance=5000
    End Object

    MuzzleFlashSocket=MuzzleFlashSocket
    MuzzleFlashPSCTemplate=ParticleSystem'FX_VN_Weapons.MuzzleFlashes.FX_VN_RPG_1stP_3rdP_frontblast'
    MuzzleFlashDuration=2.0
    MuzzleFlashLightClass=class'ROGame.RORifleMuzzleFlashLight'

    BackBlastSocket=BackBlastSocket
    BackBlastPSCTemplate=ParticleSystem'FX_VN_Weapons.MuzzleFlashes.FX_VN_RPG_3rdP_blueBackblast'
    BackBlastDuration=3.5
    BackBlastLightClass=none //class'ROGame.RORifleMuzzleFlashLight'

    WeaponClass=class'HCWeap_MANPADS_9K32Strela2'
´
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
