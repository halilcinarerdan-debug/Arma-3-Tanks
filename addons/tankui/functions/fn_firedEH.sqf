/*
 * Atış olayı (CBA Fired, sınıf Tank): panel durumuna göre merminin yönünü bozar.
 *  - Stabilizasyon etkin değilken HAREKET halinde atış: yatay/düşey rastgele sapma (hızla artar, 30 km/h ve üstünde azami)
 *  - Balistik anahtarı yüklü mermiden farklı tipe indeksliyse: düşey yönde sabit sapma (indeks KE ise kısa, değilse uzun)
 * Yalnızca istasyon ekranı bu araçta bir kez açıldıysa (SB_armed) devreye girer; CBA ayarı ile kapatılabilir/ölçeklenir.
 * Fired olayı silahın yerel olduğu makinede çalışır; mermi yerel olduğu için setVelocity geçerlidir.
 */
// Parametre sırasına güvenmeyiz (bir sürümde mermi yerine dizgi geldi): nesneleri ve dizgileri türüne göre ayıkla.
// Nesneler sırayla: araç, mermi, (atan); dizgiler: ... ammo, magazine (son ikisi).
private _objs = _this select { _x isEqualType objNull };
private _strs = _this select { _x isEqualType "" };
if (count _objs < 2 || {count _strs < 2}) exitWith {
    if !(missionNamespace getVariable ["SB_firedLogged", false]) then {
        missionNamespace setVariable ["SB_firedLogged", true];
        diag_log format ["[SB_TankUI] firedEH beklenmeyen parametreler: %1", _this];
    };
};
private _veh = _objs select 0;
private _proj = _objs select 1;
private _gunner = _objs param [2, objNull];
private _ammo = _strs select (count _strs - 2);
private _mag = _strs select (count _strs - 1);
if (isNull _proj) exitWith {};
if !(missionNamespace getVariable ["SB_TankUI_effects", true]) exitWith {};
if !(_veh getVariable ["SB_armed", false]) exitWith {};

// yalnızca topçu mermisi/kurşun (füze, duman vb. hariç)
private _sim = toLower getText (configFile >> "CfgAmmo" >> _ammo >> "simulation");
if !(_sim in ["shotshell", "shotbullet"]) exitWith {};

private _scale = (missionNamespace getVariable ["SB_TankUI_effectScale", 100]) / 100;
private _sigma = 0;
if (!(call SB_fnc_realStab) && {!([_veh] call SB_fnc_stabEffective)}) then {
    _sigma = ((abs speed _veh) / 30 min 1) * 0.5;          // derece (~8.7 mil azami)
};

private _bias = 0;
private _ovr = _veh getVariable ["SB_ballOvr", ""];
private _loaded = [_mag] call SB_fnc_ammoClass;
if (_ovr != "" && {_ovr != _loaded} && {_loaded in ["KE", "HE", "HEAT"]}) then {
    _bias = 0.35 * ([1, -1] select (_ovr == "KE"));         // KE indeksliyken diğer mermi: kısa (-); tersi: uzun (+)
};

// Balistik girişler (isteğe bağlı, Leopard 2): girilen değerler gerçek ortamdan saptıkça atış kayar. Basit oyun dengesi modeli (fizik değil).
private _dEl = 0;
private _dAz = 0;
if ((missionNamespace getVariable ["SB_TankUI_ballInputs", false]) && {([_veh, "ballInputs", 0] call SB_fnc_tProfile) > 0}) then {
    private _env = [_veh] call SB_fnc_ballEnv;
    private _r = [_veh] call SB_fnc_rangeValue;
    private _km = (if (_r > 0) then {_r} else {1500}) / 1000;
    private _eAir = ([_veh, "air"] call SB_fnc_ballInput) - (_env select 0);
    private _ePow = ([_veh, "pow"] call SB_fnc_ballInput) - (_env select 0);
    private _eAlt = ([_veh, "alt"] call SB_fnc_ballInput) - (_env select 1);
    private _eWind = (_env select 2) - ([_veh, "wind"] call SB_fnc_ballInput);
    _dEl = ((_eAir * 0.03) + (_ePow * 0.05) + (_eAlt * 0.02)) * _km * 0.0573;      // mil -> derece
    _dAz = _eWind * 0.12 * _km * 0.0573;
};

if (_sigma == 0 && {_bias == 0} && {_dEl == 0} && {_dAz == 0}) exitWith {};

private _v = velocity _proj;
private _spd = vectorMagnitude _v;
if (_spd < 1) exitWith {};
private _dir = vectorNormalized _v;
// not: atan2 adlandırılmış ikili operatör, + işleminden ÖNCE çözülür; bu yüzden parantezli
private _az = ((_dir select 0) atan2 (_dir select 1)) + ((((random 2) - 1) * _sigma + _dAz) * _scale);
private _el = (asin (_dir select 2)) + ((((random 2) - 1) * _sigma) + _bias + _dEl) * _scale;
_proj setVelocity [_spd * (sin _az) * (cos _el), _spd * (cos _az) * (cos _el), _spd * (sin _el)];

// bilgilendirme: en fazla 30 sn'de bir, yalnızca atışı yapan oyuncuya
if ((_gunner isEqualTo player) && {time > (_veh getVariable ["SB_devMsgAt", 0])}) then {
    _veh setVariable ["SB_devMsgAt", time + 30];
    systemChat (if (_sigma > 0) then {"T-72: stabilizasyon etkin degil, hareket halinde atis saptı."} else {"T-72: balistik anahtari yuklu mermiye uymuyor, atis saptı."});
};
