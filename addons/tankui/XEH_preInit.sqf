if (!hasInterface) exitWith {};

// Tuş ataması: Controls > Configure Addons > Steel Tank UI üzerinden değiştirilebilir.
// Varsayılan: Ctrl + T
["Steel Tank UI", "SB_openMenu", "Tank ekranını aç/kapat",
    {[] call SB_fnc_openMenu; true},
    {},
    [0x14, [false, true, false]]
] call CBA_fnc_addKeybind;

// Mühimmat seçimi araç sahibinde (local) çalışmalı -> CBA targetEvent (remoteExec beyaz listesine takılmaz).
["SB_TankUI_loadMagazine", {
    params ["_veh", "_turret", "_weapon", "_mag"];
    _veh loadMagazine [_turret, _weapon, _mag];
}] call CBA_fnc_addEventHandler;
