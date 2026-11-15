/*
 * GPS nişangâhı alt satırı (Leopard 2 / Strv 122 mantığı): "F196A"
 *  F = ateşe hazır (0 = hazır değil), 196 = menzil / 10 (metre), A = APFSDS, b = HE-T, d = makineli tüfek.
 * params: [araç] -> 5 karakterlik metin
 */
params ["_veh"];
private _t = uiNamespace getVariable ["SB_TankUI_turret", [0]];
private _w = _veh currentWeaponTurret _t;
([_veh, _t] call SB_fnc_weaponRoles) params ["_main", "_coax"];
private _ready = ["0", "F"] select (((_veh ammo _w) > 0) && {!([_veh] call SB_fnc_isLoading)});
private _r = [_veh] call SB_fnc_rangeValue;
private _rs = "---";
if (_r > 0) then {
    _rs = str ((round (_r / 10)) min 999);
    while {count _rs < 3} do { _rs = "0" + _rs };
};
private _a = if (_coax != "" && {_w isEqualTo _coax}) then {"d"} else {
    ["b", "A"] select (([_veh currentMagazineTurret _t] call SB_fnc_ammoClass) == "KE")
};
_ready + _rs + _a
