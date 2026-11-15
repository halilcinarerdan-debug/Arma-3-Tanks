/* 0.5 sn'de bir çağrılır (CBA PFH). */
private _display = uiNamespace getVariable ["SB_TankUI_display", displayNull];
if (isNull _display) exitWith {};

private _veh = uiNamespace getVariable ["SB_TankUI_vehicle", objNull];
if (isNull _veh || {!alive player} || {!(player in _veh)}) exitWith { closeDialog 0 };

private _tab = uiNamespace getVariable ["SB_TankUI_tab", 0];
if (_tab == 0) then {
    // Mühimmat değiştiyse listeyi yeniden çiz
    if (str ([_veh] call SB_fnc_getAmmoList) != (uiNamespace getVariable ["SB_TankUI_sig", ""])) then {
        [0] call SB_fnc_setTab;
    };
} else {
    {
        private _fn = _x getVariable ["sb_fn", {}];
        [_x, _veh] call _fn;
    } forEach (uiNamespace getVariable ["SB_TankUI_ctrls", []]);
};
