/* Durum sekmesi: hasar çubukları (hitpoint) + hız/yakıt/motor. Değerler refresh ile canlı güncellenir. */
params ["_display"];
private _veh = uiNamespace getVariable "SB_TankUI_vehicle";

private _scr = ctrlPosition (_display displayCtrl 7402);
_scr params ["_sx", "_sy", "_sw", "_sh"];
private _x0 = _sx + _sw * 0.03;
private _y0 = _sy + _sh * 0.19;
private _rowH = _sh * 0.055;
private _font = _rowH * 0.7;
private _ctrls = [];

private _mk = {
    params ["_x", "_y", "_w", "_text"];
    private _c = _display ctrlCreate ["SB_RscText", -1];
    _c ctrlSetPosition [_x, _y, _w, _rowH * 0.9];
    _c ctrlSetText _text;
    _c ctrlSetFontHeight _font;
    _c ctrlCommit 0;
    _ctrls pushBack _c;
    _c
};

// Hasar (sol sütun)
[_x0, _y0, _sw * 0.4, "HASAR"] call _mk;
private _hpRows = [
    ["GOVDE", "hithull"], ["MOTOR", "hitengine"],
    ["SOL PALET", "hitltrack"], ["SAG PALET", "hitrtrack"],
    ["TARET", "hitturret"], ["TOP", "hitgun"], ["YAKIT DEPOSU", "hitfuel"]
];
private _i = 1;
{
    _x params ["_label", "_hp"];
    if (([_veh, _hp] call SB_fnc_getHit) >= 0) then {
        private _y = _y0 + _rowH * _i;
        [_x0, _y, _sw * 0.18, _label] call _mk;
        private _v = [_x0 + _sw * 0.19, _y, _sw * 0.33, ""] call _mk;
        _v setVariable ["sb_hp", _hp];
        _v setVariable ["sb_fn", {
            params ["_c", "_veh"];
            private _d = [_veh, _c getVariable "sb_hp"] call SB_fnc_getHit;
            _c ctrlSetText (([1 - _d, 16] call SB_fnc_bar) + format [" %1%2", round ((1 - _d) * 100), "%"]);
            private _col = [0.55, 1, 0.55, 1];
            if (_d >= 0.6) then { _col = [1, 0.25, 0.2, 1] } else { if (_d >= 0.2) then { _col = [1, 0.75, 0.2, 1] } };
            _c ctrlSetTextColor _col;
        }];
        [_v, _veh] call (_v getVariable "sb_fn");
        _i = _i + 1;
    };
} forEach _hpRows;

// Araç verisi (sağ sütun)
private _xr = _x0 + _sw * 0.58;
[_xr, _y0, _sw * 0.35, "ARAC"] call _mk;
private _info = [
    ["HIZ", {format ["%1 km/h", round (speed _this)]}],
    ["YAKIT", {format ["%1 %%", round (fuel _this * 100)]}],
    ["MOTOR", {["KAPALI", "ACIK"] select (isEngineOn _this)}],
    ["MURETTEBAT", {format ["%1 / %2", count crew _this, count fullCrew [_this, "", true]]}]
];
{
    _x params ["_label", "_code"];
    private _y = _y0 + _rowH * (_forEachIndex + 1);
    [_xr, _y, _sw * 0.15, _label] call _mk;
    private _v = [_xr + _sw * 0.16, _y, _sw * 0.2, ""] call _mk;
    _v setVariable ["sb_code", _code];
    _v setVariable ["sb_fn", {
        params ["_c", "_veh"];
        _c ctrlSetText (_veh call (_c getVariable "sb_code"));
    }];
    [_v, _veh] call (_v getVariable "sb_fn");
} forEach _info;

uiNamespace setVariable ["SB_TankUI_ctrls", _ctrls];
