/*
 * T-72B3 (2012) nişancı istasyonu. Parça şekilleri Steel Beasts T-72 görüntülerine göre 2B çizildi (kendi çizimimiz).
 * YALNIZCA işlevi olan parçalar var: her biri oyunda gerçek bir etki yapar veya gerçek veriyi gösterir.
 * Görüntüde görülen ama işlevi doğrulanamayan parçalar (СОСНА-У paneli, РС/ВС, АСЦ, РУЧ/ПОДДОН penceresi vb.) bilerek çizilmedi;
 * işlevleri doğrulandıkça eklenecek (docs/t72-station-notes.md).
 */
params ["_display"];
private _veh = uiNamespace getVariable "SB_TankUI_vehicle";
#include "\z\tank33\addons\tankui\kit.sqf"

_veh setVariable ["SB_armed", true, true];
[getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName") + "  |  " + ("SCR_STATION" call _L), _roleLabel] call _header;
private _violet = [0.6, 0.35, 1, 1];
private _yel = [1, 0.85, 0.15, 1];
private _hasAtgm = ([_veh, "atgm", 0] call SB_fnc_tProfile) > 0;

// ---- Lamba matrisi (2x3, tek plaka) ----
["label", 3.4, 3.5, 6.0, 3.4, [1, 1, 1, 1], _rectTex, [0.05, 0.06, 0.05, 1]] call _spr;
[1.5, 2.6, "L_STAB" call _L,   _green,  {[_this] call SB_fnc_stabEffective}] call _lampSmall;
[3.4, 2.6, "L_MIRROR" call _L, _red,    {(_this getVariable ["SB_hydr", false]) && {_this getVariable ["SB_mirror", false]} && {serverTime - (_this getVariable ["SB_hydrOn", 0]) >= 120}}] call _lampSmall;
[5.3, 2.6, "L_HYDR" call _L,   _green,  {_this getVariable ["SB_hydr", false]}] call _lampSmall;
[3.4, 4.3, "L_DELTA" call _L,  _red,    {_this getVariable ["SB_delta", false]}] call _lampSmall;
[5.3, 4.3, "L_LOADED" call _L, _violet, {(_this ammo (_this currentWeaponTurret (uiNamespace getVariable ["SB_TankUI_turret", [0]]))) > 0}] call _lampSmall;

// ---- МЕХ-Д / СТАБИЛ / ПРИВОД (siyah yuvarlak butonlar) ----
[1.3, 7.6, "T_DELTA" call _L, "delta", {_this getVariable ["SB_delta", false]}] call _pushBlack;
[3.5, 7.6, "T_STAB" call _L, "stab", {_this getVariable ["SB_stab", false]}] call _pushBlack;
[5.7, 7.6, "T_HYDR" call _L, "hydr", {_this getVariable ["SB_hydr", false]}] call _pushBlack;

// ---- Mermi seçici (О / Б / К + varsa ПТУР) + YÜKLE + sayaç ----
private _selPos = if (_hasAtgm) then {[
    ["О" call _L, "sel_HE", -75], ["Б" call _L, "sel_KE", -25], ["К" call _L, "sel_HEAT", 25], ["AM_ATGM" call _L, "sel_ATGM", 75]
]} else {[
    ["О", "sel_HE", -60], ["Б", "sel_KE", 0], ["К", "sel_HEAT", 60]
]};
[3.6, 12.1, _selPos, compile "['HE', 'KE', 'HEAT', 'ATGM'] find (_this getVariable ['SB_selType', ''])", 0.8] call _rotary;
private _pl = [7.2, 11.6, "LOAD" call _L, "load", [0.2, 0.6, 0.25, 1]] call _push;
_pl setVariable ["sb_fn", { params ["_c", "_veh"]; _c ctrlSetText ((["LOAD", "LOADING"] select ([_veh] call SB_fnc_isLoading)) call SB_fnc_lbl) }];
[_pl, _veh] call (_pl getVariable "sb_fn");
[7.2, 14.8, 0.95, "gauge_ammo", 11, -115, 115, compile "
    private _t = uiNamespace getVariable ['SB_TankUI_turret', [0]];
    private _sel = _this getVariable ['SB_selType', ''];
    if (_sel != '') then { [_this, _t, _sel] call SB_fnc_ammoCount } else {
        22 - (([_this, _t, 'KE'] call SB_fnc_ammoCount) + ([_this, _t, 'HEAT'] call SB_fnc_ammoCount) + ([_this, _t, 'HE'] call SB_fnc_ammoCount))
    }
", [0.05, 0.05, 0.05, 1], [0.9, 0.9, 0.85, 1]] call _gauge;

// ---- Menzil: ekran + Д (LRF) şalteri + hazır lambası + РУЧ/АВТ (yükleyici) şalteri ----
["display", 13.4, 3.4, 5.4, 2.4, [1, 1, 1, 1], _rectTex, [0.02, 0.02, 0.02, 1]] call _spr;
[11.4, 3.4, compile "[_this] call SB_fnc_rangeText", 4, 0.95] call _sevenSeg;
[10.2, 6.3, "", _yel, {_this getVariable ["SB_lrfOn", false]}] call _lampSmall;
[11.7, 6.4, "Д", "lrfon", {[180, 0] select (_this getVariable ["SB_lrfOn", false])}, 0.8] call _toggle;
[10.2, 8.4, "L_READY" call _L, _red, {(_this getVariable ["SB_lrfOn", false]) && {serverTime >= (_this getVariable ["SB_lrfReadyAt", 0])}}] call _lampSmall;
[10.2, 10.6, "", _green, {!(_this getVariable ["SB_manual", false])}] call _lampSmall;
[11.7, 10.7, "РУЧ / АВТ", "automan", {[0, 180] select (_this getVariable ["SB_manual", false])}, 0.8] call _toggle;
if (_hasAtgm) then { [10.2, 12.7, "L_ATGM" call _L, _green, {[_this] call SB_fnc_atgmReady}] call _lampSmall };

// ---- Menzil çarkı + lazer ----
[16.4, 12.4, 3.0, "gauge_arc", 30, -80, 80, compile "([_this] call SB_fnc_rangeValue) / 100", [1, 0.45, 0.1, 1], [0, 0, 0, 0], 0.98] call _gauge;
[16.4, 14.2, 6, 0.5, "RANGE" call _L, _ink, 2, 0.42] call _txt;
[15.6, 7.0, "LASE" call _L, "lase"] call _push;
[18.2, 7.0, "RESET" call _L, "reset", [0.15, 0.15, 0.15, 1]] call _push;

call _finish;
