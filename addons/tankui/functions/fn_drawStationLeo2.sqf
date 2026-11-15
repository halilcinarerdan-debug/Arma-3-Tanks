/*
 * Leopard 2 ailesi nişancı istasyonu (Strv 122 / Leo 2A5 mantığı; Steel Beasts Strv 122 kılavuzu yalnızca referans).
 *  - Ateş kontrol modu (3 konum): NORMAL = hidrolik + stabilizasyon, ACİL/OBSERVATION = hidrolik, stabilizasyonsuz,
 *    MANUEL = güç yok (taret kilidi CBA ayarına bağlı). Mevcut etkiler (SB_hydr / SB_stab) aynen kullanılır.
 *  - Mermi: APFSDS-T ve HE-T seçimi + YÜKLE (insan yükleyici: süre CBA ayarı). Menzil: LRF + savaş nişanı (BS 1100) / SS 1500.
 *  - Top / MG şalteri, hazır / ateş lambaları, kalan mermi sayaçları.
 * Etiketler araç diline göre; durumlar istemci tarafında tutulur.
 */
params ["_display"];
private _veh = uiNamespace getVariable "SB_TankUI_vehicle";
#include "\z\tank33\addons\tankui\kit.sqf"

_veh setVariable ["SB_armed", true];
private _vehName = getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName");
[_vehName + "  |  " + ("SCR_STATION" call _L), _roleLabel] call _header;
private _dim = [0.62, 0.78, 0.58, 1];

// ---- Durum lambaları ----
[1.3, 2.6, "LED_BER" call _L, _green, {
    (_this ammo (_this currentWeaponTurret (uiNamespace getVariable ["SB_TankUI_turret", [0]]))) > 0
}] call _lampRound;
[4.0, 2.6, "LED_ELD" call _L, _red, {
    (_this ammo (_this currentWeaponTurret (uiNamespace getVariable ["SB_TankUI_turret", [0]]))) > 0
    && {time >= (_this getVariable ["SB_lrfReadyAt", 0])} && {!([_this] call SB_fnc_isLoading)}
}] call _lampRound;
[6.7, 2.6, "LED_KSP" call _L, _amber, {
    private _t = uiNamespace getVariable ["SB_TankUI_turret", [0]];
    (_this currentWeaponTurret _t) isEqualTo (([_this, _t] call SB_fnc_weaponRoles) select 1)
}] call _lampRound;
[9.4, 2.6, "LED_STAB" call _L, _green, {[_this] call SB_fnc_stabEffective}] call _lampRound;

// ---- Ateş kontrol modu (üç konum) ----
[0.9, 5.2, 8, 0.5, "FC_TITLE" call _L, _dim, 0, 0.45] call _txt;
{
    _x params ["_key", "_act", "_y", "_idx"];
    [1.3, _y, "", _green, compile format [
        "private _m = if !(_this getVariable ['SB_hydr', false]) then {2} else {[1, 0] select (_this getVariable ['SB_stab', false])}; _m == %1", _idx
    ]] call _lampRound;
    [2.4, _y, 6.5, 0.55, _key call _L, _ink, 0, 0.45] call _txt;
    [4.0, _y, 7, 1.3, _act] call _inv;
} forEach [["FC_NORMAL", "fc_normal", 6.6, 0], ["FC_EMERG", "fc_emerg", 8.2, 1], ["FC_MANUAL", "fc_manual", 9.8, 2]];

// ---- Mermi seçimi + YÜKLE + kalan sayı ----
[10.6, 5.2, 7, 0.5, "SEL_TITLE" call _L, _dim, 0, 0.45] call _txt;
{
    _x params ["_key", "_act", "_y", "_type"];
    [10.9, _y, "", _amber, compile format [
        "private _s = _this getVariable ['SB_selType', '']; if (%1 == 'HE') then {_s in ['HE', 'HEAT']} else {_s == %1}", str _type
    ]] call _lampRound;
    [12.0, _y, 5, 0.55, _key call _L, _ink, 0, 0.42] call _txt;
    ["display", 18.7, _y, 3.0, 1.5, [1, 1, 1, 1], _rectTex, [0.02, 0.02, 0.02, 1]] call _spr;
    [17.8, _y, compile format [
        "private _t = uiNamespace getVariable ['SB_TankUI_turret', [0]]; str (if (%1 == 'KE') then {[_this, _t, 'KE'] call SB_fnc_ammoCount} else {([_this, _t, 'HE'] call SB_fnc_ammoCount) + ([_this, _t, 'HEAT'] call SB_fnc_ammoCount)})", str _type
    ], 2, 0.6] call _sevenSeg;
    [14.8, _y, 7, 1.3, _act] call _inv;
} forEach [["AM_APFSDS", "am_KE", 6.6, "KE"], ["AM_HET", "am_HE", 8.2, "HE"]];

private _pl = [14.2, 10.0, "LOAD" call _L, "load", [0.2, 0.6, 0.25, 1]] call _push;
_pl setVariable ["sb_fn", { params ["_c", "_veh"]; _c ctrlSetText ((["LOAD", "LOADING"] select ([_veh] call SB_fnc_isLoading)) call SB_fnc_lbl) }];
[_pl, _veh] call (_pl getVariable "sb_fn");

// ---- LRF ekranı ----
["display", 14.6, 2.6, 5.6, 2.7, [1, 1, 1, 1], _rectTex, [0.02, 0.02, 0.02, 1]] call _spr;
[12.575, 2.6, compile "[_this] call SB_fnc_rangeText"] call _sevenSeg;

// ---- Alt sıra: top/MG, savaş nişanı, LRF ----
[2.2, 12.8, "T_KANKSP" call _L, "weapon", {
    private _t = uiNamespace getVariable ["SB_TankUI_turret", [0]];
    [0, 180] select ((_this currentWeaponTurret _t) isEqualTo (([_this, _t] call SB_fnc_weaponRoles) select 1))
}] call _toggle;
[5.6, 12.6, "P_BS" call _L, "bs_1100", [0.45, 0.45, 0.45, 1]] call _push;
[8.8, 12.6, "P_SS1500" call _L, "bs_1500", [0.45, 0.45, 0.45, 1]] call _push;
[12.2, 12.6, "LASE" call _L, "lase"] call _push;
[15.4, 12.6, "RESET" call _L, "reset", [0.15, 0.15, 0.15, 1]] call _push;
[18.8, 12.8, "T_LRFON" call _L, "lrfon", {[180, 0] select (_this getVariable ["SB_lrfOn", false])}] call _toggle;
[19.2, 2.6, "L_LRF" call _L, _green, {_this getVariable ["SB_lrfOn", false]}] call _lampRound;

// ---- Kalan mermi sayaçları: ana top toplam + MG ----
[2.2, 15.5, 3.5, 0.5, "W_MAIN" call _L, _ink, 2, 0.42] call _txt;
["display", 5.6, 15.5, 3.4, 1.5, [1, 1, 1, 1], _rectTex, [0.02, 0.02, 0.02, 1]] call _spr;
[4.7, 15.5, compile "private _t = uiNamespace getVariable ['SB_TankUI_turret', [0]]; str (([_this, _t, 'KE'] call SB_fnc_ammoCount) + ([_this, _t, 'HE'] call SB_fnc_ammoCount) + ([_this, _t, 'HEAT'] call SB_fnc_ammoCount))", 2, 0.6] call _sevenSeg;
[11.0, 15.5, 3.5, 0.5, "W_COAX" call _L, _ink, 2, 0.42] call _txt;
["display", 15.3, 15.5, 5.0, 1.5, [1, 1, 1, 1], _rectTex, [0.02, 0.02, 0.02, 1]] call _spr;
[13.1, 15.5, compile "str ([_this, uiNamespace getVariable ['SB_TankUI_turret', [0]]] call SB_fnc_coaxCount)", 4, 0.6] call _sevenSeg;

call _finish;
