/* Menüyü açar; zaten açıksa kapatır. Sadece tank içinde, hayattayken çalışır. */
if (!hasInterface) exitWith {};

private _display = uiNamespace getVariable ["SB_TankUI_display", displayNull];
if (!isNull _display) exitWith { closeDialog 0 };

private _veh = vehicle player;
if (_veh isEqualTo player || {!(_veh isKindOf "Tank")} || {!alive player}) exitWith {
    systemChat "Steel Tank UI: sadece tank içindeyken kullanılabilir.";
};

createDialog "SB_TankUI_Main";
