/*
 * Panel durumunun oyuna etkileri (hudUpdate PFH'sinden her 0.3 sn çağrılır):
 *  - Ayna kilidi: hidrolik açık + ayna açık + 120 sn ısınma tamamsa optik yön stabilizasyonu açık, değilse kapalı
 *    (enableDirectionStabilization [bool, turretPath]; yalnızca optik modunda config'te directionStabilized varsa etkili)
 *  - Araçtan inince/araç değişince taret kilidini ve optik stabilizasyonu eski hâline getirir
 */
private _veh = vehicle player;
private _last = uiNamespace getVariable ["SB_effVeh", objNull];

if (!isNull _last && {_last != _veh}) then {
    private _lt = uiNamespace getVariable ["SB_lockedTurret", []];
    if (_lt isNotEqualTo []) then {
        _last setTurretLimits [_lt select 1];
        ["SB_TankUI_turretLimits", [_last, [_lt select 1]], _last] call CBA_fnc_targetEvent;
        uiNamespace setVariable ["SB_lockedTurret", []];
    };
    if (uiNamespace getVariable ["SB_gunStabSet", false]) then {
        // geçersiz kılmayı temizle (-1)
        [_last, uiNamespace getVariable ["SB_effTurret", [0]], -1] call SB_fnc_setGunStab;
        _last setVariable ["SB_gunStabApplied", nil];
        uiNamespace setVariable ["SB_gunStabSet", false];
    };
    if (uiNamespace getVariable ["SB_dirStabSet", false]) then {
        _last enableDirectionStabilization [true, uiNamespace getVariable ["SB_effTurret", [0]]];
        _last setVariable ["SB_dirStabApplied", nil];
        uiNamespace setVariable ["SB_dirStabSet", false];
    };
    uiNamespace setVariable ["SB_effVeh", objNull];
};

if !(_veh isKindOf "Tank") exitWith {};
if (!alive player || {!(missionNamespace getVariable ["SB_TankUI_effects", true])} || {!(_veh getVariable ["SB_armed", false])}) exitWith {};
if (([_veh, player] call SB_fnc_getRole) != "gunner") exitWith {};

uiNamespace setVariable ["SB_effVeh", _veh];

// Gerçek top stabilizasyonu: STAB etkinse (şalter + hidrolik + 120 sn ısınma + aşırı ısınma yok) 3 (iki düzlem), değilse 0
if (call SB_fnc_realStab) then {
    private _crewS = (fullCrew _veh) select {(_x select 0) isEqualTo player};
    private _turretS = if (_crewS isEqualTo []) then {[0]} else {(_crewS select 0) select 3};
    private _gmode = [0, 3] select ([_veh] call SB_fnc_stabEffective);
    if ((_veh getVariable ["SB_gunStabApplied", -9]) != _gmode) then {
        [_veh, _turretS, _gmode] call SB_fnc_setGunStab;
        _veh setVariable ["SB_gunStabApplied", _gmode];
        uiNamespace setVariable ["SB_gunStabSet", true];
        uiNamespace setVariable ["SB_effTurret", _turretS];
    };
};

if (missionNamespace getVariable ["SB_TankUI_opticStab", true]) then {
    private _crew = (fullCrew _veh) select {(_x select 0) isEqualTo player};
    private _turret = if (_crew isEqualTo []) then {[0]} else {(_crew select 0) select 3};
    private _want = (_veh getVariable ["SB_hydr", false]) && {_veh getVariable ["SB_mirror", false]} && {time - (_veh getVariable ["SB_hydrOn", 0]) >= 120};
    private _flag = [0, 1] select _want;
    if ((_veh getVariable ["SB_dirStabApplied", -1]) != _flag) then {
        _veh enableDirectionStabilization [_want, _turret];
        _veh setVariable ["SB_dirStabApplied", _flag];
        uiNamespace setVariable ["SB_dirStabSet", true];
        uiNamespace setVariable ["SB_effTurret", _turret];
    };
};
