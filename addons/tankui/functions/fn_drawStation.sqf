/* İSTASYON sekmesi: profildeki station alanına göre araca özgü istasyon ekranını çizer. */
params ["_display"];
private _veh = uiNamespace getVariable "SB_TankUI_vehicle";
private _profile = [_veh] call SB_fnc_getProfile;   // not: >> operatörü call'dan önce çözülür, bu yüzden ayrı satır
private _station = getText (_profile >> "station");
switch (_station) do {
    case "T72": {
        switch (uiNamespace getVariable ["SB_TankUI_role", "gunner"]) do {
            case "driver": { [_display] call SB_fnc_drawStationT72Driver };
            case "commander": { [_display] call SB_fnc_drawStationT72Cmdr };
            default { [_display] call SB_fnc_drawStationT72 };
        };
    };
    case "M1": {
        switch (uiNamespace getVariable ["SB_TankUI_role", "gunner"]) do {
            case "driver": { [_display] call SB_fnc_drawStationLeo2Driver };
            case "commander": { [_display] call SB_fnc_drawStationM1Cmdr };
            default { [_display] call SB_fnc_drawStationM1 };
        };
    };
    case "LEO2": {
        switch (uiNamespace getVariable ["SB_TankUI_role", "gunner"]) do {
            case "driver": { [_display] call SB_fnc_drawStationLeo2Driver };
            case "commander": { [_display] call SB_fnc_drawStationLeo2Cmdr };
            default { [_display] call SB_fnc_drawStationLeo2 };
        };
    };
    default {
        (ctrlPosition (_display displayCtrl 7402)) params ["_sx", "_sy", "_sw", "_sh"];
        private _c = _display ctrlCreate ["SB_RscText", -1];
        _c ctrlSetPosition [_sx + _sw * 0.03, _sy + _sh * 0.2, _sw * 0.9, _sh * 0.05];
        _c ctrlSetText format ["Bu arac icin istasyon ekrani yok. Arac: %1  Profil: %2", typeOf _veh, configName _profile];
        _c ctrlCommit 0;
        uiNamespace setVariable ["SB_TankUI_ctrls", [_c]];
    };
};
