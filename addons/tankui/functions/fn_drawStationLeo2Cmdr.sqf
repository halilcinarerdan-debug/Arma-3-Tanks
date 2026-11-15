/*
 * Leopard 2 ailesi komutan istasyonu: mürettebat (isim + sağlık), MG / duman sayıları, arıza lambaları, kapak ve duman atışı.
 * T-72 komutan ekranının Leopard sürümü (etiketler araç diline göre).
 */
params ["_display"];
private _veh = uiNamespace getVariable "SB_TankUI_vehicle";
#include "\z\tank33\addons\tankui\kit.sqf"

[getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName") + "  |  " + ("SCR_STATION" call _L), _roleLabel] call _header;

{
    private _y = 2.8 + _forEachIndex * 1.7;
    ["label", 7.4, _y, 14.2, 1.35, [1, 1, 1, 1], _rectTex, [0.05, 0.06, 0.05, 1]] call _spr;
    private _t = [0.9, _y, 13, 0.7, "", _ink, 0, 0.5] call _txt;
    _t setVariable ["sb_role", _x];
    _t setVariable ["sb_fn", {
        params ["_c", "_veh"];
        private _role = _c getVariable "sb_role";
        private _entry = (fullCrew _veh) select {(toLower (_x select 1)) == _role};
        private _name = "CREW_EMPTY" call SB_fnc_lbl;
        private _hp = "";
        if (_entry isNotEqualTo []) then {
            private _unit = (_entry select 0) select 0;
            _name = name _unit;
            _hp = format ["   %1%2", round ((1 - damage _unit) * 100), "%"];
        };
        _c ctrlSetText ((("ROLE_" + _role) call SB_fnc_lbl) + ":  " + _name + _hp);
    }];
    [_t, _veh] call (_t getVariable "sb_fn");
} forEach ["driver", "gunner", "commander"];

{
    _x params ["_cx", "_key", "_code"];
    [_cx, 8.6, 5, 0.5, _key call _L, _ink, 2, 0.5] call _txt;
    ["display", _cx, 10.2, 4.6, 2.0, [1, 1, 1, 1], _rectTex, [0.02, 0.02, 0.02, 1]] call _spr;
    [_cx - 1.2, 10.2, _code, 3, 0.9] call _sevenSeg;
} forEach [
    [3.5, "W_COAX", compile "str ([_this, [0]] call SB_fnc_coaxCount)"],
    [9.0, "W_MG2", compile "str ([_this, [0, 0]] call SB_fnc_coaxCount)"],
    [14.5, "SMOKE", compile "private _n = 0; { if (((toLower (_x select 1)) find 'smoke') >= 0) then { _n = _n + (_x select 3) } } forEach ([_this] call SB_fnc_getAmmoList); str _n"]
];

[1.6, 13.4, "F_ENG" call _L, _red,  {([_this, "hitengine"] call SB_fnc_getHit) >= 0.3}] call _lampRound;
[4.2, 13.4, "F_LTR" call _L, _red,  {([_this, "hitltrack"] call SB_fnc_getHit) >= 0.3}] call _lampRound;
[6.8, 13.4, "F_RTR" call _L, _red,  {([_this, "hitrtrack"] call SB_fnc_getHit) >= 0.3}] call _lampRound;
[9.4, 13.4, "F_HULL" call _L, _red, {([_this, "hithull"] call SB_fnc_getHit) >= 0.3}] call _lampRound;

[16.0, 13.4, "T_HATCH" call _L, "hatch", compile "[180, 0] select (isTurnedOut player)"] call _toggle;
[19.3, 13.2, "SMOKE" call _L, "smoke", [0.45, 0.45, 0.45, 1]] call _push;

call _finish;
