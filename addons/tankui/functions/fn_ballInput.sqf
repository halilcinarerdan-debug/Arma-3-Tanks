/* params: [araç, "air"|"pow"|"alt"|"wind"] -> bilgisayara girilen değer (girilmediyse gerçek değer; yan rüzgâr AUTOM ise her zaman gerçek) */
params ["_veh", "_key"];
private _env = [_veh] call SB_fnc_ballEnv;
private _actual = switch (_key) do { case "air": {_env select 0}; case "pow": {_env select 0}; case "alt": {_env select 1}; default {_env select 2} };
if (_key == "wind" && {!(_veh getVariable ["SB_balWindMan", false])}) exitWith {_actual};
_veh getVariable ["SB_bal_" + _key, _actual]
