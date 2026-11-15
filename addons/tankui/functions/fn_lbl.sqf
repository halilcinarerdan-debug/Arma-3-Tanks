/*
 * Etiket çözücü. params: [anahtar] -> metin
 * Dil: CBA ayarı SB_TankUI_labelLang (0 = araç dili, 1 tr, 2 en, 3 ru, 4 de).
 * Araç dili profilin "language" alanından gelir (T-72: ru, Leopard: de, M1/Challenger: en, genel: tr).
 * Anahtarlar stringtable.xml içinde STR_SB_<dil>_<anahtar>; her dil ayrı anahtar olduğu için oyun dilinden bağımsızdır.
 */
params ["_key"];
private _set = missionNamespace getVariable ["SB_TankUI_labelLang", 0];
private _lang = ["", "tr", "en", "ru", "de"] select (_set max 0 min 4);
if (_lang == "") then {
    private _veh = uiNamespace getVariable ["SB_TankUI_vehicle", vehicle player];
    private _profile = [_veh] call SB_fnc_getProfile;
    _lang = getText (_profile >> "language");
    if (_lang == "") then { _lang = "tr" };
};
private _k = format ["STR_SB_%1_%2", _lang, _key];
if (isLocalized _k) exitWith { localize _k };
private _fb = format ["STR_SB_en_%1", _key];
if (isLocalized _fb) exitWith { localize _fb };
_key
