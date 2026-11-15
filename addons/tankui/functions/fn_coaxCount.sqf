/* Koaksiyel silahın kalan toplam mermisi. params: [araç, turretPath] -> sayı */
params ["_veh", "_turret"];
private _coax = ([_veh, _turret] call SB_fnc_weaponRoles) select 1;
if (_coax == "") exitWith {0};
private _n = 0;
{
    if ((_x select 0) isEqualTo _turret && {(_x select 6) isEqualTo _coax}) then { _n = _n + (_x select 3) };
} forEach ([_veh] call SB_fnc_getAmmoList);
_n
