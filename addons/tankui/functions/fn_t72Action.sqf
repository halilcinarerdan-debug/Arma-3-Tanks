/*
 * T-72 istasyon düğmeleri. params: [eylem]
 * sel_KE|sel_HEAT|sel_HE|sel_OFF, load, lase, reset, mode, delta, stab, hydr
 * Durumlar araç üzerinde (sadece bu client'ta) tutulur.
 */
params ["_action"];
private _veh = uiNamespace getVariable ["SB_TankUI_vehicle", objNull];
if (isNull _veh) exitWith {};
private _turret = uiNamespace getVariable ["SB_TankUI_turret", [0]];

if ((_action select [0, 4]) == "sel_") exitWith {
    private _t = _action select [4];
    _veh setVariable ["SB_selType", ["", _t] select (_t != "OFF")];
};

switch (_action) do {
    case "load": {
        if (_veh getVariable ["SB_loading", false]) exitWith {};
        private _type = _veh getVariable ["SB_selType", ""];
        if (_type == "") exitWith { systemChat "T-72: mermi secici KAPALI." };

        private _row = ([_veh] call SB_fnc_getAmmoList) select {
            (_x select 0) isEqualTo _turret && {([_x select 1] call SB_fnc_ammoClass) == _type}
        };
        if (_row isEqualTo []) exitWith { systemChat format ["T-72: %1 mermisi kalmadi.", _type] };

        private _mag = (_row select 0) select 1;
        _veh setVariable ["SB_loading", true];
        // Karusel dönüşü + mekanik yükleyici: ~6 sn (kılavuza göre normal durum)
        [{
            params ["_veh", "_turret", "_mag"];
            [_turret, _mag, _veh] call SB_fnc_selectAmmo;
            _veh setVariable ["SB_loading", false];
        }, [_veh, _turret, _mag], 6] call CBA_fnc_waitAndExecute;
    };

    case "lase": {
        if (time < (_veh getVariable ["SB_lrfReadyAt", 0])) exitWith { systemChat "T-72: LRF sogutuluyor." };
        _veh setVariable ["SB_lrfReadyAt", time + 3];

        private _weapon = _veh currentWeaponTurret _turret;
        private _from = _veh modelToWorldWorld (_veh selectionPosition ["usti hlavne", "Memory"]);
        private _dir = _veh weaponDirection _weapon;
        private _hits = lineIntersectsSurfaces [_from, _from vectorAdd (_dir vectorMultiply 4000), _veh, objNull, true, 1, "FIRE", "VIEW"];

        private _limit = [3000, 1200, 1800] select (_veh getVariable ["SB_lrfMode", 0]);
        private _dist = if (_hits isEqualTo []) then {-1} else {_from distance ((_hits select 0) select 0)};

        if (_dist < 0 || {_dist > _limit}) then {
            // kötü dönüş / mod sınırı aşıldı -> battlesight 800 m (kılavuz)
            _veh setVariable ["SB_lrfText", "----"];
            _veh setVariable ["SB_range", 800];
        } else {
            _veh setVariable ["SB_lrfText", str round _dist];
            _veh setVariable ["SB_range", _dist];
        };
    };

    case "reset": { _veh setVariable ["SB_range", 0] };
    case "mode":  { _veh setVariable ["SB_lrfMode", ((_veh getVariable ["SB_lrfMode", 0]) + 1) mod 3] };
    case "delta": { _veh setVariable ["SB_delta", !(_veh getVariable ["SB_delta", false])] };

    case "hydr": {
        private _on = !(_veh getVariable ["SB_hydr", false]);
        _veh setVariable ["SB_hydr", _on];
        if (_on) then { _veh setVariable ["SB_hydrOn", time] } else { _veh setVariable ["SB_stab", false] };
    };
    case "stab": {
        if (_veh getVariable ["SB_hydr", false]) then {
            _veh setVariable ["SB_stab", !(_veh getVariable ["SB_stab", false])];
        } else {
            systemChat "T-72: stabilizasyon icin once hidrolik acilmali.";
        };
    };
};
