/*
 * Bir mermiyi kabul eden silahı ve namluyu bulur.
 * params: [araç, turretPath, magClass] -> [silahSınıfı, namluAdı] (bulunamazsa ["", ""])
 */
params ["_veh", "_turret", "_mag"];
private _weaponToUse = "";
private _muzzleToUse = "";
{
    private _weapon = _x;
    private _muzzles = getArray (configFile >> "CfgWeapons" >> _weapon >> "muzzles");
    {
        // "this" = silahın ana namlusu; namlu adı silah sınıfıdır
        private _muzzle = if (_x == "this") then {_weapon} else {_x};
        if (_muzzleToUse isEqualTo "" && {_mag in compatibleMagazines [_weapon, _muzzle]}) then {
            _weaponToUse = _weapon;
            _muzzleToUse = _muzzle;
        };
    } forEach _muzzles;
} forEach (_veh weaponsTurret _turret);
[_weaponToUse, _muzzleToUse]
