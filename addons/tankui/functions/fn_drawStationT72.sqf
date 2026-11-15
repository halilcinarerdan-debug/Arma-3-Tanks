/*
 * T-72 nişancı istasyonu: gerçek panel donanım şekilleriyle (spec: docs/t72m1-gunner-station.md)
 * Yuvarlak lambalar, kollu şalterler, dönel mermi seçici, beyaz yüzlü mermi sayacı,
 * 7 segmentli LRF ekranı, ibreli menzil çarkı. Hepsi ctrlCreate ile; ek texture gerekmez.
 * Birim "U" = ekran yüksekliğinin 0.05'i; genişlik asp ile çevrilir (daireler yuvarlak kalsın diye).
 * Panel dil: Latin; Kiril etiketler istenirse _txt çağrılarındaki metinler değiştirilir.
 */
params ["_display"];
private _veh = uiNamespace getVariable "SB_TankUI_vehicle";

(ctrlPosition (_display displayCtrl 7402)) params ["_sx", "_sy", "_sw", "_sh"];
private _res = getResolution;
private _asp = (_res select 1) / (_res select 0);
private _sgn = getNumber (configFile >> "CfgSBTankUI" >> "angleSign");
if (_sgn == 0) then { _sgn = 1 };
private _u = _sh * 0.05;
private _bx = _sx + _sw * 0.03;
private _by = _sy + _sh * 0.17;
private _ctrls = [];

private _dotTex = "\A3\ui_f\data\map\markers\military\dot_CA.paa";
private _rectTex = "#(argb,8,8,3)color(1,1,1,1)";
private _label = [0.82, 0.84, 0.78, 1];

private _fx = { _bx + _this * _u * _asp };
private _fy = { _by + _this * _u };

// merkez (frac) + boyut (U) ile resim
private _pic = {
    params ["_cx", "_cy", "_wU", "_hU", "_tex", "_col"];
    private _c = _display ctrlCreate ["SB_RscPicture", -1];
    _c ctrlSetText _tex;
    _c ctrlSetTextColor _col;
    _c ctrlSetPosition [_cx - _wU * _u * _asp / 2, _cy - _hU * _u / 2, _wU * _u * _asp, _hU * _u];
    _c ctrlCommit 0;
    _ctrls pushBack _c;
    _c
};
private _dot = { params ["_ox", "_oy", "_d", "_col"]; [_ox call _fx, _oy call _fy, _d, _d, _dotTex, _col] call _pic };
private _rect = { params ["_ox", "_oy", "_wU", "_hU", "_col"]; [_ox call _fx, _oy call _fy, _wU, _hU, _rectTex, _col] call _pic };
// ibre/kol/çentik için: ince dikdörtgen kontrol (konumu placeRect belirler)
private _bar = { params ["_col"]; [0, 0, 0.1, 0.1, _rectTex, _col] call _pic };

private _txt = {
    params ["_ox", "_oy", "_wU", "_hU", "_text", ["_col", _label]];
    private _c = _display ctrlCreate ["SB_RscTextC", -1];
    _c ctrlSetPosition [(_ox call _fx) - _wU * _u * _asp / 2, (_oy call _fy) - _hU * _u / 2, _wU * _u * _asp, _hU * _u];
    _c ctrlSetText _text;
    _c ctrlSetFontHeight (_u * 0.46);
    _c ctrlSetTextColor _col;
    _c ctrlCommit 0;
    _ctrls pushBack _c;
    _c
};
private _inv = {
    params ["_ox", "_oy", "_wU", "_hU", "_act"];
    private _c = _display ctrlCreate ["SB_RscButtonInvisible", -1];
    _c ctrlSetPosition [(_ox call _fx) - _wU * _u * _asp / 2, (_oy call _fy) - _hU * _u / 2, _wU * _u * _asp, _hU * _u];
    _c ctrlCommit 0;
    _c setVariable ["sb_act", _act];
    _c ctrlAddEventHandler ["ButtonClick", { [(_this select 0) getVariable "sb_act"] call SB_fnc_t72Action }];
    _ctrls pushBack _c;
    _c
};

// sol-üst köşe + boyut ile dikdörtgen
private _box = { params ["_ox", "_oy", "_wU", "_hU", "_col"]; [_ox + _wU / 2, _oy + _hU / 2, _wU, _hU, _col] call _rect };

// Tablet dokusu hissi: siyah dış çerçeve, zeytin yeşili yüz, açık üst-sol / koyu alt-sağ kabartma, oluklu vidalar
private _plate = {
    params ["_ox", "_oy", "_wU", "_hU"];
    [_ox - 0.15, _oy - 0.15, _wU + 0.3, _hU + 0.3, [0.02, 0.02, 0.02, 1]] call _box;
    [_ox, _oy, _wU, _hU, [0.1, 0.12, 0.08, 1]] call _box;
    [_ox, _oy, _wU - 0.12, _hU - 0.12, [0.42, 0.46, 0.34, 1]] call _box;
    [_ox + 0.12, _oy + 0.12, _wU - 0.24, _hU - 0.24, [0.3, 0.34, 0.24, 1]] call _box;
    {
        private _sx2 = _ox + (_x select 0) * _wU;
        private _sy2 = _oy + (_x select 1) * _hU;
        [_sx2, _sy2, 0.42, [0.1, 0.11, 0.09, 1]] call _dot;
        [_sx2, _sy2, 0.32, [0.55, 0.57, 0.5, 1]] call _dot;
        private _slot = [[0.12, 0.13, 0.1, 1]] call _bar;
        private _a = 40;
        private _len = 0.3;
        [_slot, (_sx2 - (sin _a) * _len / 2) call _fx, (_sy2 + (cos _a) * _len / 2) call _fy, _len * _u, _u * 0.06, _a, _asp, _sgn] call SB_fnc_placeRect;
    } forEach [[0.03, 0.045], [0.97, 0.045], [0.03, 0.955], [0.97, 0.955]];
};

// ---- Etiket kutulu LED lamba (siyah kutu, etiket solda, LED sağda) ----
private _lamp = {
    params ["_ox", "_oy", "_name", "_col", "_code"];
    [_ox, _oy, 3.6, 1.0, [0.03, 0.03, 0.03, 1]] call _rect;
    [_ox, _oy, 3.4, 0.82, [0.09, 0.1, 0.08, 1]] call _rect;
    [_ox - 0.55, _oy, 2.3, 0.6, _name, [0.86, 0.87, 0.82, 1]] call _txt;
    [_ox + 1.25, _oy, 0.86, [0.42, 0.43, 0.4, 1]] call _dot;
    [_ox + 1.25, _oy, 0.68, [0.04, 0.04, 0.04, 1]] call _dot;
    private _lens = [_ox + 1.25, _oy, 0.58, _col] call _dot;
    [_ox + 1.12, _oy - 0.14, 0.18, [1, 1, 1, 0.45]] call _dot;
    _lens setVariable ["sb_col", _col];
    _lens setVariable ["sb_code", _code];
    _lens setVariable ["sb_fn", {
        params ["_c", "_veh"];
        private _k = _c getVariable "sb_col";
        _c ctrlSetTextColor (if (_veh call (_c getVariable "sb_code")) then {_k} else {[(_k select 0) * 0.16, (_k select 1) * 0.16, (_k select 2) * 0.16, 1]});
    }];
    [_lens, _veh] call (_lens getVariable "sb_fn");
};

// ---- Kollu şalter: _angCode araç alır, kol açısı döner (0 = yukarı, 180 = aşağı) ----
private _toggle = {
    params ["_ox", "_oy", "_name", "_act", "_angCode"];
    [_ox, _oy, 1.5, [0.2, 0.22, 0.19, 1]] call _dot;
    [_ox, _oy, 1.05, [0.6, 0.62, 0.57, 1]] call _dot;
    private _lever = [[0.86, 0.87, 0.83, 1]] call _bar;
    _lever setVariable ["sb_geo", [_ox call _fx, _oy call _fy, _u * 0.95, _u * 0.3, _asp, _sgn]];
    _lever setVariable ["sb_ang", _angCode];
    _lever setVariable ["sb_fn", {
        params ["_c", "_veh"];
        (_c getVariable "sb_geo") params ["_x0", "_y0", "_len", "_th", "_a", "_s"];
        [_c, _x0, _y0, _len, _th, _veh call (_c getVariable "sb_ang"), _a, _s] call SB_fnc_placeRect;
    }];
    [_lever, _veh] call (_lever getVariable "sb_fn");
    [_ox, _oy + 1.6, 2.4, 0.5, _name] call _txt;
    [_ox, _oy, 1.7, 2.2, _act] call _inv;
};

// ---- Dönel seçici: _pos = [[etiket, eylem, açı], ...], _idxCode araç alır, konum indeksi döner ----
private _rotary = {
    params ["_ox", "_oy", "_pos", "_idxCode"];
    [_ox, _oy, 3.0, [0.2, 0.22, 0.19, 1]] call _dot;
    [_ox, _oy, 2.25, [0.55, 0.57, 0.52, 1]] call _dot;
    [_ox, _oy, 1.85, [0.1, 0.11, 0.1, 1]] call _dot;
    private _ptr = [[0.92, 0.92, 0.88, 1]] call _bar;
    {
        _x params ["_name", "_act", "_ang"];
        private _lx = _ox + (sin _ang) * 2.35;
        private _ly = _oy - (cos _ang) * 2.35;
        [_lx, _ly, 1.8, 0.5, _name] call _txt;
        [_lx, _ly, 1.8, 0.95, _act] call _inv;
    } forEach _pos;
    _ptr setVariable ["sb_geo", [_ox call _fx, _oy call _fy, _u * 0.95, _u * 0.3, _asp, _sgn]];
    _ptr setVariable ["sb_angles", _pos apply { _x select 2 }];
    _ptr setVariable ["sb_idx", _idxCode];
    _ptr setVariable ["sb_fn", {
        params ["_c", "_veh"];
        (_c getVariable "sb_geo") params ["_x0", "_y0", "_len", "_th", "_a", "_s"];
        private _ang = (_c getVariable "sb_angles") select ((_veh call (_c getVariable "sb_idx")) max 0);
        [_c, _x0, _y0, _len, _th, _ang, _a, _s] call SB_fnc_placeRect;
    }];
    [_ptr, _veh] call (_ptr getVariable "sb_fn");
};

// ---- Gösterge: çentikli kadran + ibre ----
private _gauge = {
    params ["_ox", "_oy", "_r", "_max", "_a0", "_a1", "_valCode", "_labStep", "_face", "_ink", "_needleCol"];
    [_ox, _oy, _r * 2 + 0.4, [0.42, 0.43, 0.4, 1]] call _dot;
    [_ox, _oy, _r * 2, _face] call _dot;
    for "_i" from 0 to _max do {
        private _ang = _a0 + (_a1 - _a0) * _i / _max;
        private _t = [_ink] call _bar;
        private _rIn = _r * 0.72;
        [_t, (_ox + (sin _ang) * _rIn) call _fx, (_oy - (cos _ang) * _rIn) call _fy, _r * 0.22 * _u, _u * 0.07, _ang, _asp, _sgn] call SB_fnc_placeRect;
        if (_i mod _labStep == 0) then {
            [_ox + (sin _ang) * _r * 0.5, _oy - (cos _ang) * _r * 0.5, 1.0, 0.5, str _i, _ink] call _txt;
        };
    };
    private _n = [_needleCol] call _bar;
    _n setVariable ["sb_geo", [_ox call _fx, _oy call _fy, _r * 0.8 * _u, _u * 0.1, _asp, _sgn, _a0, _a1, _max]];
    _n setVariable ["sb_val", _valCode];
    _n setVariable ["sb_fn", {
        params ["_c", "_veh"];
        (_c getVariable "sb_geo") params ["_x0", "_y0", "_len", "_th", "_a", "_s", "_a0", "_a1", "_max"];
        private _v = (_veh call (_c getVariable "sb_val")) max 0 min _max;
        [_c, _x0, _y0, _len, _th, _a0 + (_a1 - _a0) * (_v / _max), _a, _s] call SB_fnc_placeRect;
    }];
    [_n, _veh] call (_n getVariable "sb_fn");
    [_ox, _oy, 0.4, [0.1, 0.1, 0.1, 1]] call _dot;
};

// ---- Basma düğmesi: yuvarlak, kırmızı başlıklı ----
private _push = {
    params ["_ox", "_oy", "_name", "_act", ["_cap", [0.72, 0.1, 0.1, 1]]];
    [_ox, _oy, 1.7, [0.2, 0.22, 0.19, 1]] call _dot;
    [_ox, _oy, 1.25, _cap] call _dot;
    [_ox - 0.25, _oy - 0.3, 0.35, [1, 1, 1, 0.3]] call _dot;
    [_ox, _oy + 1.3, 3.0, 0.5, _name] call _txt;
    [_ox, _oy, 1.9, 1.9, _act] call _inv;
};

// ---- 7 segmentli ekran (4 hane) ----
private _sevenSeg = {
    params ["_ox", "_oy", "_codeText"];
    private _wD = 1.0; private _hD = 1.9; private _t = 0.2;
    private _segDef = [
        [0, -(_hD / 2) + _t / 2, _wD - _t * 1.2, _t],
        [(_wD / 2) - _t / 2, -(_hD / 4), _t, _hD / 2 - _t * 1.2],
        [(_wD / 2) - _t / 2, _hD / 4, _t, _hD / 2 - _t * 1.2],
        [0, (_hD / 2) - _t / 2, _wD - _t * 1.2, _t],
        [-(_wD / 2) + _t / 2, _hD / 4, _t, _hD / 2 - _t * 1.2],
        [-(_wD / 2) + _t / 2, -(_hD / 4), _t, _hD / 2 - _t * 1.2],
        [0, 0, _wD - _t * 1.2, _t]
    ];
    private _digits = [];
    for "_i" from 0 to 3 do {
        private _segs = [];
        { _x params ["_dx", "_dy", "_w", "_h"];
            _segs pushBack ([_ox + _i * 1.35 + _dx, _oy + _dy, _w, _h, [0.2, 0.02, 0.02, 1]] call _rect);
        } forEach _segDef;
        _digits pushBack _segs;
    };
    private _holder = [_ox, _oy, 0.01, 0.01, [0, 0, 0, 0]] call _rect;
    _holder setVariable ["sb_digits", _digits];
    _holder setVariable ["sb_text", _codeText];
    _holder setVariable ["sb_fn", {
        params ["_c", "_veh"];
        private _txt = _veh call (_c getVariable "sb_text");
        while {count _txt < 4} do { _txt = " " + _txt };
        private _map = createHashMapFromArray [
            ["0", "abcdef"], ["1", "bc"], ["2", "abged"], ["3", "abgcd"], ["4", "fgbc"],
            ["5", "afgcd"], ["6", "afgedc"], ["7", "abc"], ["8", "abcdefg"], ["9", "abcdfg"], ["-", "g"], [" ", ""]
        ];
        {
            private _on = _map getOrDefault [_txt select [_forEachIndex, 1], ""];
            private _seg = _x;
            { _seg # _forEachIndex ctrlSetTextColor ([[0.2, 0.02, 0.02, 1], [1, 0.16, 0.1, 1]] select (("abcdefg" select [_forEachIndex, 1]) in _on)) } forEach _seg;
        } forEach (_c getVariable "sb_digits");
    }];
    [_holder, _veh] call (_holder getVariable "sb_fn");
};

private _green = [0.25, 0.95, 0.35, 1];
private _amber = [1, 0.72, 0.15, 1];
private _red = [0.95, 0.2, 0.15, 1];
private _turretPath = { uiNamespace getVariable ["SB_TankUI_turret", [0]] };

// ======== Sol plaka: lambalar, balistik, mermi sayacı, seçici ========
[0, 0, 11.8, 13.6] call _plate;

// Durum lambaları: iki sütun (kılavuz: stabilizasyon, GPS ayna, hidrolik / TC müdahalesi, Delta-d, top yüklü)
[2.1, 1.4, "STAB",  _green, {_this getVariable ["SB_stab", false]}] call _lamp;
[2.1, 2.6, "AYNA",  _green, {(_this getVariable ["SB_hydr", false]) && {time - (_this getVariable ["SB_hydrOn", 0]) >= 120}}] call _lamp;
[2.1, 3.8, "HIDR",  _green, {_this getVariable ["SB_hydr", false]}] call _lamp;
[5.9, 1.4, "TC",    _amber, {false}] call _lamp;
[5.9, 2.6, "DELTA", _amber, {_this getVariable ["SB_delta", false]}] call _lamp;
[5.9, 3.8, "YUKLU", _red,   {(_this ammo (_this currentWeaponTurret (call _turretPath))) > 0}] call _lamp;

// Balistik: BPS (APFSDS/KE), OFS (HE-Frag), BKS (HEAT). Gerçek T-72 mermi kısaltmaları.
[2.2, 6.1, 3.0, 0.5, "BALISTIK"] call _txt;
{
    _x params ["_t", "_type", "_i"];
    [2.1 + 3.8 * _i, 7.0, _t, _amber, compile format [
        "([_this currentMagazineTurret (uiNamespace getVariable ['SB_TankUI_turret', [0]])] call SB_fnc_ammoClass) == '%1'", _type
    ]] call _lamp;
} forEach [["BPS", "KE", 0], ["OFS", "HE", 1], ["BKS", "HEAT", 2]];

// mermi sayacı: seçili tipin adedi (KAPALI iken boş yuva sayısı), maks 11
[9.9, 3.5, 1.6, 11, -115, 115, compile "
    private _t = uiNamespace getVariable ['SB_TankUI_turret', [0]];
    private _sel = _this getVariable ['SB_selType', ''];
    if (_sel != '') then { [_this, _t, _sel] call SB_fnc_ammoCount } else {
        22 - (([_this, _t, 'KE'] call SB_fnc_ammoCount) + ([_this, _t, 'HEAT'] call SB_fnc_ammoCount) + ([_this, _t, 'HE'] call SB_fnc_ammoCount))
    }
", 2, [0.9, 0.9, 0.85, 1], [0.1, 0.1, 0.1, 1], [0.05, 0.05, 0.05, 1]] call _gauge;
[9.9, 5.6, 3.0, 0.5, "MERMI SAYAC"] call _txt;

[3.4, 11.1, [["KAPALI", "sel_OFF", -75], ["BPS", "sel_KE", -25], ["BKS", "sel_HEAT", 25], ["OFS", "sel_HE", 75]],
    compile "['', 'KE', 'HEAT', 'HE'] find (_this getVariable ['SB_selType', ''])"] call _rotary;
[3.4, 13.0, 4, 0.5, "MERMI SECICI"] call _txt;
[8.6, 10.6, "YUKLE", "load", [0.2, 0.55, 0.2, 1]] call _push;

private _st = [8.9, 13.0, 5.0, 0.5, ""] call _txt;
_st setVariable ["sb_fn", { params ["_c", "_veh"]; _c ctrlSetText (["YUKLEYICI: HAZIR", "YUKLEYICI: YUKLUYOR"] select (_veh getVariable ["SB_loading", false])) }];
[_st, _veh] call (_st getVariable "sb_fn");

// ======== Sağ plaka: LRF, menzil çarkı, şalterler ========
private _rx = 12.3;
[_rx, 0, 11.9, 13.6] call _plate;

// LRF 7 segment ekranı
[_rx + 0.6, 0.4, 6.4, 2.7, [0.02, 0.02, 0.02, 1]] call _box;
[_rx + 1.9, 1.75, compile "_this getVariable ['SB_lrfText', '----']"] call _sevenSeg;
[_rx + 9.6, 1.4, "HAZIR", _red, {
    (_this ammo (_this currentWeaponTurret (uiNamespace getVariable ["SB_TankUI_turret", [0]]))) > 0 && {time >= (_this getVariable ["SB_lrfReadyAt", 0])}
}] call _lamp;

// menzil çarkı (x100 m, 3000 m sınırı)
[_rx + 3.9, 7.0, 3.0, 30, -100, 100, compile "(_this getVariable ['SB_range', 0]) / 100", 5, [0.06, 0.07, 0.06, 1], [0.92, 0.92, 0.88, 1], [1, 0.45, 0.1, 1]] call _gauge;
[_rx + 3.9, 10.45, 5, 0.5, "MENZIL x100 m"] call _txt;

[_rx + 8.9, 5.6, "LAZER", "lase"] call _push;
[_rx + 8.9, 8.7, "MENZIL 0", "reset", [0.15, 0.15, 0.15, 1]] call _push;

// şalter sırası (DELTA-D / STAB / HIDROLIK)
[_rx + 1.6, 11.9, "DELTA-D", "delta", {[180, 0] select (_this getVariable ["SB_delta", false])}] call _toggle;
[_rx + 4.0, 11.9, "STAB", "stab", {[180, 0] select (_this getVariable ["SB_stab", false])}] call _toggle;
[_rx + 6.4, 11.9, "HIDR", "hydr", {[180, 0] select (_this getVariable ["SB_hydr", false])}] call _toggle;

// LRF modu: 3 konumlu şalter (1200 / NORMAL / 1800)
[_rx + 9.6, 11.9, "LRF MOD", "mode", {[0, -40, 40] select (_this getVariable ["SB_lrfMode", 0])}] call _toggle;
[_rx + 8.5, 10.7, 1.4, 0.5, "1200"] call _txt;
[_rx + 10.7, 10.7, 1.4, 0.5, "1800"] call _txt;

uiNamespace setVariable ["SB_TankUI_ctrls", _ctrls];
