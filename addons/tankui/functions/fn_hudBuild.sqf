/*
 * Nişangâh plakaları (RscTitles). Arma'nın kendi optik arayüzü (pusula, taret simgesi/EL, "menzil RDY", hasar ve silah
 * panelleri) ile ÇAKIŞMAMASI için yalnızca iki yandaki boş şeritlere, Arma'nın üst köşe panellerinin altına yerleşir:
 *  Sol: A = silah/mermi lambaları + yükleyici, B = stabilizasyon/sistem lambaları
 *  Sağ: C = LRF menzil ekranı, D = kalan mermi sayıları (BPS/OFS/BKS/PKT)
 * Girişi engellemez (yalnızca görüntü).
 */
params ["_display"];
private _veh = uiNamespace getVariable ["SB_TankUI_vehicle", vehicle player];
#include "\z\tank33\addons\tankui\kit.sqf"

// Ölçek: 1 U = ekran genişliğinin %1,3'ü (yan şeritlere sığar). kit'in _u'su yükseklik oranıdır.
_u = 0.013 * ((missionNamespace getVariable ["SB_TankUI_hudScale", 115]) / 100) / _asp;

private _colW = 9;
private _gap = 0.6;
private _x0L = _sx + 0.5 * _u * _asp;
private _x0R = _sx + _sw - (_colW + 0.5) * _u * _asp;
private _yTop = _sy + 0.17 * _sh;
private _dimTxt = [0.62, 0.78, 0.58, 1];
private _turretOf = "uiNamespace getVariable ['SB_TankUI_turret', [0]]";

// Plaka: siyah kenar + zeytin yüz + koyu iç alan + vidalar. Sonraki çizimler plakanın sol-üstünü (0,0) alır.
private _hplate = {
    params ["_px", "_py", "_wU", "_hU"];
    _bx = _px;
    _by = _py;
    [-0.12, -0.12, _wU + 0.24, _hU + 0.24, [0, 0, 0, 0.88]] call _box;
    [0, 0, _wU, _hU, [0.27, 0.31, 0.22, 0.94]] call _box;
    [0.2, 0.2, _wU - 0.4, _hU - 0.4, [0.05, 0.06, 0.05, 0.92]] call _box;
    {
        ["ring", (_x select 0) * _wU, (_x select 1) * _hU, 0.34, 0.34, [0.6, 0.6, 0.57, 1], _dotTex, [0.5, 0.52, 0.47, 1]] call _spr;
    } forEach [[0.04, 0.05], [0.96, 0.05], [0.04, 0.95], [0.96, 0.95]];
};

// ================= A (sol-üst): silah / mermi =================
private _hA = 8.4;
[_x0L, _yTop, _colW, _hA] call _hplate;
{
    _x params ["_key", "_type", "_y"];
    [1.3, _y, _key call _L, _amber, compile format [
        "([_this currentMagazineTurret (%2)] call SB_fnc_ammoClass) == '%1'", _type, _turretOf
    ], "", "right"] call _lampRound;
} forEach [["AM_KE", "KE", 1.5], ["AM_HE", "HE", 3.0], ["AM_HEAT", "HEAT", 4.5]];

[5.6, 1.5, "L_LOADED" call _L, [0.6, 0.35, 1, 1], {
    (_this ammo (_this currentWeaponTurret (uiNamespace getVariable ["SB_TankUI_turret", [0]]))) > 0
}, "", "right"] call _lampRound;
[5.6, 3.0, "L_READY" call _L, _red, {
    (_this ammo (_this currentWeaponTurret (uiNamespace getVariable ["SB_TankUI_turret", [0]])))> 0
    && {_this getVariable ["SB_lrfOn", false]} && {time >= (_this getVariable ["SB_lrfReadyAt", 0])}
}, "", "right"] call _lampRound;

// aktif silah | yüklü mermi tipi
private _wTxt = [0.8, 6.2, 7.4, 0.7, "", _amber, 0, 0.55] call _txt;
_wTxt setVariable ["sb_fn", {
    params ["_c", "_veh"];
    private _t = uiNamespace getVariable ["SB_TankUI_turret", [0]];
    ([_veh, _t] call SB_fnc_weaponRoles) params ["_main", "_coax"];
    private _w = _veh currentWeaponTurret _t;
    private _wl = if (_w == _main) then {"W_MAIN" call SB_fnc_lbl} else {
        if (_w == _coax) then {"W_COAX" call SB_fnc_lbl} else {getText (configFile >> "CfgWeapons" >> _w >> "displayName")}
    };
    private _ml = switch ([_veh currentMagazineTurret _t] call SB_fnc_ammoClass) do {
        case "KE": {"AM_KE" call SB_fnc_lbl};
        case "HE": {"AM_HE" call SB_fnc_lbl};
        case "HEAT": {"AM_HEAT" call SB_fnc_lbl};
        default {""};
    };
    _c ctrlSetText (_wl + (["", " | " + _ml] select (_ml != "")));
}];
[_wTxt, _veh] call (_wTxt getVariable "sb_fn");

// yükleyici durumu (yüklüyor / elle)
private _ldTxt = [0.8, 7.5, 7.4, 0.6, "", _dimTxt, 0, 0.45] call _txt;
_ldTxt setVariable ["sb_fn", {
    params ["_c", "_veh"];
    _c ctrlSetText (if (_veh getVariable ["SB_loading", false]) then {"LOADING" call SB_fnc_lbl} else {
        if (_veh getVariable ["SB_manual", false]) then {"T_AUTO" call SB_fnc_lbl} else {""}
    });
}];
[_ldTxt, _veh] call (_ldTxt getVariable "sb_fn");

// ================= B (sol): stabilizasyon / sistem =================
private _hB = 5.9;
private _yB = _yTop + (_hA + _gap) * _u;
[_x0L, _yB, _colW, _hB] call _hplate;
[1.3, 1.5, "L_STAB" call _L, _green, {[_this] call SB_fnc_stabEffective}, "", "right"] call _lampRound;
[5.6, 1.5, "L_HYDR" call _L, _green, {_this getVariable ["SB_hydr", false]}, "", "right"] call _lampRound;
[1.3, 3.0, "L_MIRROR" call _L, _red, {
    (_this getVariable ["SB_hydr", false]) && {_this getVariable ["SB_mirror", false]} && {time - (_this getVariable ["SB_hydrOn", 0]) >= 120}
}, "", "right"] call _lampRound;
[5.6, 3.0, "L_DELTA" call _L, _red, {_this getVariable ["SB_delta", false]}, "", "right"] call _lampRound;
[1.3, 4.5, "L_LRF" call _L, _green, {_this getVariable ["SB_lrfOn", false]}, "", "right"] call _lampRound;
private _modeTxt = [5.6, 4.5, 3.2, 0.6, "", _ink, 0, 0.5] call _txt;
_modeTxt setVariable ["sb_fn", {
    params ["_c", "_veh"];
    _c ctrlSetText (["NORM", "1200", "1800"] select (_veh getVariable ["SB_lrfMode", 0]));
}];
[_modeTxt, _veh] call (_modeTxt getVariable "sb_fn");

// ================= C (sağ-üst): LRF menzil =================
private _hC = 6.0;
[_x0R, _yTop, _colW, _hC] call _hplate;
["display", 4.5, 2.6, 6.2, 2.7, [1, 1, 1, 1], _rectTex, [0.02, 0.02, 0.02, 1]] call _spr;
[2.475, 2.6, compile "[_this] call SB_fnc_rangeText"] call _sevenSeg;
[4.5, 4.9, 7, 0.6, "RANGE_M" call _L, _dimTxt, 2, 0.5] call _txt;

// ================= D (sağ): kalan mermi sayıları =================
private _hD = 8.6;
private _yD = _yTop + (_hC + _gap) * _u;
[_x0R, _yD, _colW, _hD] call _hplate;
{
    _x params ["_key", "_code", "_y"];
    [0.9, _y, 3.6, 0.6, _key call _L, _ink, 0, 0.55] call _txt;
    [4.4, _y, _code, 3, 0.6] call _sevenSeg;
} forEach [
    ["AM_KE",   compile format ["str ([_this, %1, 'KE'] call SB_fnc_ammoCount)", _turretOf], 1.7],
    ["AM_HE",   compile format ["str ([_this, %1, 'HE'] call SB_fnc_ammoCount)", _turretOf], 3.5],
    ["AM_HEAT", compile format ["str ([_this, %1, 'HEAT'] call SB_fnc_ammoCount)", _turretOf], 5.3],
    ["W_COAX",  compile format ["str ([_this, %1] call SB_fnc_coaxCount)", _turretOf], 7.1]
];

uiNamespace setVariable ["SB_TankUI_hudCtrls", _ctrls];
