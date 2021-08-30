class HCProjectile_M195Shell extends M195Shell;

simulated function ProcessGrenadeTouch(Actor Other, Vector HitLocation, Vector HitNormal, PrimitiveComponent OtherComp)
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
        super.ProcessGrenadeTouch(Other, HitLocation, HitNormal, OtherComp);
    }
}
