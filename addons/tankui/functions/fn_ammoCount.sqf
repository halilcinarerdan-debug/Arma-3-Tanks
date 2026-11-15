/* params: [araç, turretPath, tip("KE"|"HEAT"|"HE")] -> o taretteki o tipin toplam mermi sayısı */
params ["_veh", "_turret", "_type"];
private _n = 0;
{
    if ((_x select 0) isEqualTo _turret && {([_x select 1] call SB_fnc_ammoClass) == _type}) then {
        _n = _n + (_x select 3);
    };
} forEach ([_veh] call SB_fnc_getAmmoList);
_n
