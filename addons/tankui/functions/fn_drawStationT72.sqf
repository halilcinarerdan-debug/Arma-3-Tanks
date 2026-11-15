/*
 * T-72 nişancı istasyonu (spec: docs/t72m1-gunner-station.md)
 * Sol: durum lambaları, balistik lambaları, mermi seçici, YÜKLE
 * Sağ: LRF/FCS (menzil, lazer, mod, sıfırla), şalter sırası
 * Not: tüm düğmeler SB_fnc_t72Action'a gider; durumlar araçta (client) saklanır.
 */
params ["_display"];
private _veh = uiNamespace getVariable "SB_TankUI_vehicle";
private _turret = uiNamespace getVariable ["SB_TankUI_turret", [0]];

(ctrlPosition (_display displayCtrl 7402)) params ["_sx", "_sy", "_sw", "_sh"];
private _x0 = _sx + _sw * 0.03;
private _xr = _x0 + _sw * 0.52;
private _y0 = _sy + _sh * 0.19;
private _rowH = _sh * 0.055;
private _font = _rowH * 0.62;
private _ctrls = [];

private _mk = {
    params ["_class", "_x", "_y", "_w", "_h", "_text"];
    private _c = _display ctrlCreate [_class, -1];
    _c ctrlSetPosition [_x, _y, _w, _h];
    _c ctrlSetText _text;
    _c ctrlSetFontHeight _font;
    _c ctrlCommit 0;
    _ctrls pushBack _c;
    _c
};

// Lamba: sb_code true dönerse sb_col renginde yanar
private _lamp = {
    params ["_x", "_y", "_label", "_col", "_code"];
    private _c = ["SB_RscTextC", _x, _y, _sw * 0.11, _rowH * 0.85, _label] call _mk;
    _c setVariable ["sb_col", _col];
    _c setVariable ["sb_code", _code];
    _c setVariable ["sb_fn", {
        params ["_c", "_veh"];
        private _on = _veh call (_c getVariable "sb_code");
        _c ctrlSetBackgroundColor (if (_on) then {_c getVariable "sb_col"} else {[0.07, 0.1, 0.07, 1]});
        _c ctrlSetTextColor (if (_on) then {[0, 0, 0, 1]} else {[0.55, 1, 0.55, 1]});
    }];
    [_c, _veh] call (_c getVariable "sb_fn");
    _c
};

// Düğme: tıklanınca t72Action'a _act gider; sb_state (opsiyonel) true ise vurgulu
private _btn = {
    params ["_x", "_y", "_w", "_text", "_act", ["_state", {false}], ["_labelCode", {""}]];
    private _c = ["SB_RscButton", _x, _y, _w, _rowH * 0.9, _text] call _mk;
    _c setVariable ["sb_act", _act];
    _c setVariable ["sb_state", _state];
    _c setVariable ["sb_text", _text];
    _c setVariable ["sb_labelCode", _labelCode];
    _c ctrlAddEventHandler ["ButtonClick", { [(_this select 0) getVariable "sb_act"] call SB_fnc_t72Action }];
    _c setVariable ["sb_fn", {
        params ["_c", "_veh"];
        _c ctrlSetBackgroundColor (if (_veh call (_c getVariable "sb_state")) then {[0.15, 0.4, 0.15, 1]} else {[0.05, 0.08, 0.05, 1]});
        private _lbl = _veh call (_c getVariable "sb_labelCode");
        if (_lbl != "") then { _c ctrlSetText _lbl };
    }];
    [_c, _veh] call (_c getVariable "sb_fn");
    _c
};

private _green = [0.2, 0.9, 0.3, 1];
private _amber = [1, 0.75, 0.2, 1];
private _red = [0.95, 0.25, 0.2, 1];
private _lw = _sw * 0.12;

// ---- Sol sütun ----
["SB_RscText", _x0, _y0, _sw * 0.45, _rowH * 0.9, "DURUM LAMBALARI"] call _mk;
[_x0,           _y0 + _rowH * 1, "STAB",  _green, {_this getVariable ["SB_stab", false]}] call _lamp;
[_x0 + _lw,     _y0 + _rowH * 1, "AYNA",  _green, {(_this getVariable ["SB_hydr", false]) && {time - (_this getVariable ["SB_hydrOn", 0]) >= 120}}] call _lamp;
[_x0 + _lw * 2, _y0 + _rowH * 1, "HIDR",  _green, {_this getVariable ["SB_hydr", false]}] call _lamp;
[_x0,           _y0 + _rowH * 2, "TC",    _amber, {false}] call _lamp;
[_x0 + _lw,     _y0 + _rowH * 2, "DELTA", _amber, {_this getVariable ["SB_delta", false]}] call _lamp;
[_x0 + _lw * 2, _y0 + _rowH * 2, "YUKLU", _red,   {(_this ammo (_this currentWeaponTurret (uiNamespace getVariable ["SB_TankUI_turret", [0]]))) > 0}] call _lamp;

["SB_RscText", _x0, _y0 + _rowH * 3.2, _sw * 0.45, _rowH * 0.9, "BALISTIK (INDEKSLI TIP)"] call _mk;
{
    _x params ["_t", "_i"];
    [_x0 + _lw * _i, _y0 + _rowH * 4.2, _t, _amber, compile format [
        "([_this currentMagazineTurret (uiNamespace getVariable ['SB_TankUI_turret', [0]])] call SB_fnc_ammoClass) == '%1'", _t
    ]] call _lamp;
} forEach [["KE", 0], ["HE", 1], ["HEAT", 2]];

["SB_RscText", _x0, _y0 + _rowH * 5.4, _sw * 0.45, _rowH * 0.9, "MERMI SECICI"] call _mk;
{
    private _t = _x;
    private _i = _forEachIndex;
    private _state = compile format ["(_this getVariable ['SB_selType', '']) == '%1'", _t];
    private _lblCode = compile format [
        "format ['%1 %%1', [_this, uiNamespace getVariable ['SB_TankUI_turret', [0]], '%1'] call SB_fnc_ammoCount]", _t
    ];
    [_x0 + _lw * _i, _y0 + _rowH * 6.4, _lw * 0.95, _t, "sel_" + _t, _state, _lblCode] call _btn;
} forEach ["KE", "HEAT", "HE"];
[_x0 + _lw * 3, _y0 + _rowH * 6.4, _lw * 0.95, "KAPALI", "sel_OFF", {(_this getVariable ["SB_selType", ""]) == ""}] call _btn;

[_x0, _y0 + _rowH * 7.6, _lw * 1.5, "YUKLE", "load"] call _btn;
private _st = ["SB_RscText", _x0 + _lw * 1.6, _y0 + _rowH * 7.6, _lw * 2.4, _rowH * 0.9, ""] call _mk;
_st setVariable ["sb_fn", {
    params ["_c", "_veh"];
    _c ctrlSetText (["YUKLEYICI: HAZIR", "YUKLEYICI: YUKLUYOR"] select (_veh getVariable ["SB_loading", false]));
}];
[_st, _veh] call (_st getVariable "sb_fn");

// ---- Sağ sütun: LRF / FCS ----
["SB_RscText", _xr, _y0, _sw * 0.4, _rowH * 0.9, "LRF / FCS"] call _mk;
private _lrf = ["SB_RscText", _xr, _y0 + _rowH * 1, _sw * 0.4, _rowH * 1.3, ""] call _mk;
_lrf ctrlSetFontHeight (_rowH * 1.1);
_lrf setVariable ["sb_fn", {
    params ["_c", "_veh"];
    _c ctrlSetText format ["LRF  %1", _veh getVariable ["SB_lrfText", "----"]];
}];
[_lrf, _veh] call (_lrf getVariable "sb_fn");

private _wheel = ["SB_RscText", _xr, _y0 + _rowH * 2.5, _sw * 0.4, _rowH * 0.9, ""] call _mk;
_wheel setVariable ["sb_fn", {
    params ["_c", "_veh"];
    private _r = _veh getVariable ["SB_range", 0];
    _c ctrlSetText format ["MENZIL CARKI  %1  (x100 m)", (round (_r / 10)) / 10];
}];
[_wheel, _veh] call (_wheel getVariable "sb_fn");

private _ready = ["SB_RscTextC", _xr, _y0 + _rowH * 3.5, _sw * 0.4, _rowH * 0.85, "HAZIR"] call _mk;
_ready setVariable ["sb_fn", {
    params ["_c", "_veh"];
    private _t = uiNamespace getVariable ["SB_TankUI_turret", [0]];
    private _ok = (_veh ammo (_veh currentWeaponTurret _t)) > 0 && {time >= (_veh getVariable ["SB_lrfReadyAt", 0])};
    _c ctrlSetBackgroundColor (if (_ok) then {[0.9, 0.2, 0.15, 1]} else {[0.07, 0.1, 0.07, 1]});
    _c ctrlSetTextColor (if (_ok) then {[0, 0, 0, 1]} else {[0.55, 1, 0.55, 1]});
}];
[_ready, _veh] call (_ready getVariable "sb_fn");

[_xr, _y0 + _rowH * 4.7, _sw * 0.19, "LAZER", "lase"] call _btn;
[_xr + _sw * 0.21, _y0 + _rowH * 4.7, _sw * 0.19, "MENZIL 0", "reset"] call _btn;
[_xr, _y0 + _rowH * 5.8, _sw * 0.4, "MOD", "mode", {false}, {
    format ["LRF MOD: %1", ["NORMAL", "1200", "1800"] select (_this getVariable ["SB_lrfMode", 0])]
}] call _btn;

["SB_RscText", _xr, _y0 + _rowH * 7, _sw * 0.4, _rowH * 0.9, "SALTERLER"] call _mk;
private _sw3 = _sw * 0.13;
[_xr,             _y0 + _rowH * 8, _sw3, "DELTA-D", "delta", {_this getVariable ["SB_delta", false]}] call _btn;
[_xr + _sw3 + 0.002, _y0 + _rowH * 8, _sw3, "STAB",  "stab",  {_this getVariable ["SB_stab", false]}] call _btn;
[_xr + (_sw3 + 0.002) * 2, _y0 + _rowH * 8, _sw3, "HIDROLIK", "hydr", {_this getVariable ["SB_hydr", false]}] call _btn;

uiNamespace setVariable ["SB_TankUI_ctrls", _ctrls];
