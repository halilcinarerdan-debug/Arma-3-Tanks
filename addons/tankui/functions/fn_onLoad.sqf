params ["_display"];
private _veh = vehicle player;
private _profile = [_veh] call SB_fnc_getProfile;
private _role = [_veh, player] call SB_fnc_getRole;
private _roleCfg = configFile >> "CfgSBTankUI" >> "Roles" >> _role;

uiNamespace setVariable ["SB_TankUI_display", _display];
uiNamespace setVariable ["SB_TankUI_vehicle", _veh];
uiNamespace setVariable ["SB_TankUI_role", _role];
uiNamespace setVariable ["SB_TankUI_ctrls", []];
uiNamespace setVariable ["SB_TankUI_sig", ""];

(_display displayCtrl 7403) ctrlSetText (getText (_profile >> "title") + " | " + getText (_roleCfg >> "label"));
(_display displayCtrl 7404) ctrlSetText getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName");

// Role göre sekme düğmelerini diz (ammo -> 7411 / sekme 0, status -> 7412 / sekme 1)
private _tabMap = createHashMapFromArray [["ammo", [7411, 0]], ["status", [7412, 1]]];
private _p1 = ctrlPosition (_display displayCtrl 7411);
private _step = ((ctrlPosition (_display displayCtrl 7412)) select 0) - (_p1 select 0);
{ (_display displayCtrl _x) ctrlShow false } forEach [7411, 7412];

private _first = -1;
{
    private _info = _tabMap getOrDefault [_x, []];
    if (_info isNotEqualTo []) then {
        _info params ["_idc", "_idx"];
        private _btn = _display displayCtrl _idc;
        _btn ctrlSetPosition [(_p1 select 0) + _step * _forEachIndex, _p1 select 1, _p1 select 2, _p1 select 3];
        _btn ctrlCommit 0;
        _btn ctrlShow true;
        if (_first < 0) then { _first = _idx };
    };
} forEach getArray (_roleCfg >> "tabs");

[_first max 0] call SB_fnc_setTab;

private _pfh = [{ call SB_fnc_refresh }, 0.5] call CBA_fnc_addPerFrameHandler;
uiNamespace setVariable ["SB_TankUI_pfh", _pfh];
