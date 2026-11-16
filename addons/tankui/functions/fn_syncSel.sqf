/*
 * Mermi seçimini oyunun gerçek durumuyla eşitler (hudUpdate PFH'sinden her 0.3 sn).
 * Aynı taretteki başka bir oyuncu / bot (ör. 2. nişancı) mermiyi değiştirirse, arayüzdeki seçici ve lambalar buna uyar.
 * Kendi yüklememiz sürerken (SB_loadEnd) dokunmaz; hedefimiz zaten SB_selType'tadır.
 */
private _veh = vehicle player;
if !(_veh isKindOf "Tank") exitWith {};
if ([_veh] call SB_fnc_isDisabled) exitWith {};
private _crew = (fullCrew _veh) select {(_x select 0) isEqualTo player};
if (_crew isEqualTo []) exitWith {};
private _turret = (_crew select 0) select 3;
if (_turret isEqualTo []) exitWith {};

private _mag = _veh currentMagazineTurret _turret;
private _key = "SB_lastMag_" + str _turret;           // yerel (herkes kendi gördüğünü izler)
if ((_veh getVariable [_key, ""]) isEqualTo _mag) exitWith {};
_veh setVariable [_key, _mag];
if ([_veh] call SB_fnc_isLoading) exitWith {};
private _class = [_mag] call SB_fnc_ammoClass;
if (_class in ["KE", "HE", "HEAT", "ATGM"] && {(_veh getVariable ["SB_selType", ""]) != _class}) then { _veh setVariable ["SB_selType", _class, true] };
