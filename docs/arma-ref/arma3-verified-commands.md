# Arma 3: wiki'de doğrulanmış komut sözdizimleri

Kaynak: Bohemia Interactive Community Wiki sayfaları (ekran görüntüleri kullanıcı tarafından sağlandı, Kasım 2026).
Bu projede kullanılan her komutun burada kayıtlı sözdizimine uyduğundan emin olun; burada olmayan komutları tahminle yazmayın.
Ham eylem listesi: `arma3-actions-raw.txt`.

## Taret / silah

| Komut | Sözdizimi | Notlar |
|---|---|---|
| `setTurretLimits` (2.12) | `vehicle setTurretLimits [turret, minTurn, maxTurn, minElev, maxElev, soft]` ; sıfırlama: `vehicle setTurretLimits [turret]` | Argüman **yerel**, etki **global**. Derece cinsinden, tareti **modelin yönüne göre**: minTurn 0..-açı (sol), maxTurn 0..+açı (sağ), minElev 0..-açı (aşağı), maxElev 0..+açı (yukarı). Yalnızca config sınırları içinde. `soft` (2.22, opsiyonel): true = sınıra yumuşak git, false = anında. |
| `enableDirectionStabilization` (2.06) | `vehicle enableDirectionStabilization [enabled, turretPath]` | turretPath opsiyonel (verilmezse birincil taret). **Yalnızca seçili taretin mevcut optik modunda config'te `directionStabilized` varsa etkili.** Eşi: `directionStabilizationEnabled`. Sayfanın "See also" kısmında `enableGunStabilization` de var (aşağıya bakın). |
| `currentZeroing` | `currentZeroing object` -> sayı ; alternatif (2.04): `object currentZeroing [weaponClass, muzzleClass]` -> `[distance, zeroingIndex]` | **Birim ister, araç desteklenmez** (`currentZeroing myVehicle` çalışmaz, `currentZeroing gunner myVehicle` çalışır). `distance` lazer menzilini de içerir (Arma 2.20+); `zeroingIndex`: 0=50 m, 1=100 m, 2=150 m ..., lazer için -1. muzzleClass opsiyonel. |
| `setWeaponZeroing` (2.04) | `object setWeaponZeroing [weaponClass, muzzleClass, zeroingIndex]` -> bool | Birim ya da araç. FCS'li araç taretlerinde etkisiz kalabildiğine dair bilinen hata: feedback.bistudio.com/T162056. |
| `weaponState` | `weaponState unit` ; `weaponState [vehicle, turretPath, weapon, muzzle, firemode]` -> `[weapon, muzzle, firemode, magazine, ammoCount, roundReloadPhase, magazineReloadPhase]` | Syntax 2'de weapon/muzzle/firemode opsiyonel (varsayılan ""); yalnızca `[vehicle, turret]` seçili silahı sorgular. `magazineReloadPhase` (2.06): 1->0, 0 = yükleme tamam, >0 sürüyor. |
| `selectWeapon` | `unit selectWeapon muzzleName` ; alternatif (2.08): `unit selectWeapon [weapon, muzzle, firemode]` | Alternatif sözdizimi **kişisel ya da araç silahı** için. unit: kişi, **yerel olmalı** (sunucudan uzaktan çalıştırılabilir). Birden fazla namlulu silahlarda silah değil **namlu adı** verilir. Boş yazı seçimi kaldırmaz (onun için `action SwitchWeapon`). |
| `fire` | `unit fire muzzle` ; `unit fire [muzzle, mode, magazine]` | Argüman **yerel**, etki global. Uzak birimle güvenilmez; `selectWeapon` ile birlikte kullanılmalı ve yerel olduğu makinede çalıştırılmalı. Arma 3'te (1.76'dan beri) duman el bombası örnekleri çalışmıyor; piyade için çözüm `[unit, muzzle] call BIS_fnc_fire`. |

## action

Genel: `unit action ["eylemAdı", parametreler]`; eylem adı büyük/küçük harf duyarsız, argüman genelde yerel (Eject/GetOut/GetIn* gibi bazılarında global olabilir). 2.18'den beri `actionNow` ile animasyonsuz anlık yapılabilir.

| Eylem | Sözdizimi | Notlar |
|---|---|---|
| `TurnIn` / `TurnOut` | `unit action ["TurnOut", vehicle]` | **Birim, aracın etkin komutanı olan bir oyuncu olmalı.** Yalnızca turn-in/turn-out özelliği olan koltuklarda kullanın (aksi hâlde kargo animasyonunu bozar). AI davranış moduna göre kendisi yapar. |
| `LightOn` / `LightOff` | `unit action ["LightOn", targetVehicle]` | Boş araç farları; AI kontrolündeki araçta farlar AI davranışına (combat/stealth = kapalı) bağlıdır. |
| `EngineOn` / `EngineOff` | `unit action ["EngineOn", targetVehicle]` | AI sürücünün isteğini geçersiz kılmaz. (Biz motor için `engineOn` komutunu CBA olayıyla araç sahibinde çalıştırıyoruz.) |
| `SwitchWeapon` | `unit action ["SwitchWeapon", targetUnit, targetUnit, weaponIndex]` ; araç silahı: `player action ["SwitchWeapon", vehicle player, player, index]` | `-1` = silah sırtta/kaldır. İndeks için Arma 2.10'dan beri `weaponsInfo` daha uygun. |
| `UseWeapon` | `unitOne action ["UseWeapon", targetVehicle, targetUnit, weaponIndex]` ; tank örnekleri: `logic action ["UseWeapon", myTank, gunner myTank, 1]`, `[..., myTank, commander myTank, 0]` | unitOne oyuncuysa önce yerden alma animasyonu oynar; Game Logic ise anında yapar. |

## Henüz doğrulanmayanlar (kodda dikkat)

- `isLightOn`, `isTurnedOut` (durum okuyucular): sayfaları görülmedi. Kodda `compile` içinde, hata yalnızca ilgili şalteri etkiler.
- `enableGunStabilization`: `enableDirectionStabilization` sayfasının "See also" kısmında geçiyor. **Top stabilizasyonunu çalışma anında açıp kapatan komut olabilir (STAB şalteri için).** Sayfası alınırsa doğrulanmalı: https://community.bistudio.com/wiki/enableGunStabilization
- `selectWeaponTurret`, `weaponsInfo` (2.10), `getTurretLimits`, `turretLocal`: sayfalarda "See also"da geçiyor; sözdizimi görülmedi.

## Projede nerede kullanılıyor

| Dosya | Kullanılan komutlar |
|---|---|
| `fn_rangeValue.sqf` | `currentZeroing [weapon]` (oyuncu üzerinde) |
| `fn_turretLock.sqf` | `setTurretLimits` (kilitle / sıfırla) |
| `fn_applyEffects.sqf` | `enableDirectionStabilization`, `setTurretLimits [turret]` (sıfırlama) |
| `fn_selectWeapon.sqf` | `weaponState [veh, turret, weapon, muzzle]`, `selectWeapon [weapon, muzzle, firemode]` |
| `fn_t72ActionX.sqf` | `action TurnIn/TurnOut/LightOn/LightOff`, `fire`, `selectWeapon` |
