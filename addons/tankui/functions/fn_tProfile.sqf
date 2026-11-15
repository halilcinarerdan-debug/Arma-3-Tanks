/* params: [araç, özellik adı, varsayılan] -> profildeki sayısal özellik (T serisi sistem farkları) */
params ["_veh", "_name", ["_def", 0]];
private _p = [_veh] call SB_fnc_getProfile;
if (isNumber (_p >> _name)) then { getNumber (_p >> _name) } else { _def }
