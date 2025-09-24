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
class HCHeli_AH1G extends ROHeli_AH1G
    abstract;

`define INCLUDE_CHANGE_SEAT(dummy)
`define WITH_HELO_HUD_DEBUG(dummy)
`include(HeloCombat\Classes\HCHeli_Common.uci)
`undefine(INCLUDE_CHANGE_SEAT)
`undefine(WITH_HELO_HUD_DEBUG)

DefaultProperties
{
    Team=`AXIS_TEAM_INDEX

    bCopilotMustBePilot=True
    bCopilotCanFly=True

    Ceiling=50000 // 1000m.
    MaxSpeed=4800

    WeaponPawnClass=class'HCHelicopterWeaponPawn'
    ClientWeaponPawnClass=class'HCTransportClientSideWeaponPawn'

    Seats(0)={( CameraTag=None,
                CameraOffset=-420,
                SeatAnimBlendName=PilotPositionNode,
                SeatPositions=((bDriverVisible=true,bAllowFocus=false,PositionCameraTag=none,ViewFOV=0.0,bViewFromCameraTag=false,
                                    PositionIdleAnim=Pilot_Idle,DriverIdleAnim=Pilot_Idle,AlternateIdleAnim=Pilot_Idle_AI,SeatProxyIndex=0,
                                    LeftHandIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_PilotCollective,DefaultEffectorRotationTargetName=IK_PilotCollective),
                                    RightHandIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_PilotCyclic,DefaultEffectorRotationTargetName=IK_PilotCyclic),
                                    LeftFootIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_PilotLPedal,DefaultEffectorRotationTargetName=IK_PilotLPedal),
                                    RightFootIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_PilotRPedal,DefaultEffectorRotationTargetName=IK_PilotRPedal),
                                    PositionFlinchAnims=(Pilot_Flinch),
                                    PositionDeathAnims=(Pilot_Death))
                                ),
                bSeatVisible=true,
                SeatBone=Pilot_Attach,
                DriverDamageMult=0.5,
                InitialPositionIndex=0,
                SeatRotation=(Pitch=0,Yaw=0,Roll=0),
                VehicleBloodMICParameterName=BloodPilot,
                GunClass=class'HCHWeap_AH1G_M35',   // class'VNHWeap_AH1G_RocketPods',
                GunSocket=(RocketPod_Left01Front,M195_Muzzle,RocketPod_Right01Front,M195_Muzzle),
                GunPivotPoints=(),
                TurretControls=(),
                FiringPositionIndex=0,
                TracerFrequency=5,
                WeaponTracerClass=(none, none/*class'M195TracerShell'*/),
                MuzzleFlashLightClass=(none, none), //(class'ROVehicleMGMuzzleFlashLight',class'ROVehicleMGMuzzleFlashLight'),
                bAlternatingBarrelIndices=true,
                bDualAltBarrelWeapons=true,
                )}

    Seats(1)={( CameraTag=None,
                CameraOffset=-420,
                SeatAnimBlendName=CopilotPositionNode,
                SeatPositions=(// Flying
                                (bDriverVisible=true,bCanFlyHelo=true,bAllowFocus=false,PositionCameraTag=none,ViewFOV=0.0,bViewFromCameraTag=false,
                                    PositionUpAnim=copilot_IdleToFlight,PositionIdleAnim=copilot_Flight_Idle,DriverIdleAnim=copilot_Flight_Idle,AlternateIdleAnim=copilot_Flight_Idle_AI,SeatProxyIndex=1,bIgnoreWeapon=true,bRotateGunOnCommand=true,
                                    LeftHandIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_CoPilotCollective,DefaultEffectorRotationTargetName=IK_CoPilotCollective),
                                    RightHandIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_CoPilotCyclic,DefaultEffectorRotationTargetName=IK_CoPilotCyclic),
                                    LeftFootIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_CoPilotLPedal,DefaultEffectorRotationTargetName=IK_CoPilotLPedal),
                                    RightFootIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_CoPilotRPedal,DefaultEffectorRotationTargetName=IK_CoPilotRPedal),
                                    PositionFlinchAnims=(copilot_Flight_Flinch),
                                    PositionDeathAnims=(copilot_Flight_Death)),
                                // Freelooking
                                (bDriverVisible=true,bAllowFocus=true,PositionCameraTag=none,ViewFOV=0.0,
                                    PositionUpAnim=copilot_SightToIdle,PositionDownAnim=copilot_FlightToIdle,PositionIdleAnim=copilot_Idle,DriverIdleAnim=copilot_Idle,AlternateIdleAnim=copilot_Idle_AI,SeatProxyIndex=1,bIgnoreWeapon=true,bRotateGunOnCommand=true,
                                    LeftHandIKInfo=(PinEnabled=true),
                                    RightHandIKInfo=(PinEnabled=true),
                                    LeftFootIKInfo=(PinEnabled=true),
                                    RightFootIKInfo=(PinEnabled=true),
                                    PositionFlinchAnims=(copilot_Flinch),
                                    PositionDeathAnims=(copilot_Death)),
                                // Gunsight
                                (bDriverVisible=true,bAllowFocus=false,PositionCameraTag=CPG_Camera,ViewFOV=70.0,bCamRotationFollowSocket=true,bViewFromCameraTag=true,bDrawOverlays=true,bUseDOF=true,
                                    PositionDownAnim=copilot_IdleToSight,PositionIdleAnim=copilot_Sight_Idle,DriverIdleAnim=copilot_Sight_Idle,AlternateIdleAnim=copilot_Sight_Idle_AI,SeatProxyIndex=1,
                                    LeftHandIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_CPGLeft,DefaultEffectorRotationTargetName=IK_CPGLeft),
                                    RightHandIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_CPGRight,DefaultEffectorRotationTargetName=IK_CPGRight),
                                    LeftFootIKInfo=(PinEnabled=true),
                                    RightFootIKInfo=(PinEnabled=true),
                                    ChestIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_CPGChest,DefaultEffectorRotationTargetName=IK_CPGChest),
                                    HipsIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_CPGHips,DefaultEffectorRotationTargetName=IK_CPGChest),
                                    PositionFlinchAnims=(copilot_Sight_Flinch),
                                    PositionDeathAnims=(copilot_Sight_Death))
                                ),
                TurretVarPrefix="Copilot",
                bSeatVisible=true,
                SeatBone=copilot_Attach,
                DriverDamageMult=0.5,
                InitialPositionIndex=1,
                FiringPositionIndex=2,
                SeatRotation=(Pitch=0,Yaw=0,Roll=0),
                VehicleBloodMICParameterName=BloodCoPilot,
                GunClass=class'HCHWeap_AH1G_Turret',
                GunSocket=(M129_Muzzle,M134_Muzzle),
                GunPivotPoints=(M28_Turret,M28_Turret),
                TurretControls=(M28_Rot_Yaw,M28_Rot_Pitch),
                TracerFrequency=15,
                WeaponTracerClass=(class'HCBullet_M134Tracer_AH1G',class'HCBullet_M134Tracer_AH1G'),
                MuzzleFlashLightClass=(none, none), //(class'ROVehicleMGMuzzleFlashLight',class'ROVehicleMGMuzzleFlashLight'),
                )}
}
