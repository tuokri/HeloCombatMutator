class HCHWeap_UH1H_RocketPods extends ROHWeap_AH1G_RocketPods
    abstract;

DefaultProperties
{
    WeaponContentClass(0)="HeloCombat.HCHWeap_UH1H_RocketPods_Content"
    WeaponProjectiles(0)=class'HCProjectile_Mk40Rocket_UH1H'
    VehicleClass=class'HCHeli_UH1H_Gunship'
    MaxAmmoCount=64
}
