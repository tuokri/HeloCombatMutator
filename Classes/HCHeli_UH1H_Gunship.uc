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
class HCHeli_UH1H_Gunship extends ROHeli_UH1H_Gunship
    abstract;

`define INCLUDE_CHANGE_SEAT(dummy)
`include(HeloCombat\Classes\HCHeli_Common.uci)
`undefine(INCLUDE_CHANGE_SEAT)

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
                SeatPositions=((bDriverVisible=true,bAllowFocus=false,PositionCameraTag=none,ViewFOV=0.0,bViewFromCameraTag=false,bDrawOverlays=false,
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
                VehicleBloodMICParameterName=Gore02,
                GunClass=class'HCHWeap_UH1H_RocketPods',
                GunSocket=(Launcher_L_Front,Launcher_R_Front),
                GunPivotPoints=(),
                TurretControls=(),
                FiringPositionIndex=0,
                TracerFrequency=5,
                WeaponTracerClass=(none, none),
                MuzzleFlashLightClass=(none, none), //(class'ROVehicleMGMuzzleFlashLight',class'ROVehicleMGMuzzleFlashLight'),
                bAlternatingBarrelIndices=true,
                )}

    Seats(1)={( CameraTag=None,
                CameraOffset=-420,
                SeatAnimBlendName=CopilotPositionNode,
                SeatPositions=(// Flying
                                (bDriverVisible=true,bCanFlyHelo=true,bAllowFocus=false,PositionCameraTag=none,ViewFOV=0.0,
                                PositionUpAnim=copilot_IdleToFlight,PositionIdleAnim=copilot_Flight_Idle,DriverIdleAnim=copilot_Flight_Idle,AlternateIdleAnim=copilot_Flight_Idle_AI,SeatProxyIndex=1,
                                LeftHandIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_CopilotCollective,DefaultEffectorRotationTargetName=IK_CopilotCollective),
                                RightHandIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_CopilotCyclic,DefaultEffectorRotationTargetName=IK_CopilotCyclic),
                                LeftFootIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_CopilotLPedal,DefaultEffectorRotationTargetName=IK_CopilotLPedal),
                                RightFootIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_CopilotRPedal,DefaultEffectorRotationTargetName=IK_CopilotRPedal),
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
                                    LeftHandIKInfo=(PinEnabled=true),
                                    RightHandIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_CPGRight,DefaultEffectorRotationTargetName=IK_CPGRight),
                                    LeftFootIKInfo=(PinEnabled=true),
                                    RightFootIKInfo=(PinEnabled=true),
                                    PositionFlinchAnims=(copilot_Sight_Flinch),
                                    PositionDeathAnims=(copilot_Sight_Death))
                                ),
                TurretVarPrefix="Copilot",
                bSeatVisible=true,
                SeatBone=copilot_Attach,
                DriverDamageMult=0.5,
                InitialPositionIndex=2,
                FiringPositionIndex=2,
                SeatRotation=(Pitch=0,Yaw=0,Roll=0),
                VehicleBloodMICParameterName=Gore02,
                GunClass=class'HCHWeap_UH1H_M21',
                GunSocket=(Minigun_L_Muzzle,Minigun_R_Muzzle),
                GunPivotPoints=(M21_Rot_Yaw, M21_Rot_Yaw),
                TurretControls=(M21_Rot_Yaw, M21_Rot_Pitch, M21_L_Rot_Yaw, M21_R_Rot_Yaw),
                DetachedTurretPivotSockets=(,, Minigun_L_Muzzle, Minigun_R_Muzzle),
                MuzzleFlashLightClass=(none, none), //(class'ROVehicleMGMuzzleFlashLight',class'ROVehicleMGMuzzleFlashLight'),
                bAlternatingBarrelIndices=true,
                TracerFrequency=15,
                WeaponTracerClass=(class'HCBullet_M134Tracer_UH1H',class'HCBullet_M134Tracer_UH1H'),
                )}

    Seats(2)={( GunClass=class'HCHWeap_UH1_Gunship_DoorMG_L',
                GunSocket=(MG_Barrel_L, MG_Barrel_L_02),
                GunPivotPoints=(MG_Pitch_L),
                TurretControls=(MGL_Rot_Yaw,MGL_Rot_Pitch),
                CameraTag=None,
                CameraOffset=-420,
                SeatAnimBlendName=CrewChiefPositionNode,
                SeatPositions=((bDriverVisible=true,bAllowFocus=true,PositionCameraTag=none,ViewFOV=0.0,
                                    bIsExterior=true, bIgnoreWeapon=true,bRotateGunOnCommand=true,
                                    PositionUpAnim=LGunner_Idle_pose,PositionIdleAnim=LGunner_Idle,DriverIdleAnim=LGunner_Idle,AlternateIdleAnim=LGunner_Idle_AI,SeatProxyIndex=2,
                                    LeftHandIKInfo=(PinEnabled=true),
                                    RightHandIKInfo=(PinEnabled=true),
                                    HipsIKInfo=(PinEnabled=true),
                                    LeftFootIKInfo=(PinEnabled=true),
                                    RightFootIKInfo=(PinEnabled=true),
                                    PositionFlinchAnims=(LGunner_Idle),
                                    PositionDeathAnims=(LGunner_Death),
                                    ChestIKInfo=(PinEnabled=true)),
                                // Above gun sights
                                (bDriverVisible=true,bAllowFocus=true,PositionCameraTag=MGL_Camera_High,ViewFOV=0.0,bCamRotationFollowSocket=true,bViewFromCameraTag=true,bUseDOF=true,
                                    bIsExterior=true,
                                    PositionUpAnim=LGunner_Ironsight_Idle_pose,PositionDownAnim=LGunner_Ironsight_Idle_pose,PositionIdleAnim=LGunner_Idle,bConstrainRotation=false,YawContraintIndex=0,PitchContraintIndex=1,DriverIdleAnim=LGunner_Ironsight_Idle,AlternateIdleAnim=LGunner_Ironsight_Idle_AI,SeatProxyIndex=2,
                                    LeftHandIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_DoorMGLLeftHand,DefaultEffectorRotationTargetName=IK_DoorMGLLeftHand),
                                    RightHandIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_DoorMGLRightHand,DefaultEffectorRotationTargetName=IK_DoorMGLRightHand),
                                    HipsIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_DoorMGLHips,DefaultEffectorRotationTargetName=IK_DoorMGLHips),
                                    LeftFootIKInfo=(PinEnabled=true),
                                    RightFootIKInfo=(PinEnabled=true),
                                    PositionFlinchAnims=(LGunner_Idle),
                                    PositionDeathAnims=(LGunner_Death),
                                    ChestIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_DoorMGLChest,DefaultEffectorRotationTargetName=IK_DoorMGLChest)),
                                // Gun sights
                                (bDriverVisible=true,bAllowFocus=true,PositionCameraTag=MGL_Camera,ViewFOV=0.0,bCamRotationFollowSocket=true,bViewFromCameraTag=true,bUseDOF=true,
                                    bIsExterior=true,
                                    PositionDownAnim=LGunner_Ironsight_Idle_pose,PositionIdleAnim=LGunner_Idle,bConstrainRotation=false,YawContraintIndex=0,PitchContraintIndex=1,DriverIdleAnim=LGunner_Ironsight_Idle,AlternateIdleAnim=LGunner_Ironsight_Idle_AI,SeatProxyIndex=2,
                                    LeftHandIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_DoorMGLLeftHand,DefaultEffectorRotationTargetName=IK_DoorMGLLeftHand),
                                    RightHandIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_DoorMGLRightHand,DefaultEffectorRotationTargetName=IK_DoorMGLRightHand),
                                    HipsIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_DoorMGLHips,DefaultEffectorRotationTargetName=IK_DoorMGLHips),
                                    LeftFootIKInfo=(PinEnabled=true),
                                    RightFootIKInfo=(PinEnabled=true),
                                    PositionFlinchAnims=(LGunner_Idle),
                                    PositionDeathAnims=(LGunner_Death),
                                    ChestIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_DoorMGLChest,DefaultEffectorRotationTargetName=IK_DoorMGLChest))),
                TurretVarPrefix="DoorMGLeft",
                bSeatVisible=true,
                SeatBone=L_Gunner_Attach,
                DriverDamageMult=1.0,
                InitialPositionIndex=1,
                FiringPositionIndex=2,
                SeatRotation=(Pitch=0,Yaw=0,Roll=0),
                WeaponRotation=(Pitch=0,Yaw=16384,Roll=0),
                VehicleBloodMICParameterName=Gore02,
                TracerFrequency=5,
                WeaponTracerClass=(class'HCBullet_M60DTracer',class'HCBullet_M60DTracer'),
                MuzzleFlashLightClass=(none, none), //(class'ROVehicleMGMuzzleFlashLight',class'ROVehicleMGMuzzleFlashLight'),
                bAlternatingBarrelIndices=true,
                )}

    Seats(3)={( GunClass=class'HCHWeap_UH1_Gunship_DoorMG_R',
                GunSocket=(MG_Barrel_R,MG_Barrel_R_02),
                GunPivotPoints=(MG_Pitch_R),
                TurretControls=(MGR_Rot_Yaw,MGR_Rot_Pitch),
                CameraTag=None,
                CameraOffset=-420,
                SeatAnimBlendName=DoorGunnerPositionNode,
                SeatPositions=((bDriverVisible=true,bAllowFocus=true,PositionCameraTag=none,ViewFOV=0.0,
                                    bIsExterior=true, bIgnoreWeapon=true,bRotateGunOnCommand=true,
                                    PositionUpAnim=RGunner_Idle_pose,PositionIdleAnim=RGunner_Idle,DriverIdleAnim=RGunner_Idle,AlternateIdleAnim=RGunner_Idle_AI,SeatProxyIndex=3,
                                    LeftHandIKInfo=(PinEnabled=true),
                                    RightHandIKInfo=(PinEnabled=true),
                                    HipsIKInfo=(PinEnabled=true),
                                    LeftFootIKInfo=(PinEnabled=true),
                                    RightFootIKInfo=(PinEnabled=true),
                                    PositionFlinchAnims=(RGunner_Idle),
                                    PositionDeathAnims=(RGunner_Death),
                                    ChestIKInfo=(PinEnabled=true)),
                                // Above gun sights
                                (bDriverVisible=true,bAllowFocus=true,PositionCameraTag=MGR_Camera_High,ViewFOV=0.0,bCamRotationFollowSocket=true,bViewFromCameraTag=true,bUseDOF=true,
                                    bIsExterior=true,
                                    PositionUpAnim=RGunner_Ironsight_Idle_pose,PositionDownAnim=RGunner_Ironsight_Idle_pose,PositionIdleAnim=RGunner_Idle,bConstrainRotation=false,YawContraintIndex=0,PitchContraintIndex=1,DriverIdleAnim=Rgunner_Ironsight_Idle,AlternateIdleAnim=Rgunner_Ironsight_Idle_AI,SeatProxyIndex=3,
                                    LeftHandIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_DoorMGRLeftHand,DefaultEffectorRotationTargetName=IK_DoorMGRLeftHand),
                                    RightHandIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_DoorMGRRightHand,DefaultEffectorRotationTargetName=IK_DoorMGRRightHand),
                                    HipsIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_DoorMGRHips,DefaultEffectorRotationTargetName=IK_DoorMGRHips),
                                    LeftFootIKInfo=(PinEnabled=true),
                                    RightFootIKInfo=(PinEnabled=true),
                                    PositionFlinchAnims=(RGunner_Idle),
                                    PositionDeathAnims=(RGunner_Death),
                                    ChestIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_DoorMGRChest,DefaultEffectorRotationTargetName=IK_DoorMGRChest)),
                                // Gun sights
                                (bDriverVisible=true,bAllowFocus=true,PositionCameraTag=MGR_Camera,ViewFOV=0.0,bCamRotationFollowSocket=true,bViewFromCameraTag=true,bUseDOF=true,
                                    bIsExterior=true,
                                    PositionDownAnim=RGunner_Ironsight_Idle_pose,PositionIdleAnim=RGunner_Idle,bConstrainRotation=false,YawContraintIndex=0,PitchContraintIndex=1,DriverIdleAnim=Rgunner_Ironsight_Idle,AlternateIdleAnim=Rgunner_Ironsight_Idle_AI,SeatProxyIndex=3,
                                    LeftHandIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_DoorMGRLeftHand,DefaultEffectorRotationTargetName=IK_DoorMGRLeftHand),
                                    RightHandIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_DoorMGRRightHand,DefaultEffectorRotationTargetName=IK_DoorMGRRightHand),
                                    HipsIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_DoorMGRHips,DefaultEffectorRotationTargetName=IK_DoorMGRHips),
                                    LeftFootIKInfo=(PinEnabled=true),
                                    RightFootIKInfo=(PinEnabled=true),
                                    PositionFlinchAnims=(RGunner_Idle),
                                    PositionDeathAnims=(RGunner_Death),
                                    ChestIKInfo=(IKEnabled=true,DefaultEffectorLocationTargetName=IK_DoorMGRChest,DefaultEffectorRotationTargetName=IK_DoorMGRChest))),
                TurretVarPrefix="DoorMGRight",
                bSeatVisible=true,
                SeatBone=R_Gunner_Attach,
                DriverDamageMult=1.0,
                InitialPositionIndex=1,
                FiringPositionIndex=2,
                SeatRotation=(Pitch=0,Yaw=0,Roll=0),
                WeaponRotation=(Pitch=0,Yaw=-16384,Roll=0),
                VehicleBloodMICParameterName=Gore02,
                TracerFrequency=5,
                WeaponTracerClass=(class'HCBullet_M60DTracer',class'HCBullet_M60DTracer'),
                MuzzleFlashLightClass=(none, none), //(class'ROVehicleMGMuzzleFlashLight',class'ROVehicleMGMuzzleFlashLight'),
                bAlternatingBarrelIndices=true,
                )}
}
