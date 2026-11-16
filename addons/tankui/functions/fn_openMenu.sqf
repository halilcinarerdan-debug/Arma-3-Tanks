/* Menüyü açar; zaten açıksa kapatır. Sadece tank içinde, hayattayken çalışır. */
if (!hasInterface) exitWith {};

private _display = uiNamespace getVariable ["SB_TankUI_display", displayNull];
if (!isNull _display) exitWith { closeDialog 0 };

private _veh = vehicle player;
if (_veh isEqualTo player || {!(_veh isKindOf "Tank")} || {!alive player}) exitWith {
    systemChat "Steel Tank UI: sadece tank içindeyken kullanılabilir.";
};

if ([_veh] call SB_fnc_isDisabled) exitWith {
    systemChat format ["Steel Tank UI: bu arac icin devre disi (CBA > Steel Tank UI > Devre disi araclar): %1", typeOf _veh];
};

createDialog "SB_TankUI_Main";
