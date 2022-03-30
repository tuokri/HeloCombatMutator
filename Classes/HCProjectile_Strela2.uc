class HCProjectile_Strela2 extends HCHeatSeekingProjectile;

DefaultProperties
{
    FueledFlightTime=14
    LifeSpan=17
    RocketIgnitionTime=0.11
    SpreadStartDelay=0
    InitialAccelerationTime=1.0

    Speed=10750
    MaxSpeed=21500 // 430 m/s.

    Damage=250
    ImpactDamage=1000
    DamageRadius=800
    PenetrationDamageRadius=1000

    ProjFlightTemplate=ParticleSystem'HC_FX.Emitter.FX_Strela2_Flight'
    ProjExplosionTemplate=ParticleSystem'HC_FX.Emitter.FX_Strela2_Explosion'

    // AmbientSound=AkEvent'WW_CMD_AntiAir.Play_CMD_AntiAir_Launch'
    // ExplosionSound=AkEvent'WW_CMD_AntiAir.Play_EXP_SAM_Explode'
}
