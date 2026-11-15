/*
 * Leopard 2 / Strv 122 sürücü istasyonu: hız göstergesi, yakıt, geri görüş kılavuzu, arıza lambaları, motor/far/kapak.
 * Geri görüş kılavuzu: kılavuzdaki siyah-beyaz geri görüş kamerasının (5 / 10 / 15 m işaretleri) fikrine göre; arkaya üç ışın
 * atılır, ölçülen engel uzaklığı çubuklarda gösterilir (Arma'da kamera görüntüsü yok, bu yüzden canlı mesafe verisi).
 */
params ["_display"];
private _veh = uiNamespace getVariable "SB_TankUI_vehicle";
#include "\z\tank33\addons\tankui\kit.sqf"

[getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName") + "  |  " + ("SCR_STATION" call _L), _roleLabel] call _header;
private _dim = [0.62, 0.78, 0.58, 1];

// hız + yakıt
[4.4, 5.8, 2.9, "gauge_speed", 80, -120, 120, compile "abs speed _this", [0.85, 0.15, 0.1, 1], [0.9, 0.9, 0.85, 1]] call _gauge;
[4.4, 9.4, 4, 0.5, "SPEED" call _L, _ink, 2, 0.45] call _txt;
["display", 4.4, 11.6, 5.0, 2.2, [1, 1, 1, 1], _rectTex, [0.02, 0.02, 0.02, 1]] call _spr;
[3.185, 11.6, compile "str round abs speed _this", 3, 0.9] call _sevenSeg;
[9.2, 4.0, 1.2, "gauge_fuel", 4, -60, 60, compile "(fuel _this) * 4", [0.05, 0.05, 0.05, 1], [0.9, 0.9, 0.85, 1]] call _gauge;
[9.2, 6.0, 3, 0.5, "FUEL" call _L, _ink, 2, 0.45] call _txt;

// geri görüş kılavuzu
["display", 15.4, 6.6, 8.6, 7.6, [1, 1, 1, 1], _rectTex, [0.02, 0.02, 0.02, 1]] call _spr;
[11.7, 3.1, 4, 0.5, "REAR_T" call _L, _dim, 0, 0.42] call _txt;
{
    private _p = [_x, 15.4, 5.25, 2.7, 4.05, [0.5, 0.55, 0.48, 1], _rectTex, [0, 0, 0, 0]] call _spr;
} forEach ["tank_trackL", "tank_trackR", "tank_hull", "tank_engine", "tank_turret", "tank_gun"];
{
    _x params ["_m", "_y"];
    [15.4, _y, 6.6, 0.05, [0.45, 0.55, 0.43, 1]] call _rect;
    [11.7, _y, 1.2, 0.5, format ["%1", _m], _dim, 2, 0.4] call _txt;
} forEach [[5, 8.0], [10, 8.7], [15, 9.4]];
{
    _x params ["_off", "_cx"];
    private _bar = [_cx, 7.3, 1.0, 0.05, [0.25, 0.95, 0.35, 1]] call _rect;
    _bar setVariable ["sb_pos", ctrlPosition _bar];
    _bar setVariable ["sb_off", _off];
    _bar setVariable ["sb_u", _u];
    private _val = [_cx, 10.1, 1.6, 0.5, "--", _ink, 2, 0.4] call _txt;
    _bar setVariable ["sb_val", _val];
    _bar setVariable ["sb_fn", {
        params ["_c", "_veh"];
        private _off = _c getVariable "sb_off";
        private _dir = vectorDir _veh;
        private _back = [-(_dir select 0), -(_dir select 1), 0];
        private _right = [_dir select 1, -(_dir select 0), 0];
        private _from = (_veh modelToWorldWorld [0, -4.8, 1.0]) vectorAdd (_right vectorMultiply _off);
        private _hits = lineIntersectsSurfaces [_from, _from vectorAdd (_back vectorMultiply 15), _veh, objNull, true, 1, "FIRE", "VIEW"];
        private _d = if (_hits isEqualTo []) then {-1} else {_from distance ((_hits select 0) select 0)};
        (_c getVariable "sb_pos") params ["_px", "_py", "_pw", "_ph"];
        private _len = if (_d < 0) then {0} else {(_d min 15) * 0.14 * (_c getVariable "sb_u")};   // 0.14 U / m
        _c ctrlSetPosition [_px, _py, _pw, _ph max _len];
        _c ctrlCommit 0;
        _c ctrlSetTextColor (if (_d < 0) then {[0.25, 0.95, 0.35, 1]} else {
            if (_d < 5) then {[0.95, 0.2, 0.15, 1]} else {if (_d < 10) then {[1, 0.72, 0.15, 1]} else {[0.25, 0.95, 0.35, 1]}}
        });
        (_c getVariable "sb_val") ctrlSetText (if (_d < 0) then {"--"} else {format ["%1 m", round _d]});
    }];
    [_bar, _veh] call (_bar getVariable "sb_fn");
} forEach [[-1.3, 14.0], [0, 15.4], [1.3, 16.8]];

// arıza lambaları
[10.6, 11.3, "L_RUN" call _L, _green, {isEngineOn _this}] call _lampRound;
[12.8, 11.3, "F_ENG" call _L, _red,  {([_this, "hitengine"] call SB_fnc_getHit) >= 0.3}] call _lampRound;
[15.0, 11.3, "F_LTR" call _L, _red,  {([_this, "hitltrack"] call SB_fnc_getHit) >= 0.3}] call _lampRound;
[17.2, 11.3, "F_RTR" call _L, _red,  {([_this, "hitrtrack"] call SB_fnc_getHit) >= 0.3}] call _lampRound;
[19.4, 11.3, "F_HULL" call _L, _red, {([_this, "hithull"] call SB_fnc_getHit) >= 0.3}] call _lampRound;

// şalterler (isLightOn / isTurnedOut doğrulanmadı: compile ile yalıtılmış)
[12.0, 13.9, "T_ENGINE" call _L, "engine", {[180, 0] select (isEngineOn _this)}] call _toggle;
[15.2, 13.9, "T_LIGHT" call _L, "lights", compile "[180, 0] select (isLightOn _this)"] call _toggle;
[18.4, 13.9, "T_HATCH" call _L, "hatch", compile "[180, 0] select (isTurnedOut player)"] call _toggle;

call _finish;
