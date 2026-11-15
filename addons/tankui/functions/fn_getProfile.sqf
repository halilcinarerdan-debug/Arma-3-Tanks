/* params: [araç] -> CfgSBTankUI altındaki profil config'i (eşleşme yoksa Generic) */
params ["_veh"];
private _type = toLower typeOf _veh;
private _found = configFile >> "CfgSBTankUI" >> "Generic";
{
    private _profile = _x;
    if ({_x != "" && {(toLower _x) in _type}} count getArray (_profile >> "match") > 0) exitWith {
        _found = _profile;
    };
} forEach ("true" configClasses (configFile >> "CfgSBTankUI" >> "Profiles"));
_found
