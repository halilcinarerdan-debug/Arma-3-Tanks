/*
 * Ortak ekipman takımı. Ekran fonksiyonlarına #include ile gömülür.
 * Beklenen değişkenler: _display, _veh.
 * Birim "U": ekran yüksekliğinin 1/17'si. Genişlik asp ile çevrilir, daireler yuvarlak kalır.
 * Dokular \z\tank33\addons\tankui\data\*.paa; yoksa düz renk yedeği kullanılır (tools/gen_textures.py).
 */
(ctrlPosition (_display displayCtrl 7402)) params ["_sx", "_sy", "_sw", "_sh"];
private _res = getResolution;
private _asp = (_res select 1) / (_res select 0);
private _sgn = missionNamespace getVariable ["SB_TankUI_angleSign", getNumber (configFile >> "CfgSBTankUI" >> "angleSign")];
if (_sgn == 0) then { _sgn = 1 };
private _L = { [_this] call SB_fnc_lbl };
private _u = _sh / 17;
private _bx = _sx + _u * _asp * 0.8;
private _by = _sy + _u * 0.4;
private _ctrls = [];
// Palet: profildeki palette ("leo" = Leopard 2 iç mekanı: açık gri boya, beyaz yazı, kare LED düğmeler)
private _profCfg = [_veh] call SB_fnc_getProfile;   // not: >> operatörü call'dan önce çözülür
private _pal = getText (_profCfg >> "palette");
private _leo = _pal != "";
private _accent = [[0.62, 0.78, 0.58, 1], [0.9, 0.92, 0.9, 1]] select _leo;
private _isSq = _pal in ["leo", "m1"];
private _sqOk = _isSq && {fileExists "\z\tank33\addons\tankui\data\ring_sq_ca.paa"} && {fileExists "\z\tank33\addons\tankui\data\lens_sq_ca.paa"};
private _ringN = ["ring", "ring_sq"] select _sqOk;
private _lensN = ["lens", "lens_sq"] select _sqOk;
private _roleLabel = ("ROLE_" + (uiNamespace getVariable ["SB_TankUI_role", "other"])) call _L;

private _dotTex = "\A3\ui_f\data\map\markers\military\dot_CA.paa";
private _rectTex = "#(argb,8,8,3)color(1,1,1,1)";
private _ink = [0.84, 0.86, 0.8, 1];
// Doku dosyaları <ad>_ca.paa olarak adlandırılır (tools/gen_textures.py); kodda yalnızca <ad> kullanılır.
// Dokusuz yedek moda geçmek için CBA ayarı "Dokulari kullan" kapatılır.
private _useTex = missionNamespace getVariable ["SB_TankUI_useTextures", true];
private _tex = { ["", format ["\z\tank33\addons\tankui\data\%1_ca.paa", _this]] select _useTex };
private _fx = { _bx + _this * _u * _asp };
private _fy = { _by + _this * _u };

// merkez (frac) + boyut (U)
private _pic = {
    params ["_cx", "_cy", "_wU", "_hU", "_t", "_col"];
    private _c = _display ctrlCreate ["SB_RscPicture", -1];
    _c ctrlSetText _t;
    _c ctrlSetTextColor _col;
    _c ctrlSetPosition [_cx - _wU * _u * _asp / 2, _cy - _hU * _u / 2, _wU * _u * _asp, _hU * _u];
    _c ctrlCommit 0;
    _ctrls pushBack _c;
    _c
};
// doku varsa onu, yoksa düz yedeği çizer
private _spr = {
    params ["_name", "_ox", "_oy", "_wU", "_hU", ["_col", [1, 1, 1, 1]], ["_fbTex", _rectTex], ["_fbCol", [0.1, 0.1, 0.1, 1]]];
    private _t = _name call _tex;
    private _k = _col;
    private _fallback = false;
    if (_t == "") then { _t = _fbTex; _k = _fbCol; _fallback = true };
    private _c = [_ox call _fx, _oy call _fy, _wU, _hU, _t, _k] call _pic;
    if (_fallback && {(_fbCol select 3) == 0}) then { _c ctrlShow false };
    _c
};
private _rect = { params ["_ox", "_oy", "_wU", "_hU", "_col"]; [_ox call _fx, _oy call _fy, _wU, _hU, _rectTex, _col] call _pic };
private _box = { params ["_ox", "_oy", "_wU", "_hU", "_col"]; [_ox + _wU / 2, _oy + _hU / 2, _wU, _hU, _col] call _rect };
// ibre/kol/işaretçi: placeRect ile konumlanır
private _bar = {
    params ["_col", ["_name", "needle"]];
    private _t = _name call _tex;
    if (_t == "") then { _t = _rectTex };
    [0 call _fx, 0 call _fy, 0.1, 0.1, _t, _col] call _pic
};
private _txt = {
    params ["_ox", "_oy", "_wU", "_hU", "_text", ["_col", _ink], ["_style", 2], ["_fs", 0.46]];
    private _c = _display ctrlCreate [["SB_RscText", "SB_RscTextR", "SB_RscTextC"] select _style, -1];
    _c ctrlSetPosition [(_ox call _fx) - ([0, _wU * _u * _asp / 2] select (_style == 2)), (_oy call _fy) - _hU * _u / 2, _wU * _u * _asp, _hU * _u];
    _c ctrlSetText _text;
    _c ctrlSetFontHeight (_u * _fs);
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
// tıklanınca _handler (kod) [_act] ile çağrılır
private _invH = {
    params ["_ox", "_oy", "_wU", "_hU", "_act", "_handler"];
    private _c = [_ox, _oy, _wU, _hU, _act] call _inv;
    _c setVariable ["sb_handler", _handler];
    _c ctrlRemoveAllEventHandlers "ButtonClick";
    _c ctrlAddEventHandler ["ButtonClick", { params ["_c"]; [_c getVariable "sb_act"] call (_c getVariable "sb_handler") }];
    _c
};

// ---- Ekran başlığı ----
private _header = {
    params ["_left", "_right"];
    private _w = (_sw / (_u * _asp)) - 1.6;
    [0, 0.45, _w * 0.6, 0.7, _left, _accent, 0] call _txt;
    [_w * 0.6, 0.45, _w * 0.4, 0.7, _right, _accent, 1] call _txt;
    [_w / 2, 1.1, _w, 0.05, [[0.35, 0.45, 0.33, 1], [0.55, 0.57, 0.55, 1]] select _leo] call _rect;
};

// ---- Etiket kutulu LED lamba: etiket solda, LED sağda ----
private _lamp = {
    params ["_ox", "_oy", "_name", "_col", "_code", ["_pw", 3.4]];
    ["label", _ox, _oy, _pw, 0.95, [1, 1, 1, 1], _rectTex, [0.05, 0.06, 0.05, 1]] call _spr;
    [_ox - 0.5, _oy, _pw - 1.2, 0.6, _name] call _txt;
    private _lx = _ox + _pw / 2 - 0.62;
    private _glow = [_lx call _fx, _oy call _fy, 1.15, 1.15, _dotTex, [_col select 0, _col select 1, _col select 2, 0]] call _pic;
    ["ring", _lx, _oy, 0.95, 0.95, [1, 1, 1, 1], _dotTex, [0.45, 0.46, 0.43, 1]] call _spr;
    private _lens = ["lens", _lx, _oy, 0.62, 0.62, _col, _dotTex, _col] call _spr;
    ["gloss", _lx - 0.1, _oy - 0.12, 0.55, 0.55, [1, 1, 1, 1], _dotTex, [1, 1, 1, 0]] call _spr;
    _lens setVariable ["sb_col", _col];
    _lens setVariable ["sb_glow", _glow];
    _lens setVariable ["sb_code", _code];
    _lens setVariable ["sb_fn", {
        params ["_c", "_veh"];
        private _k = _c getVariable "sb_col";
        private _on = _veh call (_c getVariable "sb_code");
        _c ctrlSetTextColor (if (_on) then {_k} else {[(_k select 0) * 0.14, (_k select 1) * 0.14, (_k select 2) * 0.14, 1]});
        (_c getVariable "sb_glow") ctrlSetTextColor [_k select 0, _k select 1, _k select 2, [0, 0.22] select _on];
    }];
    [_lens, _veh] call (_lens getVariable "sb_fn");
};

// ---- Düz yuvarlak lamba (kılavuza uygun): metal halka + lens; küçük gravür etiket altta, istenirse lens üstünde harf ----
private _lampRound = {
    params ["_ox", "_oy", "_name", "_col", "_code", ["_lensText", ""], ["_labelSide", "below"]];
    private _glow = [_ox call _fx, _oy call _fy, 1.5, 1.5, _dotTex, [_col select 0, _col select 1, _col select 2, 0]] call _pic;
    [_ringN, _ox, _oy, 1.25, 1.25, [1, 1, 1, 1], _dotTex, [0.45, 0.46, 0.43, 1]] call _spr;
    private _lens = [_lensN, _ox, _oy, 0.85, 0.85, _col, _dotTex, _col] call _spr;
    ["gloss", _ox - 0.14, _oy - 0.16, 0.7, 0.7, [1, 1, 1, 1], _dotTex, [1, 1, 1, 0]] call _spr;
    if (_lensText != "") then { [_ox, _oy, 1.1, 0.5, _lensText, [0.06, 0.05, 0.02, 1], 2, 0.4] call _txt };
    if (_name != "") then {
        switch (_labelSide) do {
            case "right": { [_ox + 0.9, _oy, 3.2, 0.5, _name, _ink, 0, 0.4] call _txt };
            case "left":  { [_ox - 0.9 - 3.2, _oy, 3.2, 0.5, _name, _ink, 1, 0.4] call _txt };
            default       { [_ox, _oy + 1.05, 2.6, 0.5, _name, _ink, 2, 0.38] call _txt };
        };
    };
    _lens setVariable ["sb_col", _col];
    _lens setVariable ["sb_glow", _glow];
    _lens setVariable ["sb_code", _code];
    _lens setVariable ["sb_fn", {
        params ["_c", "_veh"];
        private _k = _c getVariable "sb_col";
        private _on = _veh call (_c getVariable "sb_code");
        _c ctrlSetTextColor (if (_on) then {_k} else {[(_k select 0) * 0.14, (_k select 1) * 0.14, (_k select 2) * 0.14, 1]});
        (_c getVariable "sb_glow") ctrlSetTextColor [_k select 0, _k select 1, _k select 2, [0, 0.25] select _on];
    }];
    [_lens, _veh] call (_lens getVariable "sb_fn");
};

// ---- Küçük yuvarlak lamba (gerçek T-72 paneli: gövdeye gömülü, etiketsiz küçük lens; minik gravür yazı altta) ----
private _lampSmall = {
    params ["_ox", "_oy", "_name", "_col", "_code"];
    private _glow = [_ox call _fx, _oy call _fy, 1.2, 1.2, _dotTex, [_col select 0, _col select 1, _col select 2, 0]] call _pic;
    ["ring", _ox, _oy, 0.95, 0.95, [1, 1, 1, 1], _dotTex, [0.45, 0.46, 0.43, 1]] call _spr;
    private _lens = ["lens", _ox, _oy, 0.64, 0.64, _col, _dotTex, _col] call _spr;
    ["gloss", _ox - 0.1, _oy - 0.12, 0.5, 0.5, [1, 1, 1, 1], _dotTex, [1, 1, 1, 0]] call _spr;
    if (_name != "") then { [_ox, _oy + 0.85, 2.1, 0.4, _name, _ink, 2, 0.3] call _txt };
    _lens setVariable ["sb_col", _col];
    _lens setVariable ["sb_glow", _glow];
    _lens setVariable ["sb_code", _code];
    _lens setVariable ["sb_fn", {
        params ["_c", "_veh"];
        private _k = _c getVariable "sb_col";
        private _on = _veh call (_c getVariable "sb_code");
        _c ctrlSetTextColor (if (_on) then {_k} else {[(_k select 0) * 0.14, (_k select 1) * 0.14, (_k select 2) * 0.14, 1]});
        (_c getVariable "sb_glow") ctrlSetTextColor [_k select 0, _k select 1, _k select 2, [0, 0.22] select _on];
    }];
    [_lens, _veh] call (_lens getVariable "sb_fn");
};

// ---- Siyah yuvarlak buton (T-72 paneli: МЕХ-Д / СТАБИЛ / ПРИВОД): koyu başlık, açıkken ince yeşil halka ----
private _pushBlack = {
    params ["_ox", "_oy", "_name", "_act", "_stateCode"];
    ["recess", _ox, _oy, 2.1, 2.1, [1, 1, 1, 1], _dotTex, [0.1, 0.11, 0.09, 1]] call _spr;
    private _ringC = ["ring", _ox, _oy, 1.7, 1.7, [0.45, 0.46, 0.43, 1], _dotTex, [0.45, 0.46, 0.43, 1]] call _spr;
    ["knob", _ox, _oy, 1.25, 1.25, [0.16, 0.16, 0.16, 1], _dotTex, [0.12, 0.12, 0.12, 1]] call _spr;
    ["gloss", _ox - 0.2, _oy - 0.25, 0.7, 0.7, [1, 1, 1, 0.5], _dotTex, [1, 1, 1, 0]] call _spr;
    [_ox, _oy + 1.4, 3.0, 0.5, _name, _ink, 2, 0.38] call _txt;
    [_ox, _oy, 2.0, 2.0, _act] call _inv;
    _ringC setVariable ["sb_state", _stateCode];
    _ringC setVariable ["sb_fn", {
        params ["_c", "_veh"];
        _c ctrlSetTextColor (if (_veh call (_c getVariable "sb_state")) then {[0.25, 0.95, 0.35, 1]} else {[0.45, 0.46, 0.43, 1]});
    }];
    [_ringC, _veh] call (_ringC getVariable "sb_fn");
};

// ---- Kollu şalter: _angCode araç alır, kol açısı döner ----
private _toggle = {
    params ["_ox", "_oy", "_name", "_act", "_angCode", ["_sc", 1], ["_labCol", _ink]];
    ["recess", _ox, _oy, 1.7 * _sc, 1.7 * _sc, [1, 1, 1, 1], _dotTex, [0.1, 0.11, 0.09, 1]] call _spr;
    ["ring", _ox, _oy, 1.15 * _sc, 1.15 * _sc, [1, 1, 1, 1], _dotTex, [0.6, 0.62, 0.57, 1]] call _spr;
    private _lever = [[1, 1, 1, 1], "lever"] call _bar;
    _lever setVariable ["sb_geo", [_ox call _fx, _oy call _fy, _u * 1.0 * _sc, _u * 0.3 * _sc, _asp, _sgn]];
    _lever setVariable ["sb_ang", _angCode];
    _lever setVariable ["sb_fn", {
        params ["_c", "_veh"];
        (_c getVariable "sb_geo") params ["_x0", "_y0", "_len", "_th", "_a", "_s"];
        [_c, _x0, _y0, _len, _th, _veh call (_c getVariable "sb_ang"), _a, _s] call SB_fnc_placeRect;
    }];
    [_lever, _veh] call (_lever getVariable "sb_fn");
    [_ox, _oy + 1.55 * _sc, 2.6, 0.5, _name, _labCol, 2, [0.4, 0.32] select (_sc < 0.9)] call _txt;
    [_ox, _oy, 1.8 * _sc, 2.3 * _sc, _act] call _inv;
};

// ---- Dönel seçici: _pos = [[etiket, eylem, açı], ...] ----
private _rotary = {
    params ["_ox", "_oy", "_pos", "_idxCode", ["_sc", 1]];
    ["recess", _ox, _oy, 3.3 * _sc, 3.3 * _sc, [1, 1, 1, 1], _dotTex, [0.1, 0.11, 0.09, 1]] call _spr;
    ["knob", _ox, _oy, 2.6 * _sc, 2.6 * _sc, [1, 1, 1, 1], _dotTex, [0.5, 0.52, 0.48, 1]] call _spr;
    ["recess", _ox, _oy, 1.5 * _sc, 1.5 * _sc, [1, 1, 1, 1], _dotTex, [0.12, 0.13, 0.11, 1]] call _spr;
    private _ptr = [[0.95, 0.95, 0.9, 1]] call _bar;
    {
        _x params ["_name", "_act", "_ang"];
        private _lx = _ox + (sin _ang) * 2.45 * _sc;
        private _ly = _oy - (cos _ang) * 2.45 * _sc;
        [_lx, _ly, 1.8 * _sc, 0.5, _name, _ink, 2, [0.46, 0.38] select (_sc < 0.9)] call _txt;
        [_lx, _ly, 1.9 * _sc, 1.0, _act] call _inv;
    } forEach _pos;
    _ptr setVariable ["sb_geo", [_ox call _fx, _oy call _fy, _u * 1.0 * _sc, _u * 0.26 * _sc, _asp, _sgn]];
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

// ---- Gösterge: kadran dokuya pişirilmiştir (çentik/rakam), ibre dinamik ----
private _gauge = {
    params ["_ox", "_oy", "_r", "_texName", "_max", "_a0", "_a1", "_valCode", "_needleCol", "_faceCol", ["_nl", 0.82]];
    private _D = _r * 2 / 0.9;
    [_texName, _ox, _oy, _D, _D, [1, 1, 1, 1], _dotTex, _faceCol] call _spr;
    private _n = [_needleCol] call _bar;
    _n setVariable ["sb_geo", [_ox call _fx, _oy call _fy, _r * _nl * _u, _r * _nl * _u * 0.16, _asp, _sgn, _a0, _a1, _max]];
    _n setVariable ["sb_val", _valCode];
    _n setVariable ["sb_fn", {
        params ["_c", "_veh"];
        (_c getVariable "sb_geo") params ["_x0", "_y0", "_len", "_th", "_a", "_s", "_a0", "_a1", "_max"];
        private _v = (_veh call (_c getVariable "sb_val")) max 0 min _max;
        [_c, _x0, _y0, _len, _th, _a0 + (_a1 - _a0) * (_v / _max), _a, _s] call SB_fnc_placeRect;
    }];
    [_n, _veh] call (_n getVariable "sb_fn");
    ["knob", _ox, _oy, 0.55, 0.55, [0.7, 0.7, 0.7, 1], _dotTex, [0.2, 0.2, 0.2, 1]] call _spr;
};

// ---- Basma düğmesi (yuvarlak, parlak başlıklı) ----
private _push = {
    params ["_ox", "_oy", "_name", "_act", ["_cap", [0.72, 0.1, 0.1, 1]]];
    ["recess", _ox, _oy, 2.0, 2.0, [1, 1, 1, 1], _dotTex, [0.1, 0.11, 0.09, 1]] call _spr;
    ["ring", _ox, _oy, 1.65, 1.65, [1, 1, 1, 1], _dotTex, [0.5, 0.52, 0.48, 1]] call _spr;
    ["lens", _ox, _oy, 1.2, 1.2, _cap, _dotTex, _cap] call _spr;
    ["gloss", _ox - 0.2, _oy - 0.25, 0.8, 0.8, [1, 1, 1, 1], _dotTex, [1, 1, 1, 0]] call _spr;
    [_ox, _oy, 2.0, 2.0, _act] call _inv;
    [_ox, _oy + 1.4, 3.2, 0.5, _name] call _txt     // etiket denetimini döndürür (dinamik metin için)
};

// ---- 7 segmentli ekran: n hane, k ölçek, _codeText araç alır, metin döner ----
private _sevenSeg = {
    params ["_ox", "_oy", "_codeText", ["_n", 4], ["_k", 1]];
    private _wD = 1.0 * _k; private _hD = 1.9 * _k; private _t = 0.2 * _k; private _step = 1.35 * _k;
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
    for "_i" from 0 to (_n - 1) do {
        private _segs = [];
        { _x params ["_dx", "_dy", "_w", "_h"];
            _segs pushBack ([_ox + _i * _step + _dx, _oy + _dy, _w, _h, [0.2, 0.02, 0.02, 1]] call _rect);
        } forEach _segDef;
        _digits pushBack _segs;
    };
    private _holder = [_ox, _oy, 0.01, 0.01, [0, 0, 0, 0]] call _rect;
    _holder setVariable ["sb_digits", _digits];
    _holder setVariable ["sb_text", _codeText];
    _holder setVariable ["sb_n", _n];
    _holder setVariable ["sb_fn", {
        params ["_c", "_veh"];
        private _n = _c getVariable "sb_n";
        private _txt = _veh call (_c getVariable "sb_text");
        while {count _txt < _n} do { _txt = " " + _txt };
        private _map = createHashMapFromArray [
            ["0", "abcdef"], ["1", "bc"], ["2", "abged"], ["3", "abgcd"], ["4", "fgbc"],
            ["5", "afgcd"], ["6", "afgedc"], ["7", "abc"], ["8", "abcdefg"], ["9", "abcdfg"], ["-", "g"], [" ", ""],
            ["A", "abcefg"], ["F", "aefg"], ["b", "cdefg"], ["d", "bcdeg"]
        ];
        {
            private _on = _map getOrDefault [_txt select [_forEachIndex, 1], ""];
            private _seg = _x;
            { _seg select _forEachIndex ctrlSetTextColor ([[0.2, 0.02, 0.02, 1], [1, 0.16, 0.1, 1]] select (("abcdefg" select [_forEachIndex, 1]) in _on)) } forEach _seg;
        } forEach (_c getVariable "sb_digits");
    }];
    [_holder, _veh] call (_holder getVariable "sb_fn");
};

// ---- Cam yansıması: en son çizilir (en üstte) ----
private _finish = {
    ["glass", (_sx + _sw / 2 - _bx) / (_u * _asp), (_sy + _sh / 2 - _by) / _u, _sw / (_u * _asp), _sh / _u, [1, 1, 1, 1], _rectTex, [0, 0, 0, 0]] call _spr;
    private _dk = (missionNamespace getVariable ["SB_TankUI_dirt", 60]) / 100;
    if (_dk > 0) then {
        ["dirt", (_sx + _sw / 2 - _bx) / (_u * _asp), (_sy + _sh / 2 - _by) / _u, _sw / (_u * _asp), _sh / _u, [1, 1, 1, _dk], _rectTex, [0, 0, 0, 0]] call _spr;
    };
    uiNamespace setVariable ["SB_TankUI_ctrls", _ctrls];
};

private _green = [0.25, 0.95, 0.35, 1];
private _amber = [1, 0.72, 0.15, 1];
private _red = [0.95, 0.2, 0.15, 1];
