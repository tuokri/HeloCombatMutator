class HCHWeap_AH1G_Turret extends ROHWeap_AH1G_Turret
    abstract;

DefaultProperties
{
    WeaponContentClass(0)="HeloCombat.HCHWeap_AH1G_Turret_Content"
    WeaponProjectiles(0)=class'HCProjectile_M129Grenade'
    WeaponProjectiles(ALTERNATE_FIREMODE)=class'HCBullet_M134_AH1G'
    VehicleClass=class'HCHeli_AH1G'
}
