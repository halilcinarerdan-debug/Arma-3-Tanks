/* MUHIMMAT ekranı (ekipman dili): silah plakası, mermi tipi plakası, 7 segment adet, aktif LED, SEC düğmesi. */
params ["_display"];
private _veh = uiNamespace getVariable "SB_TankUI_vehicle";
private _list = [_veh] call SB_fnc_getAmmoList;
uiNamespace setVariable ["SB_TankUI_sig", str _list];
#include "\z\tank33\addons\tankui\kit.sqf"

[getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName") + "  |  " + ("SCR_AMMO" call _L), _roleLabel] call _header;

private _dim = [0.62, 0.78, 0.58, 1];
[2.4, 1.9, 4.8, 0.5, "COL_WEAPON" call _L, _dim] call _txt;
[7.5, 1.9, 4.9, 0.5, "COL_AMMO" call _L, _dim] call _txt;
[12.4, 1.9, 4.5, 0.5, "COL_COUNT" call _L, _dim] call _txt;

private _names = createHashMapFromArray [["KE", "AM_KE_FULL" call _L], ["HEAT", "AM_HEAT_FULL" call _L], ["HE", "AM_HE_FULL" call _L]];

{
    _x params ["_turret", "_mag", "_name", "_count", "_isCurrent", "_wName"];
    if (_forEachIndex < 6) then {
        private _y = 3.5 + _forEachIndex * 2.3;
        private _type = [_mag] call SB_fnc_ammoClass;
        private _shown = _names getOrDefault [_type, toUpper (_name select [0, 18])];
        private _col = [_ink, [1, 0.8, 0.3, 1]] select _isCurrent;

        ["label", 2.4, _y, 4.8, 1.5, [1, 1, 1, 1], _rectTex, [0.05, 0.06, 0.05, 1]] call _spr;
        [2.4, _y, 4.4, 0.6, toUpper (_wName select [0, 18]), _ink] call _txt;
        ["label", 7.5, _y, 4.9, 1.5, [1, 1, 1, 1], _rectTex, [0.05, 0.06, 0.05, 1]] call _spr;
        [7.5, _y, 4.5, 0.6, _shown, _col] call _txt;

        ["display", 12.4, _y, 4.5, 1.9, [1, 1, 1, 1], _rectTex, [0.02, 0.02, 0.02, 1]] call _spr;
        private _cnt = str _count;
        [11.25, _y, compile format ["'%1'", _cnt], 3, 0.85] call _sevenSeg;

        // aktif LED
        private _lx = 15.5;
        ["ring", _lx, _y, 1.05, 1.05, [1, 1, 1, 1], _dotTex, [0.45, 0.46, 0.43, 1]] call _spr;
        private _lens = ["lens", _lx, _y, 0.68, 0.68, _amber, _dotTex, _amber] call _spr;
        _lens ctrlSetTextColor ([[0.14, 0.1, 0.02, 1], _amber] select _isCurrent);
        ["gloss", _lx - 0.1, _y - 0.12, 0.55, 0.55, [1, 1, 1, 1], _dotTex, [1, 1, 1, 0]] call _spr;

        // SEC düğmesi (etiket plakası + görünmez tıklama alanı)
        ["label", 18.2, _y, 3.0, 1.4, [1, 1, 1, 1], _rectTex, [0.05, 0.06, 0.05, 1]] call _spr;
        [18.2, _y, 2.8, 0.6, "SELECT" call _L, [0.6, 0.9, 0.6, 1]] call _txt;
        [18.2, _y, 3.0, 1.5, [_turret, _mag], { (_this select 0) call SB_fnc_selectAmmo }] call _invH;
    };
} forEach _list;

if (_list isEqualTo []) then {
    [9.5, 6.0, 12, 0.7, "NO_AMMO" call _L, _ink] call _txt;
};

call _finish;
