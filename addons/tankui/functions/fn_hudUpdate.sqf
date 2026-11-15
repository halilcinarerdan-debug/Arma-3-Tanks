/*
 * Nişangâh plakalarını göster/gizle ve güncelle (CBA PFH, 0.3 sn).
 * Gösterim koşulu: ayar açık, menü kapalı, oyuncu tankta nişancı/komutan koltuğunda ve optiğe bakıyor (cameraView == "GUNNER").
 */
call SB_fnc_applyEffects;

private _want = false;
private _veh = vehicle player;
if (missionNamespace getVariable ["SB_TankUI_hud", true] && {isNull (uiNamespace getVariable ["SB_TankUI_display", displayNull])}) then {
    if (_veh isKindOf "Tank" && {alive player} && {cameraView == "GUNNER"} && {([_veh, player] call SB_fnc_getRole) in ["gunner", "commander"]}) then { _want = true };
};

private _disp = uiNamespace getVariable ["SB_TankUI_hudDisplay", displayNull];

if (_want) then {
    if (isNull _disp) then {
        // plakalar bu bağlamı (araç, rol, taret) okur; menünün onLoad'u ile aynı değişkenler
        uiNamespace setVariable ["SB_TankUI_vehicle", _veh];
        uiNamespace setVariable ["SB_TankUI_role", [_veh, player] call SB_fnc_getRole];
        private _crew = (fullCrew _veh) select {(_x select 0) isEqualTo player};
        uiNamespace setVariable ["SB_TankUI_turret", if (_crew isEqualTo []) then {[0]} else {(_crew select 0) select 3}];
        "SB_TankUI_hud" cutRsc ["SB_TankUI_Hud", "PLAIN", 0, false];
    } else {
        {
            private _fn = _x getVariable ["sb_fn", {}];
            [_x, _veh] call _fn;
        } forEach (uiNamespace getVariable ["SB_TankUI_hudCtrls", []]);
    };
} else {
    if !(isNull _disp) then {
        "SB_TankUI_hud" cutText ["", "PLAIN", 0];
        uiNamespace setVariable ["SB_TankUI_hudDisplay", displayNull];
        uiNamespace setVariable ["SB_TankUI_hudCtrls", []];
    };
};
