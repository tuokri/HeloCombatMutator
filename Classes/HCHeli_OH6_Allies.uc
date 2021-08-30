class HCHeli_OH6_Allies extends ROHeli_OH6
    abstract;

DefaultProperties
{
    Team=`ALLIES_TEAM_INDEX

    bCopilotMustBePilot=True
    bCopilotCanFly=True

    Ceiling=50000 // 1000m.
    MaxSpeed=4800

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
