/*
 * Menzil değeri (metre). Kaynak CBA ayarı "SB_TankUI_rangeSource":
 *   0 = Arma'nın kendi menzili: currentZeroing [silah] -> [mesafe, indeks]; mesafe lazer menzilini de içerir (Arma 2.20+).
 *       Not: currentZeroing BİRİM ister (araç desteklenmez), bu yüzden oyuncunun kendisi kullanılır.
 *   1 = panel lazeri (LAZER düğmesiyle ölçülen SB_range)
 * params: [araç] -> sayı (0 = menzil yok)
 */
params ["_veh"];
if (_veh getVariable ["SB_rngMan", false]) exitWith { _veh getVariable ["SB_range", 0] };   // Leopard: elle girilen menzil
if ((missionNamespace getVariable ["SB_TankUI_rangeSource", 0]) == 1) exitWith { _veh getVariable ["SB_range", 0] };

private _t = uiNamespace getVariable ["SB_TankUI_turret", [0]];
private _w = _veh currentWeaponTurret _t;
if (_w == "") exitWith {0};
private _z = player currentZeroing [_w];
if (_z isEqualType []) then { _z param [0, 0] } else { _z }
