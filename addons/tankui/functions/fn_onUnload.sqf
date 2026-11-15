private _pfh = uiNamespace getVariable ["SB_TankUI_pfh", -1];
if (_pfh >= 0) then { [_pfh] call CBA_fnc_removePerFrameHandler };
{ uiNamespace setVariable [_x, nil] } forEach [
    "SB_TankUI_display", "SB_TankUI_vehicle", "SB_TankUI_ctrls",
    "SB_TankUI_sig", "SB_TankUI_pfh", "SB_TankUI_tab", "SB_TankUI_role", "SB_TankUI_turret"
];
