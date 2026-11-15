/*
 * T-72 sürücü istasyonu. NOT: Steel Beasts kılavuzunda T-72M1 sürücü paneli modellenmemiş (yalnızca kapak görüntüsü);
 * bu ekran gerçek aracın sürücü göstergelerine ve Arma'nın verebildiği canlı verilere göre tasarlandı.
 * Gerçek veri: hız, yakıt, motor, arıza lambaları (hasar). Eylemler: motor aç/kapa, farlar, kapak (aç/kapat).
 */
params ["_display"];
private _veh = uiNamespace getVariable "SB_TankUI_vehicle";
#include "\z\tank33\addons\tankui\kit.sqf"

[getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName") + "  |  " + ("SCR_STATION" call _L), _roleLabel] call _header;

// hız göstergesi (0-80 km/h) + 7 segment
[5.6, 8.2, 4.2, "gauge_speed", 80, -120, 120, compile "abs speed _this", [0.85, 0.15, 0.1, 1], [0.9, 0.9, 0.85, 1]] call _gauge;
[5.6, 12.9, 4, 0.5, "SPEED" call _L, _ink, 2, 0.45] call _txt;
["display", 5.6, 15.3, 5.0, 2.2, [1, 1, 1, 1], _rectTex, [0.02, 0.02, 0.02, 1]] call _spr;
[4.4, 15.3, compile "str round abs speed _this", 3, 0.9] call _sevenSeg;

// yakıt
[14.0, 4.6, 2.3, "gauge_fuel", 4, -60, 60, compile "(fuel _this) * 4", [0.05, 0.05, 0.05, 1], [0.9, 0.9, 0.85, 1]] call _gauge;
[14.0, 7.6, 4, 0.5, "FUEL" call _L, _ink, 2, 0.45] call _txt;

// lambalar: motor çalışıyor + arıza lambaları (ilgili bölgenin hasarı >= %30)
[11.8, 9.8, "L_RUN" call _L, _green, {isEngineOn _this}] call _lampRound;
[12.9, 8.6, 5, 0.5, "FAULT" call _L, [0.62, 0.78, 0.58, 1], 2, 0.45] call _txt;
[14.8, 9.8, "F_ENG" call _L, _red,  {([_this, "hitengine"] call SB_fnc_getHit) >= 0.3}] call _lampRound;
[17.0, 9.8, "F_LTR" call _L, _red,  {([_this, "hitltrack"] call SB_fnc_getHit) >= 0.3}] call _lampRound;
[19.2, 9.8, "F_RTR" call _L, _red,  {([_this, "hitrtrack"] call SB_fnc_getHit) >= 0.3}] call _lampRound;
[11.8, 12.2, "F_HULL" call _L, _red, {([_this, "hithull"] call SB_fnc_getHit) >= 0.3}] call _lampRound;

// şalterler. isLightOn / isTurnedOut doğrulanamadı: derleme hatası yalnızca o şalteri etkilesin diye compile ile
[12.6, 14.6, "T_ENGINE" call _L, "engine", {[180, 0] select (isEngineOn _this)}] call _toggle;
[15.6, 14.6, "T_LIGHT" call _L, "lights", compile "[180, 0] select (isLightOn _this)"] call _toggle;
[18.6, 14.6, "T_HATCH" call _L, "hatch", compile "[180, 0] select (isTurnedOut player)"] call _toggle;

call _finish;
