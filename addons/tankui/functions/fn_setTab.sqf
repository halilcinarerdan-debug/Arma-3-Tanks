/* params: [sekme] 0 = mühimmat, 1 = durum, 2 = istasyon */
params ["_tab"];
private _display = uiNamespace getVariable ["SB_TankUI_display", displayNull];
if (isNull _display) exitWith {};

{ ctrlDelete _x } forEach (uiNamespace getVariable ["SB_TankUI_ctrls", []]);
uiNamespace setVariable ["SB_TankUI_ctrls", []];
uiNamespace setVariable ["SB_TankUI_tab", _tab];

private _active = [0.12, 0.25, 0.12, 1];
private _idle = [0.05, 0.08, 0.05, 1];
(_display displayCtrl 7411) ctrlSetBackgroundColor ([_idle, _active] select (_tab == 0));
(_display displayCtrl 7412) ctrlSetBackgroundColor ([_idle, _active] select (_tab == 1));
(_display displayCtrl 7413) ctrlSetBackgroundColor ([_idle, _active] select (_tab == 2));

switch (_tab) do {
    case 0: { [_display] call SB_fnc_drawAmmo };
    case 1: { [_display] call SB_fnc_drawStatus };
    case 2: { [_display] call SB_fnc_drawStation };
};
