params ["_display"];
private _veh = vehicle player;
private _profile = [_veh] call SB_fnc_getProfile;
private _role = [_veh, player] call SB_fnc_getRole;
private _roleCfg = configFile >> "CfgSBTankUI" >> "Roles" >> _role;

uiNamespace setVariable ["SB_TankUI_display", _display];
uiNamespace setVariable ["SB_TankUI_vehicle", _veh];
uiNamespace setVariable ["SB_TankUI_role", _role];
// Oyuncunun taret yolu (nişancı istasyonu işlemleri için)
private _crew = (fullCrew _veh) select {(_x select 0) isEqualTo player};
uiNamespace setVariable ["SB_TankUI_turret", if (_crew isEqualTo []) then {[0]} else {(_crew select 0) select 3}];
uiNamespace setVariable ["SB_TankUI_ctrls", []];
uiNamespace setVariable ["SB_TankUI_sig", ""];

// Yan donanım düğmelerinin etiketleri (araç dili)
(_display displayCtrl 7411) ctrlSetText (["SCR_AMMO"] call SB_fnc_lbl);
(_display displayCtrl 7412) ctrlSetText (["SCR_STATUS"] call SB_fnc_lbl);
(_display displayCtrl 7413) ctrlSetText (["SCR_STATION"] call SB_fnc_lbl);
(_display displayCtrl 7499) ctrlSetText (["CLOSE"] call SB_fnc_lbl);

// Doku kapalıysa zemin zeytin yeşili yedek gövde olur; açıkken koyu zemin kalır (gövdenin arkasından dünya görünmesin)
if !(missionNamespace getVariable ["SB_TankUI_useTextures", true]) then { (_display displayCtrl 7401) ctrlSetBackgroundColor [0.25, 0.30, 0.20, 1] };
// Tanılama: fileExists sonucu (RPT)
diag_log format ["[SB_TankUI] fileExists ring=%1 housing=%2", fileExists "\z\tank33\addons\tankui\data\ring_ca.paa", fileExists "\z\tank33\addons\tankui\data\housing_ca.paa"];

// Role göre sekme düğmelerini diz (ammo -> 7411 / sekme 0, status -> 7412 / sekme 1)
private _tabMap = createHashMapFromArray [["ammo", [7411, 0]], ["status", [7412, 1]], ["station", [7413, 2]]];
private _p1 = ctrlPosition (_display displayCtrl 7411);
private _step = ((ctrlPosition (_display displayCtrl 7412)) select 1) - (_p1 select 1);
{ (_display displayCtrl _x) ctrlShow false } forEach [7411, 7412, 7413];

private _first = -1;
private _slot = 0;
{
    private _info = _tabMap getOrDefault [_x, []];
    // "station" sekmesi yalnızca profilde station tanımlıysa görünür
    if (_x == "station" && {getText (_profile >> "station") == ""}) then { _info = [] };
    if (_info isNotEqualTo []) then {
        _info params ["_idc", "_idx"];
        private _btn = _display displayCtrl _idc;
        _btn ctrlSetPosition [_p1 select 0, (_p1 select 1) + _step * _slot, _p1 select 2, _p1 select 3];
        _btn ctrlCommit 0;
        _btn ctrlShow true;
        _slot = _slot + 1;
        if (_first < 0) then { _first = _idx };
    };
} forEach getArray (_roleCfg >> "tabs");

[_first max 0] call SB_fnc_setTab;

private _pfh = [{ call SB_fnc_refresh }, 0.5] call CBA_fnc_addPerFrameHandler;
uiNamespace setVariable ["SB_TankUI_pfh", _pfh];
