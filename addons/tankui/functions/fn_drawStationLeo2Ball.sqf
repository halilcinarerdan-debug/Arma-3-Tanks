/*
 * Balistik bilgisayar girişleri (isteğe bağlı sayfa; CBA: "Balistik giris sapmasi"). SB Leopard 2 panelindeki HÖHE / LUFTTEMP. /
 * PULVERTEMP. / QUERWIND girişlerinin karşılığı. Girilen değer gerçek ortamdan saparsa atış saparır (SB_fnc_firedEH).
 * Girilmeyen değer = gerçek değer (sapma yok). Yan rüzgâr AUTOM iken sensör gerçeği bilir; MANUELL iken girilen değer kullanılır.
 */
params ["_display"];
private _veh = uiNamespace getVariable "SB_TankUI_vehicle";
#include "\z\tank33\addons\tankui\kit.sqf"

[(getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName")) + "  |  " + ("BAL_T" call _L), _roleLabel] call _header;
{
    _x params ["_key", "_name", "_y"];
    ["label", 6.2, _y, 11.0, 1.4, [1, 1, 1, 1], _rectTex, [0.05, 0.06, 0.05, 1]] call _spr;
    [0.9, _y, 8.8, 0.6, _name call _L, _ink, 0, 0.45] call _txt;
    ["display", 14.0, _y, 3.8, 1.5, [1, 1, 1, 1], _rectTex, [0.02, 0.02, 0.02, 1]] call _spr;
    [12.9, _y, compile format ["private _v = [_this, '%1'] call SB_fnc_ballInput; (if (_v >= 0) then {'+'} else {'-'}) + str (abs _v)", _key], 4, 0.55] call _sevenSeg;
    [17.0, _y, "", format ["bal_%1_dn", _key], [0.45, 0.45, 0.45, 1]] call _push;
    [17.0, _y, 1.0, 0.6, "−", [0.05, 0.05, 0.05, 1], 2, 0.6] call _txt;
    [19.0, _y, "", format ["bal_%1_up", _key], [0.45, 0.45, 0.45, 1]] call _push;
    [19.0, _y, 1.0, 0.6, "+", [0.05, 0.05, 0.05, 1], 2, 0.6] call _txt;
} forEach [["alt", "BAL_ALT", 3.8], ["air", "BAL_AIR", 6.1], ["pow", "BAL_POW", 8.4], ["wind", "BAL_WIND", 10.7]];

[2.2, 13.0, "T_RMODE" call _L, "bal_windman", {[0, 180] select (_this getVariable ["SB_balWindMan", false])}] call _toggle;
private _env = [9.6, 13.0, 9.5, 0.5, "", _accent, 2, 0.4] call _txt;
_env setVariable ["sb_fn", {
    params ["_c", "_veh"];
    ([_veh] call SB_fnc_ballEnv) params ["_t", "_alt", "_w"];
    _c ctrlSetText format ["%1: %2 °C   %3 (x10 m)   %4 m/s", "BAL_ENV" call SB_fnc_lbl, _t, _alt, _w];
}];
[_env, _veh] call (_env getVariable "sb_fn");
[19.0, 13.2, "BAL_BACK" call _L, "page_main", [0.2, 0.6, 0.25, 1]] call _push;

call _finish;
