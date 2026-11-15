/*
 * Taretteki ana top ve koaksiyel silahı bulur (mermi türlerinden):
 *  - ana top: KE/HE/HEAT sınıfı mermi kabul eden silah
 *  - koaksiyel: "shotBullet" mermi kabul eden, ana top olmayan silah (duman fırlatıcı vb. dışarıda kalır)
 * params: [araç, turretPath] -> [anaTop, koaks] (bulunamayan "")
 */
params ["_veh", "_turret"];
private _main = "";
private _coax = "";
{
    private _w = _x;
    private _mags = compatibleMagazines _w;
    if ((_mags findIndex {([_x] call SB_fnc_ammoClass) in ["KE", "HE", "HEAT"]}) >= 0) then {
        if (_main == "") then { _main = _w };
    } else {
        private _bullet = (_mags findIndex {
            (toLower getText (configFile >> "CfgAmmo" >> (getText (configFile >> "CfgMagazines" >> _x >> "ammo")) >> "simulation")) == "shotbullet"
        }) >= 0;
        if (_bullet && {_coax == ""}) then { _coax = _w };
    };
} forEach (_veh weaponsTurret _turret);
[_main, _coax]
