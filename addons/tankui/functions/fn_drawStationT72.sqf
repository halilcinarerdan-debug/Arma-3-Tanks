/*
 * T-72 nişancı istasyonu: Steel Beasts T-72M1 kılavuzu (s.25-28) düzenine sadık.
 *  - Durum lambaları 2x3, düz yuvarlak: yeşil/kırmızı/yeşil, kırmızı/kırmızı/mor (stab, ayna, hidrolik / TC, Delta-d, top yüklü)
 *  - Balistik lambaları üçgen: KE üstte, HE solda, HEAT altta; sağda manuel indeks anahtarı
 *  - Mermi seçici (KAPALI + 3 tip), mermi sayacı (maks 11), 3'lü şalter sırası, LRF ekranı, yay biçimli menzil çarkı
 * Etiketler araç diline göre (stringtable). Durumlar araçta (client) saklanır.
 */
params ["_display"];
private _veh = uiNamespace getVariable "SB_TankUI_vehicle";
#include "\z\tank33\addons\tankui\kit.sqf"

_veh setVariable ["SB_armed", true];       // panel etkileri (atış sapması) bu araçta artık devrede
private _vehName = getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName");
[_vehName + "  |  " + ("SCR_STATION" call _L), _roleLabel] call _header;

private _violet = [0.6, 0.35, 1, 1];
private _turretOf = { uiNamespace getVariable ["SB_TankUI_turret", [0]] };

// ---- Durum lambaları (kılavuz s.25) ----
[0.9, 2.6, "L_STAB" call _L,   _green,  {[_this] call SB_fnc_stabEffective}] call _lampRound;
[3.0, 2.6, "L_MIRROR" call _L, _red,    {(_this getVariable ["SB_hydr", false]) && {_this getVariable ["SB_mirror", false]} && {time - (_this getVariable ["SB_hydrOn", 0]) >= 120}}] call _lampRound;
[5.1, 2.6, "L_HYDR" call _L,   _green,  {_this getVariable ["SB_hydr", false]}] call _lampRound;
[0.9, 4.8, "L_TC" call _L,     _red,    {false}] call _lampRound;
[3.0, 4.8, "L_DELTA" call _L,  _red,    {_this getVariable ["SB_delta", false]}] call _lampRound;
[5.1, 4.8, "L_LOADED" call _L, _violet, {(_this ammo (_this currentWeaponTurret (uiNamespace getVariable ["SB_TankUI_turret", [0]]))) > 0}] call _lampRound;

// ---- Balistik: üçgen (üst KE, sol HE, alt HEAT) + manuel indeks anahtarı (kılavuz s.26) ----
[8.0, 1.8, 3.6, 0.5, "BALL" call _L, [0.62, 0.78, 0.58, 1]] call _txt;
{
    _x params ["_key", "_type", "_px", "_py", "_side"];
    [_px, _py, _key call _L, _amber, compile format [
        "private _o = _this getVariable ['SB_ballOvr', '']; private _t = if (_o != '') then {_o} else {[_this currentMagazineTurret (uiNamespace getVariable ['SB_TankUI_turret', [0]])] call SB_fnc_ammoClass}; _t == '%1'", _type
    ], "", _side] call _lampRound;
} forEach [
    ["AM_KE", "KE", 8.0, 3.2, "right"],
    ["AM_HE", "HE", 6.9, 5.0, "below"],
    ["AM_HEAT", "HEAT", 8.0, 6.8, "right"]
];
["knob", 10.2, 5.0, 1.5, 1.5, [1, 1, 1, 1], _dotTex, [0.5, 0.52, 0.48, 1]] call _spr;
[10.2, 6.1, 2.6, 0.5, "BALL_OVR" call _L, _ink, 2, 0.38] call _txt;
[10.2, 5.0, 1.6, 1.6, "ball"] call _inv;

// ---- Otomatik yükleyici AUT/MAN + ayna kilidi ----
[7.0, 9.0, "T_AUTO" call _L, "automan", {[0, 180] select (_this getVariable ["SB_manual", false])}] call _toggle;
[9.6, 9.0, "T_MIRROR" call _L, "mirror", {[180, 0] select (_this getVariable ["SB_mirror", false])}] call _toggle;

// ---- Mermi seçici + YÜKLE + mermi sayacı ----
[3.0, 12.3, [
    ["SEL_OFF" call _L, "sel_OFF", -75], ["AM_KE" call _L, "sel_KE", -25], ["AM_HEAT" call _L, "sel_HEAT", 25], ["AM_HE" call _L, "sel_HE", 75]
], compile "['', 'KE', 'HEAT', 'HE'] find (_this getVariable ['SB_selType', ''])"] call _rotary;
[3.0, 15.2, 5, 0.5, "SEL_TITLE" call _L] call _txt;

private _pl = [6.9, 14.4, "LOAD" call _L, "load", [0.2, 0.6, 0.25, 1]] call _push;
_pl setVariable ["sb_fn", { params ["_c", "_veh"]; _c ctrlSetText ((["LOAD", "LOADING"] select (_veh getVariable ["SB_loading", false])) call SB_fnc_lbl) }];
[_pl, _veh] call (_pl getVariable "sb_fn");

// mermi sayacı: seçili tipin adedi (KAPALI iken boş yuva sayısı), maks 11
[9.8, 13.3, 1.4, "gauge_ammo", 11, -115, 115, compile "
    private _t = uiNamespace getVariable ['SB_TankUI_turret', [0]];
    private _sel = _this getVariable ['SB_selType', ''];
    if (_sel != '') then { [_this, _t, _sel] call SB_fnc_ammoCount } else {
        22 - (([_this, _t, 'KE'] call SB_fnc_ammoCount) + ([_this, _t, 'HEAT'] call SB_fnc_ammoCount) + ([_this, _t, 'HE'] call SB_fnc_ammoCount))
    }
", [0.05, 0.05, 0.05, 1], [0.9, 0.9, 0.85, 1]] call _gauge;
[9.8, 15.2, 3.4, 0.5, "AMMO_COUNT" call _L, _ink, 2, 0.4] call _txt;

// ---- Sağ küme: LRF ekranı + lambalar ----
["display", 13.6, 2.6, 5.6, 2.7, [1, 1, 1, 1], _rectTex, [0.02, 0.02, 0.02, 1]] call _spr;
[11.575, 2.6, compile "_this getVariable ['SB_lrfText', '----']"] call _sevenSeg;
[18.0, 2.3, "L_LRF" call _L, _green, {_this getVariable ["SB_lrfOn", false]}] call _lampRound;
[19.6, 2.3, "L_READY" call _L, _red, {(_this getVariable ["SB_lrfOn", false]) && {time >= (_this getVariable ["SB_lrfReadyAt", 0])}}] call _lampRound;

// ---- Yay biçimli menzil çarkı + ateşe hazır lambası (kılavuz s.15) ----
[14.4, 8.4, 3.1, "gauge_arc", 30, -80, 80, compile "(_this getVariable ['SB_range', 0]) / 100", [1, 0.45, 0.1, 1], [0, 0, 0, 0], 0.98] call _gauge;
[14.4, 6.9, "", _red, {
    (_this ammo (_this currentWeaponTurret (uiNamespace getVariable ["SB_TankUI_turret", [0]]))) > 0
    && {(_this getVariable ["SB_lrfOn", false])} && {time >= (_this getVariable ["SB_lrfReadyAt", 0])}
}] call _lampRound;
[14.4, 9.6, 6, 0.5, "RANGE" call _L, _ink, 2, 0.42] call _txt;

[12.4, 11.6, "LASE" call _L, "lase"] call _push;
[15.4, 11.6, "RESET" call _L, "reset", [0.15, 0.15, 0.15, 1]] call _push;
[19.0, 11.3, "T_MODE" call _L, "mode", {[0, -40, 40] select (_this getVariable ["SB_lrfMode", 0])}] call _toggle;
[18.0, 9.9, 1.4, 0.5, "1200", _ink, 2, 0.4] call _txt;
[20.0, 9.9, 1.4, 0.5, "1800", _ink, 2, 0.4] call _txt;

// ---- Şalter sırası: Delta-d / stabilizasyon / hidrolik + LRF açma (kılavuz s.27-28) ----
[12.5, 14.5, "T_DELTA" call _L, "delta", {[180, 0] select (_this getVariable ["SB_delta", false])}] call _toggle;
[14.8, 14.5, "T_STAB" call _L, "stab", {[180, 0] select (_this getVariable ["SB_stab", false])}] call _toggle;
[17.1, 14.5, "T_HYDR" call _L, "hydr", {[180, 0] select (_this getVariable ["SB_hydr", false])}] call _toggle;
[19.4, 14.5, "T_LRFON" call _L, "lrfon", {[180, 0] select (_this getVariable ["SB_lrfOn", false])}] call _toggle;

call _finish;
