/*
 * Top stabilizasyonunu çalışma anında ayarlar (wiki doğrulandı, Arma 2.22+):
 *   vehicle enableGunStabilization [mode, turretPath]
 *   mode: -1 geçersiz kılmayı temizle, 0 yok, 1 yükseliş, 2 yatay, 3 ikisi birden
 * Bu dosya BİLEREK ayrı: komut yoksa (eski sürüm) yalnızca bu işlev etkilenir. Çağıran taraf sürümü kontrol eder
 * ((productVersion select 2) >= 222). Etki alanı belirtilmemiş: hem burada hem araç sahibinde uygulanır (idempotent).
 * params: [araç, turretPath, mod]
 */
params ["_veh", "_turret", "_mode"];
_veh enableGunStabilization [_mode, _turret];
["SB_TankUI_gunStab", [_veh, _turret, _mode], _veh] call CBA_fnc_targetEvent;
