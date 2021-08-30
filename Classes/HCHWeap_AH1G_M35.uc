class HCHWeap_AH1G_M35 extends ROHWeap_AH1G_M35
    abstract;

DefaultProperties
{
    WeaponContentClass(0)="HeloCombat.HCHWeap_AH1G_M35_Content"
    WeaponProjectiles(0)=class'HCProjectile_Mk40Rocket'
    WeaponProjectiles(ALTERNATE_FIREMODE)=class'HCProjectile_M195Shell'
    VehicleClass=class'HCHeli_AH1G'
}
