/*
 * T-72 nişancı istasyonu (spec: docs/t72m1-gunner-station.md)
 * Tek başına duran ekipman: plaka yok, kadranlar dokuya pişirilmiş, LED/şalter/seçici/7 segment.
 * Etiketler: BPS = APFSDS (KE), OFS = HE-Frag, BKS = HEAT. Durumlar araçta (client) saklanır.
 */
params ["_display"];
private _veh = uiNamespace getVariable "SB_TankUI_vehicle";
#include "\sb\tankui\kit.sqf"

private _turretPath = { uiNamespace getVariable ["SB_TankUI_turret", [0]] };
private _vehName = getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName");
[_vehName + "  |  ISTASYON", _roleLabel] call _header;

// ---- Sol küme ----
[1.8, 2.5, "STAB",  _green, {_this getVariable ["SB_stab", false]}] call _lamp;
[1.8, 3.7, "AYNA",  _green, {(_this getVariable ["SB_hydr", false]) && {time - (_this getVariable ["SB_hydrOn", 0]) >= 120}}] call _lamp;
[1.8, 4.9, "HIDR",  _green, {_this getVariable ["SB_hydr", false]}] call _lamp;
[5.4, 2.5, "TC",    _amber, {false}] call _lamp;
[5.4, 3.7, "DELTA", _amber, {_this getVariable ["SB_delta", false]}] call _lamp;
[5.4, 4.9, "YUKLU", _red,   {(_this ammo (_this currentWeaponTurret (call _turretPath))) > 0}] call _lamp;

[1.8, 6.5, 3.4, 0.5, "BALISTIK", [0.62, 0.78, 0.58, 1]] call _txt;
{
    _x params ["_t", "_type", "_i"];
    [1.7 + 3.4 * _i, 7.5, _t, _amber, compile format [
        "([_this currentMagazineTurret (uiNamespace getVariable ['SB_TankUI_turret', [0]])] call SB_fnc_ammoClass) == '%1'", _type
    ], 3.1] call _lamp;
} forEach [["BPS", "KE", 0], ["OFS", "HE", 1], ["BKS", "HEAT", 2]];

[3.0, 11.4, [["KAPALI", "sel_OFF", -75], ["BPS", "sel_KE", -25], ["BKS", "sel_HEAT", 25], ["OFS", "sel_HE", 75]],
    compile "['', 'KE', 'HEAT', 'HE'] find (_this getVariable ['SB_selType', ''])"] call _rotary;
[3.0, 14.2, 4, 0.5, "MERMI SECICI"] call _txt;
private _pl = [7.2, 14.0, "YUKLE", "load", [0.2, 0.6, 0.25, 1]] call _push;
_pl setVariable ["sb_fn", { params ["_c", "_veh"]; _c ctrlSetText (["YUKLE", "YUKLUYOR..."] select (_veh getVariable ["SB_loading", false])) }];
[_pl, _veh] call (_pl getVariable "sb_fn");

// mermi sayacı: seçili tipin adedi (KAPALI iken boş yuva sayısı), maks 11
[9.4, 11.1, 1.5, "gauge_ammo", 11, -115, 115, compile "
    private _t = uiNamespace getVariable ['SB_TankUI_turret', [0]];
    private _sel = _this getVariable ['SB_selType', ''];
    if (_sel != '') then { [_this, _t, _sel] call SB_fnc_ammoCount } else {
        22 - (([_this, _t, 'KE'] call SB_fnc_ammoCount) + ([_this, _t, 'HEAT'] call SB_fnc_ammoCount) + ([_this, _t, 'HE'] call SB_fnc_ammoCount))
    }
", [0.05, 0.05, 0.05, 1], [0.9, 0.9, 0.85, 1]] call _gauge;
[9.4, 13.0, 3.4, 0.5, "MERMI SAYAC"] call _txt;


// ---- Sağ küme ----
["display", 13.5, 2.6, 5.6, 2.7, [1, 1, 1, 1], _rectTex, [0.02, 0.02, 0.02, 1]] call _spr;
[11.475, 2.6, compile "_this getVariable ['SB_lrfText', '----']"] call _sevenSeg;
[18.6, 2.6, "HAZIR", _red, {
    (_this ammo (_this currentWeaponTurret (uiNamespace getVariable ["SB_TankUI_turret", [0]]))) > 0 && {time >= (_this getVariable ["SB_lrfReadyAt", 0])}
}, 2.8] call _lamp;

// menzil çarkı (x100 m, 3000 m sınırı)
[14.4, 8.5, 3.0, "gauge_range", 30, -100, 100, compile "(_this getVariable ['SB_range', 0]) / 100", [1, 0.5, 0.12, 1], [0.06, 0.07, 0.06, 1]] call _gauge;
[14.4, 12.15, 5, 0.5, "MENZIL x100 m"] call _txt;

[18.8, 6.6, "LAZER", "lase"] call _push;
[18.8, 9.8, "MENZIL 0", "reset", [0.15, 0.15, 0.15, 1]] call _push;

[11.6, 14.0, "DELTA-D", "delta", {[180, 0] select (_this getVariable ["SB_delta", false])}] call _toggle;
[14.0, 14.0, "STAB", "stab", {[180, 0] select (_this getVariable ["SB_stab", false])}] call _toggle;
[16.4, 14.0, "HIDR", "hydr", {[180, 0] select (_this getVariable ["SB_hydr", false])}] call _toggle;
[19.0, 14.0, "LRF MOD", "mode", {[0, -40, 40] select (_this getVariable ["SB_lrfMode", 0])}] call _toggle;
[18.0, 12.7, 1.4, 0.5, "1200"] call _txt;
[20.0, 12.7, 1.4, 0.5, "1800"] call _txt;

call _finish;
