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
class HCHeli_OH6_Allies extends ROHeli_OH6
    abstract;

`define INCLUDE_CHANGE_SEAT(dummy)
`define WITH_HELO_HUD_DEBUG(dummy)
`include(HeloCombat\Classes\HCHeli_Common.uci)
`undefine(INCLUDE_CHANGE_SEAT)
`undefine(WITH_HELO_HUD_DEBUG)

DefaultProperties
{
    Team=`ALLIES_TEAM_INDEX

    bCopilotMustBePilot=True
    bCopilotCanFly=True

    Ceiling=50000 // 1000m.
    MaxSpeed=4800

    WeaponPawnClass=class'HCHelicopterWeaponPawn'
    ClientWeaponPawnClass=class'HCTransportClientSideWeaponPawn'

    // Pilot
    Seats(0)={( CameraTag=None,
                CameraOffset=-420,
                SeatAnimBlendName=PilotPositionNode,
                SeatPositions=((bDriverVisible=true,bAllowFocus=false,PositionCameraTag=none,ViewFOV=0.0,bViewFromCameraTag=false,bDrawOverlays=true,
                                    PositionIdleAnim=Pilot_Idle,DriverIdleAnim=Pilot_Idle,AlternateIdleAnim=Pilot_Idle,SeatProxyIndex=0,
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
                VehicleBloodMICParameterName=BloodLeft,
                GunClass=class'HCHWeap_OH6_Minigun_Allies',
                GunSocket=(MuzzleFlashSocket),
                GunPivotPoints=(),
                TurretControls=(),
                FiringPositionIndex=0,
                TracerFrequency=15,
                WeaponTracerClass=(class'HCBullet_M134Tracer',class'HCBullet_M134Tracer'),
                MuzzleFlashLightClass=(none, none), //(class'ROVehicleMGMuzzleFlashLight',class'ROVehicleMGMuzzleFlashLight'),
                )}
}
