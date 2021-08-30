class HCBullet_M134Tracer extends M134BulletTracer;

simulated function ProcessBulletTouch(Actor Other, Vector HitLocation, Vector HitNormal, PrimitiveComponent OtherComp)
{
    if (HCHelicopterBaseProtection(Other) != None
        && HCPlayerController(InstigatorController) != None)
    {
        Destroy();
        HCPlayerController(InstigatorController).ReceiveLocalizedMessage(
            class'HCLocalMessageHelicopterBase', HCMSGHELOBASE_ProjectileDestroyed);
    }
    else
    {
        super.ProcessBulletTouch(Other, HitLocation, HitNormal, OtherComp);
    }
}

DefaultProperties
{
    // BallisticCoefficient=0.393 // 150.5gr M59 Ball (G1)
    BallisticCoefficient=0.20 // 150.5gr M59 Ball (G7)
    // Damage=150
    Damage=803
    MyDamageType=class'RODmgType_M134Bullet'
    Speed=42650 // 853 M/S
    MaxSpeed=60000 // 1200 m/s (allow for aircraft momentum)

    // RS2. Energy transfer function
    // M60, M14, M134
    // Sturt: Boosting this because as an aircraft fired round, this is almost always going to have gravity keeping energy up over distance
    VelocityDamageFalloffCurve=(Points=((InVal=291043600,OutVal=0.7), (InVal=1819022500,OutVal=0.25)))
    // VelocityDamageFalloffCurve=(Points=((InVal=0.4,OutVal=0.6), (InVal=1.0,OutVal=0.15)))

    DragFunction=RODF_G7
}
