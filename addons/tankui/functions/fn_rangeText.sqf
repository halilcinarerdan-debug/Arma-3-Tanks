/* 7 segment ekran metni. params: [araç] -> "----" veya metre (tam sayı) */
params ["_veh"];
if (_veh getVariable ["SB_rngMan", false]) exitWith { private _m = _veh getVariable ["SB_range", 0]; if (_m <= 0) then {"----"} else {str round _m} };
if ((missionNamespace getVariable ["SB_TankUI_rangeSource", 0]) == 1) exitWith { _veh getVariable ["SB_lrfText", "----"] };
private _d = [_veh] call SB_fnc_rangeValue;
if (_d <= 0) then {"----"} else {str round _d}
