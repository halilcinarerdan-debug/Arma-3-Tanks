/*
 * Oyuncunun kendi koltuğundaki bir silahı seçer (wiki doğrulandı):
 *   unit selectWeapon [weapon, muzzle, firemode]   (araç silahları da desteklenir; argüman yerel olmalı)
 * Atış modu weaponState [vehicle, turretPath, weapon, muzzle] -> [weapon, muzzle, firemode, ...] ile alınır.
 * Etkisiz kalırsa 0.35 sn sonra eski tek argümanlı biçim (unit selectWeapon muzzleName) denenir.
 * params: [araç, turretPath, silah, namlu]
 */
params ["_veh", "_turret", "_weapon", "_muzzle"];
private _mode = (weaponState [_veh, _turret, _weapon, _muzzle]) param [2, ""];
player selectWeapon [_weapon, _muzzle, _mode];
[{
    params ["_veh", "_turret", "_weapon", "_muzzle"];
    if ((_veh currentWeaponTurret _turret) != _weapon) then { player selectWeapon _muzzle };
}, [_veh, _turret, _weapon, _muzzle], 0.35] call CBA_fnc_waitAndExecute;
