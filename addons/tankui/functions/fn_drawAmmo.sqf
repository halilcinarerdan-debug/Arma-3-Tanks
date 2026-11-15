/* Mühimmat sekmesi: her satır = silah | mermi tipi | adet | [SEÇ] ; aktif mermi ">" ile işaretli */
params ["_display"];
private _veh = uiNamespace getVariable "SB_TankUI_vehicle";
private _list = [_veh] call SB_fnc_getAmmoList;
uiNamespace setVariable ["SB_TankUI_sig", str _list];

private _scr = ctrlPosition (_display displayCtrl 7402);
_scr params ["_sx", "_sy", "_sw", "_sh"];
private _x0 = _sx + _sw * 0.03;
private _y0 = _sy + _sh * 0.19;
private _rowH = _sh * 0.055;
private _font = _rowH * 0.7;
private _ctrls = [];
private _green = [0.55, 1, 0.55, 1];

private _mk = {
    params ["_class", "_x", "_y", "_w", "_text", ["_style", 0]];
    private _c = _display ctrlCreate [_class, -1];
    _c ctrlSetPosition [_x, _y, _w, _rowH * 0.9];
    _c ctrlSetText _text;
    _c ctrlSetFontHeight _font;
    _c ctrlCommit 0;
    _ctrls pushBack _c;
    _c
};

// Başlık satırı
["SB_RscText", _x0, _y0, _sw * 0.28, "SILAH"] call _mk;
["SB_RscText", _x0 + _sw * 0.30, _y0, _sw * 0.36, "MUHIMMAT"] call _mk;
["SB_RscText", _x0 + _sw * 0.66, _y0, _sw * 0.12, "ADET"] call _mk;

private _i = 0;
{
    _x params ["_turret", "_mag", "_name", "_count", "_isCurrent", "_wName"];
    if (_i < 11) then {
        private _y = _y0 + _rowH * (_i + 1);
        private _prefix = ["  ", "> "] select _isCurrent;
        ["SB_RscText", _x0, _y, _sw * 0.28, _wName] call _mk;
        private _nameCtrl = ["SB_RscText", _x0 + _sw * 0.30, _y, _sw * 0.36, _prefix + _name] call _mk;
        ["SB_RscText", _x0 + _sw * 0.66, _y, _sw * 0.12, str _count] call _mk;
        private _btn = ["SB_RscButton", _x0 + _sw * 0.80, _y, _sw * 0.15, "SEC"] call _mk;
        _btn setVariable ["sb_data", [_turret, _mag]];
        _btn ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            (_ctrl getVariable "sb_data") call SB_fnc_selectAmmo;
        }];
        if (_isCurrent) then { _nameCtrl ctrlSetTextColor [1, 0.85, 0.3, 1] };
    };
    _i = _i + 1;
} forEach _list;

if (_list isEqualTo []) then {
    ["SB_RscText", _x0, _y0 + _rowH * 1.5, _sw * 0.9, "Mühimmat bulunamadi."] call _mk;
};

uiNamespace setVariable ["SB_TankUI_ctrls", _ctrls];
