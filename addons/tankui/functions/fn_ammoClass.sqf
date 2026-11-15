/*
 * params: [magClass] -> "KE" | "HEAT" | "HE" | "ATGM" | "OTHER"
 * Sınıf/ekran adı + CfgAmmo warheadName ile sezgisel sınıflandırma.
 * CUP gerçek sınıfları görüldükçe desenler sıkılaştırılacak.
 */
params ["_mag"];
private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
private _wh = toLower getText (configFile >> "CfgAmmo" >> _ammo >> "warheadName");
private _s = toLower (_mag + " " + getText (configFile >> "CfgMagazines" >> _mag >> "displayName") + " " + _ammo);

// füzeler (ATGM) top mermisi tipi değildir; kendi satırında adıyla görünür
if ((toLower getText (configFile >> "CfgAmmo" >> _ammo >> "simulation")) == "shotmissile") exitWith {"ATGM"};
if ((_s find "smoke") >= 0) exitWith {"OTHER"};
if ((_s find "apfsds") >= 0 || {(_s find "sabot") >= 0} || {(_s find "_ap_") >= 0}) exitWith {"KE"};
if ((_s find "heat") >= 0 || {_wh find "heat" >= 0}) exitWith {"HEAT"};
// "he" tek başına "launcher" gibi kelimelerle çakışır; bu yüzden belirgin desenler aranır
if (_wh == "he" || {{(_s find _x) >= 0} count ["mmhe", "_he_", "_he ", "hef", "frag"] > 0}) exitWith {"HE"};
"OTHER"
