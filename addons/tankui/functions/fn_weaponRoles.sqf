/*
 * Taretteki ana top ve koaksiyel silahı bulur (mermi türlerinden):
 *  - ana top: KE/HE/HEAT sınıfı mermi kabul eden silah
 *  - koaksiyel: "shotBullet" mermi kabul eden, ana top olmayan silah (duman fırlatıcı vb. dışarıda kalır)
 * Sonuç araçta önbelleğe alınır (şalter her 0.5 sn'de sorar).
 * params: [araç, turretPath] -> [anaTop, koaks] (bulunamayan "")
 */
params ["_veh", "_turret"];
private _key = "SB_wRoles_" + str _turret;
private _cached = _veh getVariable [_key, []];
if (_cached isNotEqualTo []) exitWith { _cached };

private _main = "";
private _coax = "";
{
    private _w = _x;
    private _mags = compatibleMagazines _w;
    if ((_mags findIf {([_x] call SB_fnc_ammoClass) in ["KE", "HE", "HEAT"]}) >= 0) then {
        if (_main == "") then { _main = _w };
    } else {
        private _bullet = (_mags findIf {
            (toLower getText (configFile >> "CfgAmmo" >> (getText (configFile >> "CfgMagazines" >> _x >> "ammo")) >> "simulation")) == "shotbullet"
        }) >= 0;
        if (_bullet && {_coax == ""}) then { _coax = _w };
    };
} forEach (_veh weaponsTurret _turret);

private _result = [_main, _coax];
diag_log format ["[SB_TankUI] silah rolleri taret=%1 ana=%2 koaks=%3", _turret, _main, _coax];
_veh setVariable [_key, _result];
_result
