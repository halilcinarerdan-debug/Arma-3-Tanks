/*
 * Ana top seçili değilse (MG seçiliyse) ana topa geç. params: [araç, turretPath]
 */
params ["_veh", "_turret"];
([_veh, _turret] call SB_fnc_weaponRoles) params ["_main", "_coax"];
if (_coax != "" && {(_veh currentWeaponTurret _turret) isEqualTo _coax} && {_main != ""}) then {
    [_veh, _turret, _main, _main] call SB_fnc_selectWeapon;
};
