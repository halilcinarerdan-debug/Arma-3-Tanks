/*
 * params: [araç] -> CfgSBTankUI altındaki profil config'i.
 * Önce CBA ayarı "Sinif eslestirme" ("sinif=Profil; sinif2=Profil2", sınıf adının küçük harfli bir parçası), sonra profillerin match[] listesi; eşleşme yoksa Generic.
 */
params ["_veh"];
private _type = toLower typeOf _veh;
private _found = configFile >> "CfgSBTankUI" >> "Generic";
private _done = false;

{
    private _kv = (trim _x) splitString "=";
    if (count _kv == 2) then {
        private _key = toLower (trim (_kv select 0));
        private _prof = configFile >> "CfgSBTankUI" >> "Profiles" >> (trim (_kv select 1));
        if (_key != "" && {_key in _type} && {isClass _prof}) exitWith { _found = _prof; _done = true };
    };
} forEach ((missionNamespace getVariable ["SB_TankUI_classMap", ""]) splitString ";");
if (_done) exitWith {_found};

{
    private _profile = _x;
    if ({_x != "" && {(toLower _x) in _type}} count getArray (_profile >> "match") > 0) exitWith {
        _found = _profile;
    };
} forEach ("true" configClasses (configFile >> "CfgSBTankUI" >> "Profiles"));
_found
