class HCHWeap_UH1H_RocketPods_Allies extends HCHWeap_UH1H_RocketPods
    abstract;

DefaultProperties
{
    WeaponContentClass(0)="HeloCombat.HCHWeap_UH1H_RocketPods_Allies_Content"
    WeaponProjectiles(0)=class'HCProjectile_Mk40Rocket_UH1H'
    VehicleClass=class'HCHeli_UH1H_Gunship_Allies'
    MaxAmmoCount=64
}
