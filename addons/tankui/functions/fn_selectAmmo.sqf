/* params: [turretPath, magClass] -> o taretteki uyumlu silah/namlu bulunur ve mermi yüklenir. */
params ["_turret", "_mag"];
private _veh = uiNamespace getVariable ["SB_TankUI_vehicle", objNull];
if (isNull _veh) exitWith {};

private _muzzleToUse = "";
{
    private _weapon = _x;
    private _muzzles = getArray (configFile >> "CfgWeapons" >> _weapon >> "muzzles");
    {
        // "this" = silahın ana namlusu; loadMagazine bu durumda silah adını bekler
        private _muzzle = if (_x == "this") then {_weapon} else {_x};
        if (_muzzleToUse isEqualTo "" && {_mag in compatibleMagazines [_weapon, _muzzle]}) then {
            _muzzleToUse = _muzzle;
        };
    } forEach _muzzles;
} forEach (_veh weaponsTurret _turret);

if (_muzzleToUse isEqualTo "") exitWith {
    systemChat format ["Steel Tank UI: %1 için uyumlu silah bulunamadi.", _mag];
};

// loadMagazine araç sahibinde çalışmalı
["SB_TankUI_loadMagazine", [_veh, _turret, _muzzleToUse, _mag], _veh] call CBA_fnc_targetEvent;
