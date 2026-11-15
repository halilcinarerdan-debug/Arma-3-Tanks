/*
 * Atış olayı (CBA Fired, sınıf Tank): panel durumuna göre merminin yönünü bozar.
 *  - Stabilizasyon etkin değilken HAREKET halinde atış: yatay/düşey rastgele sapma (hızla artar, 30 km/h ve üstünde azami)
 *  - Balistik anahtarı yüklü mermiden farklı tipe indeksliyse: düşey yönde sabit sapma (indeks KE ise kısa, değilse uzun)
 * Yalnızca istasyon ekranı bu araçta bir kez açıldıysa (SB_armed) devreye girer; CBA ayarı ile kapatılabilir/ölçeklenir.
 * Fired olayı silahın yerel olduğu makinede çalışır; mermi yerel olduğu için setVelocity geçerlidir.
 */
params ["_veh", "_weapon", "_muzzle", "_mode", "_ammo", "_mag", "_proj", ["_gunner", objNull]];
if (isNull _proj) exitWith {};
if !(missionNamespace getVariable ["SB_TankUI_effects", true]) exitWith {};
if !(_veh getVariable ["SB_armed", false]) exitWith {};

// yalnızca topçu mermisi/kurşun (füze, duman vb. hariç)
private _sim = toLower getText (configFile >> "CfgAmmo" >> _ammo >> "simulation");
if !(_sim in ["shotshell", "shotbullet"]) exitWith {};

private _scale = (missionNamespace getVariable ["SB_TankUI_effectScale", 100]) / 100;
private _sigma = 0;
if !([_veh] call SB_fnc_stabEffective) then {
    _sigma = ((abs speed _veh) / 30 min 1) * 0.5;          // derece (~8.7 mil azami)
};

private _bias = 0;
private _ovr = _veh getVariable ["SB_ballOvr", ""];
private _loaded = [_mag] call SB_fnc_ammoClass;
if (_ovr != "" && {_ovr != _loaded} && {_loaded in ["KE", "HE", "HEAT"]}) then {
    _bias = 0.35 * ([1, -1] select (_ovr == "KE"));         // KE indeksliyken diğer mermi: kısa (-); tersi: uzun (+)
};

if (_sigma == 0 && {_bias == 0}) exitWith {};

private _v = velocity _proj;
private _spd = vectorMagnitude _v;
if (_spd < 1) exitWith {};
private _dir = vectorNormalized _v;
// not: atan2 adlandırılmış ikili operatör, + işleminden ÖNCE çözülür; bu yüzden parantezli
private _az = ((_dir select 0) atan2 (_dir select 1)) + (((random 2) - 1) * _sigma * _scale);
private _el = (asin (_dir select 2)) + (((random 2) - 1) * _sigma + _bias) * _scale;
_proj setVelocity [_spd * (sin _az) * (cos _el), _spd * (cos _az) * (cos _el), _spd * (sin _el)];

// bilgilendirme: en fazla 30 sn'de bir, yalnızca atışı yapan oyuncuya
if ((_gunner isEqualTo player) && {time > (_veh getVariable ["SB_devMsgAt", 0])}) then {
    _veh setVariable ["SB_devMsgAt", time + 30];
    systemChat (if (_sigma > 0) then {"T-72: stabilizasyon etkin degil, hareket halinde atis saptı."} else {"T-72: balistik anahtari yuklu mermiye uymuyor, atis saptı."});
};
