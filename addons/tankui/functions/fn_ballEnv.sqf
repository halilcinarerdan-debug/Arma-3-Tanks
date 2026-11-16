/*
 * Gerçek ortam değerleri (balistik bilgisayar girişlerinin "doğrusu").
 * params: [araç] -> [havaSıcaklığı °C, yükseklik (x10 m), yanRüzgâr m/s (+ = sağa doğru esiyor)]
 * Hava sıcaklığı: ACE Weather açıksa "ace_weather_currentTemperature" (doğrulanmadı, yoksa yedek), değilse ambientTemperature.
 * Rüzgâr: oyunun rüzgârı (wind), silah yönüne dik bileşen. ACE Weather rüzgârı oyun rüzgârına yazar.
 */
params ["_veh"];
private _t = missionNamespace getVariable ["ace_weather_currentTemperature", -999];
if !(_t isEqualType 0) then { _t = -999 };
if (_t == -999) then {
    private _a = ambientTemperature;
    _t = if (_a isEqualType []) then { _a param [0, 15] } else { _a };
};
private _alt = round (((getPosASL _veh) select 2) / 10);
private _d = _veh weaponDirection (currentWeapon _veh);
private _dx = _d select 0;
private _dy = _d select 1;
private _n = (sqrt ((_dx * _dx) + (_dy * _dy))) max 0.001;
private _w = wind;
private _cross = ((_w select 0) * (_dy / _n)) + ((_w select 1) * (-_dx / _n));
[round _t, _alt, round _cross]
