class HCHeli_AH1G_Content extends HCHeli_AH1G
    placeable;

DefaultProperties
{
    // ------------------------------- mesh --------------------------------------------------------------

    Begin Object Name=ROSVehicleMesh
        SkeletalMesh=SkeletalMesh'VH_VN_US_AH1G.Mesh.US_AH1G_Rig_Master'
        Materials[3]=MaterialInstanceConstant'HC_VH_TintedHelicopters.Materials.HC_VH_US_AH1G_Mic'
        Materials[4]=MaterialInstanceConstant'HC_VH_TintedHelicopters.Materials.HC_VH_US_AH1G_CANNON_Mic'
        LightingChannels=(Dynamic=TRUE,Unnamed_1=TRUE,bInitialized=TRUE)
        AnimTreeTemplate=AnimTree'VH_VN_US_AH1G.Anim.AT_VH_AH1G'
        PhysicsAsset=PhysicsAsset'VH_VN_US_AH1G.Phys.US_AH1G_Rig_Master_Physics'
        AnimSets.Add(AnimSet'VH_VN_US_AH1G.Anim.VH_AH1G_Anims')
    End Object

    PhysAssetNoTail=PhysicsAsset'VH_VN_US_AH1G.Phys.US_AH1G_Rig_NoTail_Master_Physics'

    // -------------------------------- Dead -----------------------------------------------------------

    DestroyedSkeletalMesh=SkeletalMesh'VH_VN_US_AH1G.Mesh.US_AH1G_Destroyed_Master'
    //DestroyedSkeletalMeshWithoutTurret=SkeletalMesh'VH_Sov_UniversalCarrier.Mesh.Sov_UC_Destroyed_Master'
    DestroyedPhysicsAsset=PhysicsAsset'VH_VN_US_AH1G.Phys.US_AH1G_Rig_Master_Physics'//PhysicsAsset'VH_VN_US_AH1G.Phys.US_AH1G_Destroyed_Physics'
    DestroyedMaterial=MaterialInstanceConstant'HC_VH_TintedHelicopters.Materials.HC_VH_US_AH1G_WRECK'
    //DestroyedMaterial2=MaterialInstanceConstant'VH_Sov_UniversalCarrier.Materials.M_DT28_3rd'
    //DestroyedMaterial3=MaterialInstanceConstant'VH_Sov_UniversalCarrier.Materials.M_DT28_Ammo_3rd'
    //DestroyedTurretClass=none

    DestroyedMainRotorGibClass=class'ROGameContent.AH1G_MainRotorGib'
    DestroyedTailRotorGibClass=class'ROGameContent.AH1G_TailRotorGib'
    DestroyedTailBoomGibClass=class'ROGameContent.AH1G_TailBoomGib'

    ExplosionSound=AkEvent'WW_VEH_Shared.Play_VEH_Helicopter_Explode_Close'

    // -------------------------------- Sounds -----------------------------------------------------------

    // Engine running sound
    Begin Object Class=AkComponent Name=EngineRotorSound
        BoneName=dummy
        bStopWhenOwnerDestroyed=true
    End Object
    EngineSound=EngineRotorSound
    Components.Add(EngineRotorSound)
    EngineSoundEvent=AkEvent'WW_VEH_UH1.Play_UH1_Run'

    // Engine startup sound
    Begin Object Class=AkComponent Name=StartEngineSound
        BoneName=dummy
        bStopWhenOwnerDestroyed=true
    End Object
    EngineStartSound=StartEngineSound
    EngineStartSoundEvent=AkEvent'WW_VEH_UH1.Play_UH1_Startup'

    // Engine shutdown sound
    /*Begin Object Class=AudioComponent Name=StopEngineSound
        SoundCue=SoundCue'AUD_VN_Vehicles_Heli_OH6.Movement.OH6_Movement_Engine_Start_Cue'
    End Object
    EngineStartSound=StopEngineSound*/

    // SAM Alert
    Begin Object Class=AkComponent Name=MissileWarningAudio
        BoneName=dummy
        bStopWhenOwnerDestroyed=true
    End Object
    MissileWarningSound=MissileWarningAudio
    MissileWarningSoundEvent=AkEvent'WW_VEH_UH1.Play_Helicopter_Missile_Warning'

    Begin Object Class=AkComponent name=MinigunSoundComponent
        BoneName=dummy
        bStopWhenOwnerDestroyed=true
    End Object
    MinigunAmbient=MinigunSoundComponent
    Components.Add(MinigunSoundComponent)
    MinigunAmbientEvent=AkEvent'WW_M134_Minigun.Play_MG_M134_Loop_3p'
    Begin Object Class=AkComponent name=MinigunStopSoundComponent
        BoneName=dummy
        bStopWhenOwnerDestroyed=true
    End Object
    MinigunStopSound=MinigunStopSoundComponent
    Components.Add(MinigunStopSoundComponent)
    MinigunStopSoundEvent=AkEvent'WW_M134_Minigun.Play_MG_M134_LoopEnd_3p'

    Begin Object Class=AkComponent name=CannonSoundComponent
        BoneName=dummy
        bStopWhenOwnerDestroyed=true
    End Object
    CannonAmbient=CannonSoundComponent
    Components.Add(CannonSoundComponent)
    CannonAmbientEvent=AkEvent'WW_WEP_M195.Play_WEP_M195_Loop_3P'

    Begin Object Class=AkComponent name=CannonStopSoundComponent
        BoneName=dummy
        bStopWhenOwnerDestroyed=true
    End Object
    CannonStopSound=CannonStopSoundComponent
    Components.Add(CannonStopSoundComponent)
    CannonStopSoundEvent=AkEvent'WW_WEP_M195.Play_WEP_M195_Tail_3P'

    // HUD
    DriverOverlayTexture=none
    HUDBodyTexture=Texture2D'VN_UI_Textures.HUD.Vehicles.ui_hud_helo_ah1g_body'
    HUDGearBoxTexture=Texture2D'ui_textures.HUD.Vehicles.ui_hud_tank_transmition_PZ'
    HUDMainRotorTexture=Texture2D'VN_UI_Textures.HUD.Vehicles.ui_hud_helo_ah1g_mainrotor'
    HUDTailRotorTexture=Texture2D'VN_UI_Textures.HUD.Vehicles.ui_hud_helo_ah1g_tailrotor'
    HUDLeftSkidTexture=Texture2D'VN_UI_Textures.HUD.Vehicles.ui_hud_helo_ah1g_leftskid'
    HUDRightSkidTexture=Texture2D'VN_UI_Textures.HUD.Vehicles.ui_hud_helo_ah1g_rightskid'
    HUDTailBoomTexture=Texture2D'VN_UI_Textures.HUD.Vehicles.ui_hud_helo_ah1g_tailboom'
    HUDAmmoTextures[0]=Texture2D'VN_UI_Textures.HUD.Vehicles.UI_HUD_Helo_Ammo_AH1G_Pilot'
    HUDAmmoTextures[1]=Texture2D'VN_UI_Textures.HUD.Vehicles.UI_HUD_Helo_Ammo_AH1G_Gunner'
    RPMGaugeTexture=Texture2D'VN_UI_Textures.HUD.Vehicles.UI_HUD_Helo_RPM_AH1'

    // Pilot
    SeatProxies(0)={(
        TunicMeshType=SkeletalMesh'CHR_VN_US_Army.Mesh.US_Tunic_Pilot_Mesh',
        HeadGearMeshType=SkeletalMesh'CHR_VN_US_Headgear.PilotMesh.US_Headgear_Pilot_Base_Up',
        HeadAndArmsMeshType=SkeletalMesh'CHR_VN_US_Heads.Mesh.US_Head3_Mesh',
        HeadphonesMeshType=none,
        HeadAndArmsMICTemplate=MaterialInstanceConstant'CHR_VN_US_Heads.Materials.M_US_Head_03_Pilot_INST',
        BodyMICTemplate=MaterialInstanceConstant'CHR_VN_US_Army.Materials.M_US_Tunic_Pilot_A_INST',
        HeadgearSocket=helmet,
        SeatIndex=0,
        PositionIndex=0)}

    // Copilot
    SeatProxies(1)={(
        TunicMeshType=SkeletalMesh'CHR_VN_US_Army.Mesh.US_Tunic_Pilot_Mesh',
        HeadGearMeshType=SkeletalMesh'CHR_VN_US_Headgear.PilotMesh.US_Headgear_Pilot_Base_Up',
        HeadAndArmsMeshType=SkeletalMesh'CHR_VN_US_Heads.Mesh.US_Head3_Mesh',
        HeadphonesMeshType=none,
        HeadAndArmsMICTemplate=MaterialInstanceConstant'CHR_VN_US_Heads.Materials.M_US_Head_01_Pilot_INST',
        BodyMICTemplate=MaterialInstanceConstant'CHR_VN_US_Army.Materials.M_US_Tunic_Pilot_A_INST',
        HeadgearSocket=helmet,
        SeatIndex=1,
        PositionIndex=0)}

    // Seat proxy animations
    SeatProxyAnimSet=AnimSet'VH_VN_US_AH1G.Anim.CHR_AH1G_anims'

    // -------------- Exterior attachments ------------------//

    Begin Object class=StaticMeshComponent name=ExtBodyAttachment0
        StaticMesh=StaticMesh'VH_VN_US_AH1G.Mesh.AH1G_Fuselage_SM'
        LightingChannels=(Dynamic=TRUE,Unnamed_1=FALSE,bInitialized=TRUE)
        LightEnvironment = MyLightEnvironment
        CastShadow=true
        DepthPriorityGroup=SDPG_Foreground
        HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
        bAcceptsDynamicDecals=FALSE
    End Object

    Begin Object class=StaticMeshComponent name=ExtBodyAttachment1
        StaticMesh=StaticMesh'VH_VN_US_AH1G.Mesh.AH1G_TailBoom_SM'
        LightingChannels=(Dynamic=TRUE,Unnamed_1=FALSE,bInitialized=TRUE)
        LightEnvironment = MyLightEnvironment
        CastShadow=true
        DepthPriorityGroup=SDPG_Foreground
        HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
        bAcceptsDynamicDecals=FALSE
    End Object

    MeshAttachments(0)={(AttachmentName=ExtBodyComponent,Component=ExtBodyAttachment0,AttachmentTargetName=Fuselage)}
    MeshAttachments(1)={(AttachmentName=ExtTailComponent,Component=ExtBodyAttachment1,AttachmentTargetName=Tail_Boom)}

    // ------------------ Rotor Blade Attachments ------------------ //

    Begin Object class=StaticMeshComponent name=MainRotorAttachment0
        StaticMesh=StaticMesh'VH_VN_US_AH1G.Mesh.MainBlade'
        LightingChannels=(Dynamic=TRUE,Unnamed_1=FALSE,bInitialized=TRUE)
        LightEnvironment = MyLightEnvironment
        CastShadow=true
        DepthPriorityGroup=SDPG_World
        //HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
        bAcceptsDynamicDecals=FALSE
    End Object

    Begin Object class=StaticMeshComponent name=MainRotorAttachment1
        StaticMesh=StaticMesh'VH_VN_US_AH1G.Mesh.MainBlade'
        LightingChannels=(Dynamic=TRUE,Unnamed_1=FALSE,bInitialized=TRUE)
        LightEnvironment = MyLightEnvironment
        CastShadow=true
        DepthPriorityGroup=SDPG_World
        //HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
        bAcceptsDynamicDecals=FALSE
    End Object

    Begin Object class=StaticMeshComponent name=TailRotorAttachment
        StaticMesh=StaticMesh'VH_VN_US_AH1G.Mesh.TailBlade'
        LightingChannels=(Dynamic=TRUE,Unnamed_1=FALSE,bInitialized=TRUE)
        LightEnvironment = MyLightEnvironment
        CastShadow=true
        DepthPriorityGroup=SDPG_World
        //HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
        bAcceptsDynamicDecals=FALSE
    End Object

    // Blurred rotor meshes

    Begin Object class=StaticMeshComponent name=MainRotorBlurAttachment0
        StaticMesh=StaticMesh'VH_VN_US_AH1G.Mesh.MainBlade_Blurred'
        LightingChannels=(Dynamic=TRUE,Unnamed_1=FALSE,bInitialized=TRUE)
        LightEnvironment = MyLightEnvironment
        CastShadow=true
        DepthPriorityGroup=SDPG_World
        HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
        bAcceptsDynamicDecals=FALSE
    End Object

    Begin Object class=StaticMeshComponent name=MainRotorBlurAttachment1
        StaticMesh=StaticMesh'VH_VN_US_AH1G.Mesh.MainBlade_Blurred'
        LightingChannels=(Dynamic=TRUE,Unnamed_1=FALSE,bInitialized=TRUE)
        LightEnvironment = MyLightEnvironment
        CastShadow=true
        DepthPriorityGroup=SDPG_World
        HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
        bAcceptsDynamicDecals=FALSE
    End Object

    Begin Object class=StaticMeshComponent name=TailRotorBlurAttachment
        StaticMesh=StaticMesh'VH_VN_US_AH1G.Mesh.TailBlade_Blurred'
        LightingChannels=(Dynamic=TRUE,Unnamed_1=FALSE,bInitialized=TRUE)
        LightEnvironment = MyLightEnvironment
        CastShadow=true
        DepthPriorityGroup=SDPG_World
        HiddenGame=true
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
        bAcceptsDynamicDecals=FALSE
    End Object

    Begin Object class=ParticleSystemComponent name=ParticleSystemComponent0
        Template=ParticleSystem'FX_VN_Helicopters.Emitter.FX_VN_M134_Tracer'
        bAutoActivate=false
    End Object
    MinigunTracerComponent=ParticleSystemComponent0

    Begin Object class=ParticleSystemComponent name=ParticleSystemComponent1
        Template=ParticleSystem'FX_VN_Helicopters.Emitter.FX_VN_M35_Tracer'
        bAutoActivate=false
    End Object
    CannonTracerComponent=ParticleSystemComponent1

    RotorMeshAttachments(0)=(AttachmentName=MainRotorComponent0,Component=MainRotorAttachment0,BlurredComponent=MainRotorBlurAttachment0,DestroyedMesh=StaticMesh'VH_VN_US_AH1G.Mesh.MainBlade_Stub01',AttachmentTargetName=Blade_01,bMainRotor=true, HitZoneIndex=MAINROTORBLADE1)
    RotorMeshAttachments(1)=(AttachmentName=MainRotorComponent1,Component=MainRotorAttachment1,BlurredComponent=MainRotorBlurAttachment1,DestroyedMesh=StaticMesh'VH_VN_US_AH1G.Mesh.MainBlade_Stub01',AttachmentTargetName=Blade_02,bMainRotor=true, HitZoneIndex=MAINROTORBLADE2)
    RotorMeshAttachments(2)=(AttachmentName=TailRotorComponent,Component=TailRotorAttachment,BlurredComponent=TailRotorBlurAttachment,DestroyedMesh=StaticMesh'VH_VN_US_AH1G.Mesh.TailRotor_stub',AttachmentTargetName=Tail_Rotor,bMainRotor=false, HitZoneIndex=TAILROTORBLADE1)

    // Gibs
    Begin Object name=TailBoomDestroyed
        StaticMesh=StaticMesh'VH_VN_US_AH1G.Mesh.TailBoom_Stub'
    End Object
}
