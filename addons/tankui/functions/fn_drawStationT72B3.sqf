/*
 * T-72B3 (2012) nişancı istasyonu. Düzen, Steel Beasts T-72 görüntülerindeki parça şekillerine göre 2B çizildi (kendi çizimimiz).
 * Her parça tabletten tıklanabilir. Oyuna etkisi olanlar: lamba matrisi, МЕХ-Д / СТАБИЛ / ПРИВОД, Б-К-О mermi seçimi, Д (LRF) şalteri,
 * РУЧ/АВТ (yükleyici) şalteri, menzil ekranı, mermi sayacı. Diğer tüm parçalar yalnızca görsel durumdur (şekil ve tık hissi korunur,
 * etkisi bilinmediği için oyuna dokunmaz). Taales paneli bilerek çizilmedi.
 */
params ["_display"];
private _veh = uiNamespace getVariable "SB_TankUI_vehicle";
#include "\z\tank33\addons\tankui\kit.sqf"

_veh setVariable ["SB_armed", true, true];
[getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName") + "  |  " + ("SCR_STATION" call _L), _roleLabel] call _header;
private _violet = [0.6, 0.35, 1, 1];
private _yel = [1, 0.85, 0.15, 1];
private _dk = [0.08, 0.09, 0.09, 1];
private _wh = [0.92, 0.92, 0.9, 1];

// ---- yardımcılar ----
private _key = {                                   // siyah dikdörtgen tuş (sol-üst köşe), metin ortada
    params ["_ox", "_oy", "_w", "_h", "_text", "_act", ["_fs", 0.34]];
    ["label", _ox + _w / 2, _oy + _h / 2, _w, _h, [1, 1, 1, 1], _rectTex, [0.08, 0.08, 0.08, 1]] call _spr;
    [_ox + _w / 2, _oy + _h / 2, _w - 0.1, _h * 0.8, _text, _wh, 2, _fs] call _txt;
    [_ox + _w / 2, _oy + _h / 2, _w, _h, _act] call _inv;
};
private _lampSide = {                              // küçük lamba + sağda yazı
    params ["_ox", "_oy", "_name", "_col", "_code", ["_ink2", _dk]];
    [_ox, _oy, "", _col, _code] call _lampSmall;
    [_ox + 0.65, _oy, 2.4, 0.4, _name, _ink2, 0, 0.3] call _txt;
};
private _vt = {                                    // görsel şalter (küçük; açık plakada koyu yazı)
    params ["_ox", "_oy", "_name", "_k", ["_labCol", _dk]];
    [_ox, _oy, _name, "vis_" + _k, compile format ["[0, 180] select (_this getVariable ['vis_%1', false])", _k], 0.65, _labCol] call _toggle;
};
private _vkey = {                                   // lambalı görsel tuş (РС1…): üstte küçük lamba
    params ["_ox", "_oy", "_w", "_text", "_k"];
    [_ox + _w / 2, _oy - 0.55, "", _amber, compile format ["_this getVariable ['vis_%1', false]", _k]] call _lampSmall;
    [_ox, _oy, _w, 0.9, _text, "vis_" + _k, 0.3] call _key;
};
private _pbSmall = {                                // küçük siyah yuvarlak buton (görsel)
    params ["_ox", "_oy", "_name", "_k"];
    ["recess", _ox, _oy, 1.3, 1.3, [1, 1, 1, 1], _dotTex, [0.1, 0.11, 0.09, 1]] call _spr;
    private _rg = ["ring", _ox, _oy, 1.05, 1.05, [0.45, 0.46, 0.43, 1], _dotTex, [0.45, 0.46, 0.43, 1]] call _spr;
    ["knob", _ox, _oy, 0.75, 0.75, [0.16, 0.16, 0.16, 1], _dotTex, [0.12, 0.12, 0.12, 1]] call _spr;
    [_ox, _oy + 0.95, 1.8, 0.4, _name, _ink, 2, 0.28] call _txt;
    [_ox, _oy, 1.4, 1.4, "vis_" + _k] call _inv;
    _rg setVariable ["sb_k", "vis_" + _k];
    _rg setVariable ["sb_fn", { params ["_c", "_veh"]; _c ctrlSetTextColor (if (_veh getVariable [_c getVariable "sb_k", false]) then {[0.25, 0.95, 0.35, 1]} else {[0.45, 0.46, 0.43, 1]}) }];
    [_rg, _veh] call (_rg getVariable "sb_fn");
};

// ================= A: СОСНА-У paneli (açık gri plaka) =================
private _lg = [0.66, 0.68, 0.68, 1];
[0.1, 1.6, 5.7, 13.9, [0.05, 0.05, 0.05, 1]] call _box;
[0.25, 1.75, 5.4, 13.6, _lg] call _box;
[3.0, 2.15, 3, 0.4, "ГОТОВ", _dk, 2, 0.3] call _txt;
{
    _x params ["_n", "_cx", "_cy"];
    [_cx, _cy, _n, _yel, {true}, _dk] call _lampSide;
} forEach [["ССУ", 0.9, 2.9], ["БВ", 0.9, 3.7], ["Д", 0.9, 4.5], ["У", 3.0, 2.9], ["АВТОМАТ", 3.0, 3.7], ["ОБОГРЕВ", 3.0, 4.5]];
[1.0, 6.1, "Д.У.", "du"] call _vt;
[2.9, 6.1, "↔", "vyv1"] call _vt;
[4.6, 6.1, "↕", "vyv2"] call _vt;
[3.2, 7.8, 4, 0.35, "ВЫВЕРКА Д", _dk, 2, 0.3] call _txt;
[1.2, 8.6, "4x / 12x", "zoom"] call _vt;
[0.5, 10.0, 2.5, 0.9, "МЕНЮ", "vis_menu", 0.34] call _key;
[3.1, 10.0, 2.5, 0.9, "ЗАПИСЬ", "vis_rec", 0.26] call _key;
[0.5, 11.0, 2.5, 0.9, "−", "vis_minus", 0.5] call _key;
[3.1, 11.0, 2.5, 0.9, "+", "vis_plus", 0.5] call _key;
[1.2, 12.0, 3.2, 0.9, "ВОЗВРАТ", "vis_ret", 0.3] call _key;
[1.2, 13.7, "АВТОМАТ", "auto2"] call _vt;

// ================= B: РС / АСЦ / монитор / Д, РУЧ-АВТ / menzil =================
[6.0, 1.6, 7.4, 2.4, [0.05, 0.05, 0.05, 1]] call _box;
{
    _x params ["_t", "_k"];
    [6.15 + _forEachIndex * 1.45, 3.0, 1.3, _t, _k] call _vkey;
} forEach [["РС1", "rs1"], ["РС2", "rs2"], ["РС3", "rs3"], ["РС4", "rs4"], ["ВС", "vs"]];
[7.0, 5.6, "АСЦ", "asc", _ink] call _vt;
["display", 10.6, 6.3, 4.2, 2.8, [1, 1, 1, 1], _rectTex, [0.04, 0.04, 0.04, 1]] call _spr;
[10.6, 7.0, 4.0, 1.3, [0.55, 0.56, 0.56, 1]] call _rect;
[9.5, 7.5, 1.6, 0.35, "ССУ ВКЛ", _wh, 2, 0.28] call _txt;
[13.0, 5.2, 0.8, 0.8, "+", "vis_mp", 0.4] call _key;
[13.0, 6.2, 0.8, 0.8, "−", "vis_mm", 0.4] call _key;
[13.0, 7.2, 0.8, 0.8, "*", "vis_mb", 0.32] call _key;

[6.5, 9.4, "", _yel, {_this getVariable ["SB_lrfOn", false]}] call _lampSmall;
[7.9, 9.5, "Д", "lrfon", {[180, 0] select (_this getVariable ["SB_lrfOn", false])}, 0.65] call _toggle;
[6.5, 11.4, "", _green, {!(_this getVariable ["SB_manual", false])}] call _lampSmall;
[7.9, 11.5, "РУЧ / АВТ", "automan", {[0, 180] select (_this getVariable ["SB_manual", false])}, 0.65] call _toggle;
["display", 11.4, 10.2, 4.2, 1.9, [1, 1, 1, 1], _rectTex, [0.02, 0.02, 0.02, 1]] call _spr;
[9.94, 10.2, compile "[_this] call SB_fnc_rangeText", 4, 0.72] call _sevenSeg;
[9.6, 12.8, "ЛАЗЕР" call _L, "lase", [0.45, 0.45, 0.45, 1]] call _push;
[12.0, 12.8, "RESET" call _L, "reset", [0.15, 0.15, 0.15, 1]] call _push;

// ================= C: klasik blok =================
["label", 17.2, 3.4, 6.0, 3.4, [1, 1, 1, 1], _rectTex, [0.05, 0.06, 0.05, 1]] call _spr;
[15.3, 2.5, "L_STAB" call _L,   _green,  {[_this] call SB_fnc_stabEffective}] call _lampSmall;
[17.2, 2.5, "L_MIRROR" call _L, _red,    {(_this getVariable ["SB_hydr", false]) && {_this getVariable ["SB_mirror", false]} && {serverTime - (_this getVariable ["SB_hydrOn", 0]) >= 120}}] call _lampSmall;
[19.1, 2.5, "L_HYDR" call _L,   _green,  {_this getVariable ["SB_hydr", false]}] call _lampSmall;
[15.3, 4.2, "L_TC" call _L,     _red,    {false}] call _lampSmall;
[17.2, 4.2, "L_DELTA" call _L,  _red,    {_this getVariable ["SB_delta", false]}] call _lampSmall;
[19.1, 4.2, "L_LOADED" call _L, _violet, {(_this ammo (_this currentWeaponTurret (uiNamespace getVariable ["SB_TankUI_turret", [0]]))) > 0}] call _lampSmall;
["label", 15.7, 5.85, 3.2, 0.7, [1, 1, 1, 1], _rectTex, [0.04, 0.05, 0.04, 1]] call _spr;
[14.95, 5.85, 1.4, 0.4, "РУЧ", [0.25, 0.7, 0.3, 1], 2, 0.3] call _txt;
[16.5, 5.85, 1.6, 0.4, "ПОДДОН", [0.8, 0.2, 0.15, 1], 2, 0.3] call _txt;
[18.3, 5.8, "ВКЛ.А", "vkla"] call _pbSmall;
[19.6, 5.8, "АВТ/РУЧ", "avtruch"] call _pbSmall;
[14.9, 8.0, "T_DELTA" call _L, "delta", {_this getVariable ["SB_delta", false]}] call _pushBlack;
[17.0, 8.0, "T_STAB" call _L, "stab", {_this getVariable ["SB_stab", false]}] call _pushBlack;
[19.1, 8.0, "T_HYDR" call _L, "hydr", {_this getVariable ["SB_hydr", false]}] call _pushBlack;
private _selPos = [
    ["ЗАГР", "visrot_0", -120], ["О", "sel_HE", -80], ["Б", "sel_KE", -40], ["К", "sel_HEAT", 0], ["П", "visrot_4", 40], ["У", "visrot_5", 80], ["УН", "visrot_6", 120]
];
[16.0, 12.0, _selPos, compile "
    private _v = _this getVariable ['SB_visRot', -1];
    if (_v >= 0) then {_v} else { switch (_this getVariable ['SB_selType', '']) do { case 'HE': {1}; case 'KE': {2}; case 'HEAT': {3}; default {0} } }
", 0.62] call _rotary;
private _pl = [19.2, 11.1, "LOAD" call _L, "load", [0.2, 0.6, 0.25, 1]] call _push;
_pl setVariable ["sb_fn", { params ["_c", "_veh"]; _c ctrlSetText ((["LOAD", "LOADING"] select ([_veh] call SB_fnc_isLoading)) call SB_fnc_lbl) }];
[_pl, _veh] call (_pl getVariable "sb_fn");
[19.2, 14.55, 0.95, "gauge_ammo", 11, -115, 115, compile "
    private _t = uiNamespace getVariable ['SB_TankUI_turret', [0]];
    private _sel = _this getVariable ['SB_selType', ''];
    if (_sel != '') then { [_this, _t, _sel] call SB_fnc_ammoCount } else {
        22 - (([_this, _t, 'KE'] call SB_fnc_ammoCount) + ([_this, _t, 'HEAT'] call SB_fnc_ammoCount) + ([_this, _t, 'HE'] call SB_fnc_ammoCount))
    }
", [0.05, 0.05, 0.05, 1], [0.9, 0.9, 0.85, 1]] call _gauge;

call _finish;
