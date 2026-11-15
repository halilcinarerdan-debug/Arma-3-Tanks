/* params: [araç, hitpoint(küçük harf)] -> hasar 0..1, hitpoint yoksa -1 */
params ["_veh", "_hp"];
private _all = getAllHitPointsDamage _veh;
if (_all isEqualTo []) exitWith {-1};
private _idx = (_all select 0) findIf {(toLower _x) isEqualTo _hp};
if (_idx < 0) exitWith {-1};
(_all select 2) select _idx
