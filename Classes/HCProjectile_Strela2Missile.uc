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

// https://www.reddit.com/r/CombatFootage/comments/12ash8a/hamas_operatives_firing_strela2_manpads_at_an_iaf/
// https://en.wikipedia.org/wiki/9K32_Strela-2
// Heat seeking 9K32 missile for Strela-2 system.
class HCProjectile_Strela2Missile extends HCHeatSeekingProjectile;

DefaultProperties
{
    BallisticCoefficient=0.15

    FueledFlightTime=14
    LifeSpan=17
    RocketIgnitionTime=0.3
    SpreadStartDelay=0
    InitialAccelerationTime=2.0 // 2.3 // Actually 2.0, but tends to be lower in practice, when calculated each tick.
    GradualSpreadMultiplier=0

    Speed=1600 // 32 / m/s.
    MaxSpeed=21500 // 430 m/s.

    Damage=250 // TODO: MULTIPLY DAMAGE WHEN HITTING SUPPORT AIRCRAFT!?
    ImpactDamage=1000
    DamageRadius=800
    PenetrationDamageRadius=1000

    MyDamageType=class'HCDmgType_Strela2Missile'
    ImpactDamageType=class'HCDmgType_Strela2MissileImpact'
    GeneralDamageType=class'HCDmgType_Strela2MissileGeneral'

    ProjFlightTemplate=ParticleSystem'HC_FX.Emitter.FX_Strela2_Flight'
    ProjExplosionTemplate=ParticleSystem'HC_FX.Emitter.FX_Strela2_Explosion'

    EffectiveNavigationRatio=5

    AmbientSound=AkEvent'WW_CMD_AntiAir.Play_CMD_AntiAir_Launch'
    ExplosionSound=AkEvent'WW_CMD_AntiAir.Play_EXP_SAM_Explode'
}
