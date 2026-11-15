params ["_display"];
private _veh = vehicle player;
private _profile = [_veh] call SB_fnc_getProfile;

uiNamespace setVariable ["SB_TankUI_display", _display];
uiNamespace setVariable ["SB_TankUI_vehicle", _veh];
uiNamespace setVariable ["SB_TankUI_ctrls", []];
uiNamespace setVariable ["SB_TankUI_sig", ""];

(_display displayCtrl 7403) ctrlSetText getText (_profile >> "title");
(_display displayCtrl 7404) ctrlSetText getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName");

[0] call SB_fnc_setTab;

private _pfh = [{ call SB_fnc_refresh }, 0.5] call CBA_fnc_addPerFrameHandler;
uiNamespace setVariable ["SB_TankUI_pfh", _pfh];
