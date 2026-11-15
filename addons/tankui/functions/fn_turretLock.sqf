/*
 * Hidrolik kapalıyken tareti mevcut yönünde kilitler; açılınca serbest bırakır (setTurretLimits, wiki doğrulandı):
 *   vehicle setTurretLimits [turret, minTurn, maxTurn, minElev, maxElev]   |   vehicle setTurretLimits [turret]  (sıfırla)
 * Sınırlar tareti modelin yönüne göre verilir (0 = taret modelinin ileri yönü); yalnızca config sınırları içinde geçerlidir.
 * Argüman yerel, etki global: komut hem burada (nişancı makinesi) hem aracın sahibinde çalıştırılır.
 * params: [araç, turretPath, kilitle(bool)]
 */
params ["_veh", "_turret", "_lock"];
if (_lock) then {
    private _w = _veh currentWeaponTurret _turret;
    if (_w == "") exitWith {};
    private _d = _veh vectorWorldToModel (_veh weaponDirection _w);
    private _az = (_d select 0) atan2 (_d select 1);
    private _el = asin (_d select 2);
    private _lim = [_turret, _az - 0.25, _az + 0.25, _el - 0.25, _el + 0.25];
    _veh setTurretLimits _lim;
    ["SB_TankUI_turretLimits", [_veh, _lim], _veh] call CBA_fnc_targetEvent;
    uiNamespace setVariable ["SB_lockedTurret", [_veh, _turret]];
    systemChat "T-72: hidrolik kapali, taret kilitli (elle krank yok).";
} else {
    _veh setTurretLimits [_turret];
    ["SB_TankUI_turretLimits", [_veh, [_turret]], _veh] call CBA_fnc_targetEvent;
    uiNamespace setVariable ["SB_lockedTurret", []];
    systemChat "T-72: hidrolik acik, taret serbest.";
};
