/* params: [araç, unit] -> "driver" | "gunner" | "commander" | "other" (fullCrew rolleri) */
params ["_veh", "_unit"];
private _entry = (fullCrew _veh) select {(_x select 0) isEqualTo _unit};
if (_entry isEqualTo []) exitWith {"other"};
private _role = toLower ((_entry select 0) select 1);
if (_role in ["driver", "gunner", "commander"]) then {_role} else {"other"}
