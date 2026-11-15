/*
 * Kılavuzlu füze (gövde topundan ATGM) atışa hazır mı?
 * Koşullar: yüklü mermi ATGM, LRF açık ve ısınmış, ölçülen menzil profilin ATGM penceresinde (atgmMin..atgmMax).
 * params: [araç] -> bool
 */
params ["_veh"];
private _t = uiNamespace getVariable ["SB_TankUI_turret", [0]];
if (([_veh currentMagazineTurret _t] call SB_fnc_ammoClass) != "ATGM") exitWith {false};
if ((_veh ammo (_veh currentWeaponTurret _t)) <= 0) exitWith {false};
if !(_veh getVariable ["SB_lrfOn", false]) exitWith {false};
if (serverTime < (_veh getVariable ["SB_lrfReadyAt", 0])) exitWith {false};
private _r = [_veh] call SB_fnc_rangeValue;
_r >= ([_veh, "atgmMin", 100] call SB_fnc_tProfile) && {_r <= ([_veh, "atgmMax", 4000] call SB_fnc_tProfile)}
