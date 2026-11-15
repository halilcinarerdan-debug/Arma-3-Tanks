/* DURUM ekranı (ekipman dili): taret/gövde şeması (hasara göre renk), bölge LED'leri, hız 7 segment, yakıt kadranı. */
params ["_display"];
private _veh = uiNamespace getVariable "SB_TankUI_vehicle";
#include "\sb\tankui\kit.sqf"

[getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName") + "  |  " + ("SCR_STATUS" call _L), _roleLabel] call _header;

// hasar -> renk (kalan sağlık yüksek: yeşil, orta: amber, düşük: kırmızı, hitpoint yok: gri)
private _dmgCol = {
    params ["_d"];
    if (_d < 0) exitWith {[0.3, 0.32, 0.3, 1]};
    private _h = 1 - _d;
    if (_h >= 0.8) exitWith {[0.5, 0.8, 0.45, 1]};
    if (_h >= 0.4) exitWith {[1, 0.72, 0.15, 1]};
    [0.95, 0.2, 0.15, 1]
};
uiNamespace setVariable ["SB_dmgCol", _dmgCol];

// ---- Şema: üstten görünüm, parçalar ayrı doku, hasara göre boyanır ----
["display", 5.0, 8.7, 9.8, 14.6, [1, 1, 1, 1], _rectTex, [0.03, 0.04, 0.03, 1]] call _spr;
{
    _x params ["_texName", "_hp"];
    private _p = [_texName, 5.0, 8.7, 8.667, 13.0, [0.5, 0.8, 0.45, 1], _rectTex, [0, 0, 0, 0]] call _spr;
    _p setVariable ["sb_hp", _hp];
    _p setVariable ["sb_fn", {
        params ["_c", "_veh"];
        _c ctrlSetTextColor ([[_veh, _c getVariable "sb_hp"] call SB_fnc_getHit] call (uiNamespace getVariable "SB_dmgCol"));
    }];
    [_p, _veh] call (_p getVariable "sb_fn");
} forEach [
    ["tank_trackL", "hitltrack"], ["tank_trackR", "hitrtrack"], ["tank_hull", "hithull"],
    ["tank_engine", "hitengine"], ["tank_turret", "hitturret"], ["tank_gun", "hitgun"]
];

// ---- Bölge listesi: etiket plakası + yüzde + LED ----
private _zones = [["Z_hull", "hithull"], ["Z_engine", "hitengine"], ["Z_ltrack", "hitltrack"], ["Z_rtrack", "hitrtrack"], ["Z_turret", "hitturret"], ["Z_gun", "hitgun"], ["Z_fuel", "hitfuel"]];
private _row = 0;
{
    _x params ["_name", "_hp"];
    if (([_veh, _hp] call SB_fnc_getHit) >= 0) then {
        private _y = 2.7 + _row * 1.35;
        ["label", 13.9, _y, 5.6, 1.1, [1, 1, 1, 1], _rectTex, [0.05, 0.06, 0.05, 1]] call _spr;
        [11.3, _y, 4.4, 0.6, _name call _L, _ink, 0] call _txt;
        private _val = [16.9, _y, 2.3, 0.6, "", _ink, 1] call _txt;
        private _lx = 19.9;
        ["ring", _lx, _y, 0.95, 0.95, [1, 1, 1, 1], _dotTex, [0.45, 0.46, 0.43, 1]] call _spr;
        private _lens = ["lens", _lx, _y, 0.62, 0.62, [0.5, 0.8, 0.45, 1], _dotTex, [0.5, 0.8, 0.45, 1]] call _spr;
        ["gloss", _lx - 0.1, _y - 0.12, 0.5, 0.5, [1, 1, 1, 1], _dotTex, [1, 1, 1, 0]] call _spr;
        _lens setVariable ["sb_hp", _hp];
        _lens setVariable ["sb_val", _val];
        _lens setVariable ["sb_fn", {
            params ["_c", "_veh"];
            private _d = [_veh, _c getVariable "sb_hp"] call SB_fnc_getHit;
            _c ctrlSetTextColor ([_d] call (uiNamespace getVariable "SB_dmgCol"));
            (_c getVariable "sb_val") ctrlSetText format ["%1%%", round ((1 - _d) * 100)];
        }];
        [_lens, _veh] call (_lens getVariable "sb_fn");
        _row = _row + 1;
    };
} forEach _zones;

// ---- Hız (7 segment) ----
["display", 16.2, 13.5, 5.0, 2.3, [1, 1, 1, 1], _rectTex, [0.02, 0.02, 0.02, 1]] call _spr;
[15.1, 13.5, compile "str round abs speed _this", 3, 0.85] call _sevenSeg;
[19.1, 13.5, 1.8, 0.5, "KMH" call _L, [0.62, 0.78, 0.58, 1]] call _txt;

// ---- Yakıt kadranı + motor lambası ----
[11.9, 14.0, 1.5, "gauge_fuel", 4, -60, 60, compile "(fuel _this) * 4", [0.05, 0.05, 0.05, 1], [0.9, 0.9, 0.85, 1]] call _gauge;
[11.9, 16.0, 3.0, 0.5, "FUEL" call _L, [0.62, 0.78, 0.58, 1]] call _txt;
[17.2, 16.0, "ENGINE" call _L, _green, {isEngineOn _this}, 3.8] call _lamp;

call _finish;
