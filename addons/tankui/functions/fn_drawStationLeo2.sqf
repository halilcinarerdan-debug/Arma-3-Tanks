/*
 * Leopard 2 / Strv 122 nişancı istasyonu. Düzen, Steel Beasts Strv 122 kılavuzundaki gerçek panellere (yalnızca referans) uyar,
 * çizimler ve metinler bize ait:
 *  - GPS alt satırı "F196A" (hazır / menzil / mermi), kontrol ünitesi LED sırası (Ber, Eld, KSP, Stab)
 *  - Ateş kontrol modu paneli: STAB TILL (normal) / OBSERVATION (acil) / TORN FRÅN (manuel)
 *  - Mermi: SLPILPRJ 95 (APFSDS) / SLSGR 95 (HE-T) / KSP (makineli tüfek) + YÜKLE; kalan sayılar
 *  - Balistik bilgisayar: Avstånd AUTOM/MAN, elle menzil girişi, savaş nişanı BS 1100, SS 1500, LRF
 * Durumlar istemcide tutulur; etkiler (stab/hidrolik/taret kilidi) T-72 ile ortaktır.
 */
params ["_display"];
private _veh = uiNamespace getVariable "SB_TankUI_vehicle";
#include "\z\tank33\addons\tankui\kit.sqf"

_veh setVariable ["SB_armed", true, true];
private _vehName = getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName");
[_vehName + "  |  " + ("SCR_STATION" call _L), _roleLabel] call _header;
private _dim = [0.62, 0.78, 0.58, 1];

// ---- GPS alt satırı ----
["display", 4.9, 2.6, 7.6, 2.7, [1, 1, 1, 1], _rectTex, [0.02, 0.02, 0.02, 1]] call _spr;
[2.2, 2.6, compile "[_this] call SB_fnc_gpsText", 5, 1] call _sevenSeg;
[4.9, 4.4, 7, 0.5, "GPS_T" call _L, _dim, 2, 0.4] call _txt;

// ---- Kontrol ünitesi LED sırası ----
[11.2, 2.6, "LED_BER" call _L, _green, {
    (_this ammo (_this currentWeaponTurret (uiNamespace getVariable ["SB_TankUI_turret", [0]]))) > 0
}] call _lampRound;
[13.5, 2.6, "LED_ELD" call _L, _red, {
    (_this ammo (_this currentWeaponTurret (uiNamespace getVariable ["SB_TankUI_turret", [0]]))) > 0
    && {serverTime >= (_this getVariable ["SB_lrfReadyAt", 0])} && {!([_this] call SB_fnc_isLoading)}
}] call _lampRound;
[15.8, 2.6, "LED_KSP" call _L, _amber, {
    private _t = uiNamespace getVariable ["SB_TankUI_turret", [0]];
    (_this currentWeaponTurret _t) isEqualTo (([_this, _t] call SB_fnc_weaponRoles) select 1)
}] call _lampRound;
[18.1, 2.6, "LED_STAB" call _L, _green, {[_this] call SB_fnc_stabEffective}] call _lampRound;

// ---- Ateş kontrol modu paneli ----
[0.9, 5.1, 8, 0.5, "FC_TITLE" call _L, _dim, 0, 0.45] call _txt;
{
    _x params ["_key", "_act", "_y", "_idx"];
    ["label", 4.4, _y, 7.4, 1.15, [1, 1, 1, 1], _rectTex, [0.05, 0.06, 0.05, 1]] call _spr;
    [1.3, _y, "", _green, compile format [
        "private _m = if !(_this getVariable ['SB_hydr', false]) then {2} else {[1, 0] select (_this getVariable ['SB_stab', false])}; _m == %1", _idx
    ]] call _lampRound;
    [2.4, _y, 6.5, 0.55, _key call _L, _ink, 0, 0.45] call _txt;
    [4.4, _y, 7.4, 1.15, _act] call _inv;
} forEach [["FC_NORMAL", "fc_normal", 6.3, 0], ["FC_EMERG", "fc_emerg", 7.7, 1], ["FC_MANUAL", "fc_manual", 9.1, 2]];

// ---- Mermi / silah seçimi (kalan sayılarla) ----
[10.6, 5.1, 7, 0.5, "SEL_TITLE" call _L, _dim, 0, 0.45] call _txt;
{
    _x params ["_key", "_act", "_y", "_type", "_digits"];
    ["label", 15.2, _y, 8.8, 1.15, [1, 1, 1, 1], _rectTex, [0.05, 0.06, 0.05, 1]] call _spr;
    [10.9, _y, "", _amber, compile format [
        "private _t = uiNamespace getVariable ['SB_TankUI_turret', [0]]; private _w = _this currentWeaponTurret _t; private _coax = ([_this, _t] call SB_fnc_weaponRoles) select 1; private _msel = (_coax != '') && {_w isEqualTo _coax}; if (%1 == 'MG') then {_msel} else {!_msel && {private _s = _this getVariable ['SB_selType', '']; if (%1 == 'HE') then {_s in ['HE', 'HEAT']} else {_s == %1}}}", str _type
    ]] call _lampRound;
    [12.0, _y, 5, 0.55, _key call _L, _ink, 0, 0.42] call _txt;
    ["display", 17.9, _y, 3.0, 1.0, [1, 1, 1, 1], _rectTex, [0.02, 0.02, 0.02, 1]] call _spr;
    [[17.53, 16.79] select (_digits == 4), _y, compile format [
        "private _t = uiNamespace getVariable ['SB_TankUI_turret', [0]]; str (switch (%1) do { case 'KE': {[_this, _t, 'KE'] call SB_fnc_ammoCount}; case 'HE': {([_this, _t, 'HE'] call SB_fnc_ammoCount) + ([_this, _t, 'HEAT'] call SB_fnc_ammoCount)}; default {[_this, _t] call SB_fnc_coaxCount} })", str _type
    ], _digits, 0.55] call _sevenSeg;
    [14.2, _y, 7.4, 1.15, _act] call _inv;
} forEach [["AM_APFSDS", "am_KE", 6.3, "KE", 2], ["AM_HET", "am_HE", 7.7, "HE", 2], ["W_COAX", "weapon", 9.1, "MG", 4]];

// ---- Satır A: yükle, lazer, savaş nişanı ----
private _pl = [2.2, 10.8, "LOAD" call _L, "load", [0.2, 0.6, 0.25, 1]] call _push;
_pl setVariable ["sb_fn", { params ["_c", "_veh"]; _c ctrlSetText ((["LOAD", "LOADING"] select ([_veh] call SB_fnc_isLoading)) call SB_fnc_lbl) }];
[_pl, _veh] call (_pl getVariable "sb_fn");
[5.4, 10.8, "LASE" call _L, "lase"] call _push;
[8.6, 10.8, "RESET" call _L, "reset", [0.15, 0.15, 0.15, 1]] call _push;
[11.8, 10.8, "P_SS1500" call _L, "bs_1500", [0.45, 0.45, 0.45, 1]] call _push;
[15.0, 10.8, "P_BS" call _L, "bs_1100", [0.45, 0.45, 0.45, 1]] call _push;
[18.4, 11.0, "T_LRFON" call _L, "lrfon", {[180, 0] select (_this getVariable ["SB_lrfOn", false])}] call _toggle;

// ---- Satır B: balistik bilgisayar (Avstånd AUTOM/MAN, elle menzil) ----
[2.2, 14.2, "T_RMODE" call _L, "rngmode", {[0, 180] select (_this getVariable ["SB_rngMan", false])}] call _toggle;
[5.6, 14.0, "P_RDN" call _L, "rng_dn", [0.45, 0.45, 0.45, 1]] call _push;
[8.8, 14.0, "P_RUP" call _L, "rng_up", [0.45, 0.45, 0.45, 1]] call _push;
["display", 14.4, 14.2, 5.6, 1.9, [1, 1, 1, 1], _rectTex, [0.02, 0.02, 0.02, 1]] call _spr;
[12.4, 14.2, compile "[_this] call SB_fnc_rangeText", 4, 0.8] call _sevenSeg;
[18.0, 14.2, 3, 0.5, "AVST_T" call _L, _dim, 2, 0.38] call _txt;

call _finish;
