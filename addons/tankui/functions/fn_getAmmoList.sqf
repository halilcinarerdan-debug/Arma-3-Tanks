/*
 * params: [araç]
 * döner: [[turretPath, magClass, displayName, toplamMermi, aktifMi, silahAdı, silahSınıfı], ...]
 */
params ["_veh"];
private _result = [];
{
    _x params ["_mag", "_turret", "_count"];
    if (_count > 0) then {
        private _idx = _result findIf {(_x select 0) isEqualTo _turret && {(_x select 1) isEqualTo _mag}};
        if (_idx < 0) then {
            private _weapons = _veh weaponsTurret _turret;
            private _wName = "";
            private _wClass = "";
            {
                private _w = _x;
                private _muz = getArray (configFile >> "CfgWeapons" >> _w >> "muzzles");
                if (_muz isEqualTo []) then { _muz = ["this"] };
                {
                    private _m = if (_x == "this") then {_w} else {_x};
                    if (_wName == "" && {_mag in compatibleMagazines [_w, _m]}) then {
                        _wName = getText (configFile >> "CfgWeapons" >> _w >> "displayName");
                        _wClass = _w;
                    };
                } forEach _muz;
            } forEach _weapons;
            if (_wName == "" && {_weapons isNotEqualTo []}) then {
                _wName = getText (configFile >> "CfgWeapons" >> (_weapons select 0) >> "displayName");
            };
            _result pushBack [
                _turret, _mag,
                getText (configFile >> "CfgMagazines" >> _mag >> "displayName"),
                _count, false, _wName, _wClass
            ];
        } else {
            private _row = _result select _idx;
            _row set [3, (_row select 3) + _count];
        };
    };
} forEach (magazinesAllTurrets _veh);

{
    _x params ["_t", "_m", "", "", "", "", "_wc"];
    // aktif = o taretin AKTİF silahı bu satırın silahı VE yüklü mermi bu satırın mermisi
    _x set [4, ((_veh currentMagazineTurret _t) isEqualTo _m) && {(_veh currentWeaponTurret _t) isEqualTo _wc}];
} forEach _result;
_result
