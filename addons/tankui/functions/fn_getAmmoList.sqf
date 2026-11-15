/*
 * params: [araç]
 * döner: [[turretPath, magClass, displayName, toplamMermi, aktifMi, silahAdı], ...]
 */
params ["_veh"];
private _result = [];
{
    _x params ["_mag", "_turret", "_count"];
    if (_count > 0) then {
        private _idx = _result findIf {(_x select 0) isEqualTo _turret && {(_x select 1) isEqualTo _mag}};
        if (_idx < 0) then {
            private _weapons = _veh weaponsTurret _turret;
            private _wName = if (_weapons isEqualTo []) then {""} else {
                getText (configFile >> "CfgWeapons" >> (_weapons select 0) >> "displayName")
            };
            _result pushBack [
                _turret, _mag,
                getText (configFile >> "CfgMagazines" >> _mag >> "displayName"),
                _count, false, _wName
            ];
        } else {
            private _row = _result select _idx;
            _row set [3, (_row select 3) + _count];
        };
    };
} forEach (magazinesAllTurrets _veh);

{
    _x set [4, (_veh currentMagazineTurret (_x select 0)) isEqualTo (_x select 1)];
} forEach _result;
_result
