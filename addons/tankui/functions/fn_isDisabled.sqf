/*
 * Bu araçta Steel Tank UI devre dışı mı? CBA ayarı "Devre disi araclar": virgül/noktalı virgül ile ayrılmış girdiler.
 * Girdi bir PROFİL adıysa (Leopard2, T72B3, M1A2, ...) o profildeki tüm araçlar; değilse sınıf adının küçük harfli bir parçası.
 * params: [araç] -> bool
 */
params ["_veh"];
private _list = missionNamespace getVariable ["SB_TankUI_disabled", ""];
if (_list == "") exitWith {false};
private _type = toLower typeOf _veh;
private _pname = toLower configName ([_veh] call SB_fnc_getProfile);
private _hit = false;
{
    private _t = toLower (trim _x);
    if (_t != "" && {(_t == _pname) || {_t in _type}}) exitWith { _hit = true };
} forEach (_list splitString ",;");
_hit
