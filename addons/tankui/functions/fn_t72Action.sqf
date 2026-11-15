/*
 * T-72 istasyon düğmeleri. params: [eylem]
 * sel_KE|sel_HEAT|sel_HE|sel_OFF, load, lase, reset, mode, delta, stab, hydr, ball, lrfon, automan, mirror, weapon
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
        // Karusel + mekanik yükleyici: CBA ayarı (varsayılan 6 sn); AUT/MAN "MAN" ise elle krank: ~65 sn (kılavuz s.33)
        private _target = if (_veh getVariable ["SB_manual", false]) then {65} else {missionNamespace getVariable ["SB_TankUI_loadTime", 6]};
        // loadMagazine'den sonra Arma kendi yükleme süresini de uygular; çift beklemeyi önlemek için onu hedeften düşeriz.
        private _wm = [_veh, _turret, _mag] call SB_fnc_findWeapon;
        private _engine = 0;
        if ((_wm select 0) != "") then {
            private _wc = configFile >> "CfgWeapons" >> (_wm select 0);
            _engine = (getNumber (_wc >> "magazineReloadTime")) max (getNumber (_wc >> "reloadTime"));
        };
        private _delay = (_target - _engine) max 0;
        systemChat format ["Yukleyici: hedef %1 sn (oyunun kendi yuklemesi ~%2 sn dahil, bekleme %3 sn)", _target, round _engine, round _delay];
        [{
            params ["_veh", "_turret", "_mag"];
            [_turret, _mag, _veh] call SB_fnc_selectAmmo;
            _veh setVariable ["SB_loading", false];
        }, [_veh, _turret, _mag], _delay] call CBA_fnc_waitAndExecute;
    };

    case "lase": {
        if !(_veh getVariable ["SB_lrfOn", false]) exitWith { systemChat "T-72: LRF kapali (LRF ACIK salterini acin)." };
        if (time < (_veh getVariable ["SB_lrfReadyAt", 0])) exitWith { systemChat "T-72: LRF hazir degil." };
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
    case "lrfon": {
        private _on = !(_veh getVariable ["SB_lrfOn", false]);
        _veh setVariable ["SB_lrfOn", _on];
        if (_on) then { _veh setVariable ["SB_lrfReadyAt", time + 4] };   // lazer ısınma süresi
    };
    case "weapon": {
        // TOP <-> PKT: aktif silahı değiştir (kılavuz: M tuşu, coax/main)
        ([_veh, _turret] call SB_fnc_weaponRoles) params ["_main", "_coax"];
        private _cur = _veh currentWeaponTurret _turret;
        private _target = if (_cur == _main) then {_coax} else {_main};
        if (_target == "") exitWith { systemChat "T-72: bu taretde TOP/PKT secimi icin ikinci silah bulunamadi." };
        player selectWeapon _target;
        [{
            params ["_veh", "_turret", "_target"];
            if ((_veh currentWeaponTurret _turret) != _target) then {
                systemChat "Silah secilemedi (selectWeapon etkisiz kaldi). RPT'ye bakin.";
                diag_log format ["[SB_TankUI] TOP/PKT secimi basarisiz: istenen=%1 mevcut=%2", _target, _veh currentWeaponTurret _turret];
            };
        }, [_veh, _turret, _target], 0.4] call CBA_fnc_waitAndExecute;
    };
    case "automan": { _veh setVariable ["SB_manual", !(_veh getVariable ["SB_manual", false])] };
    case "mirror":  { _veh setVariable ["SB_mirror", !(_veh getVariable ["SB_mirror", false])] };
    case "ball": {
        // balistik bilgisayara manuel mermi tipi indeksi: otomatik -> KE -> HE -> HEAT -> otomatik
        private _seq = ["", "KE", "HE", "HEAT"];
        _veh setVariable ["SB_ballOvr", _seq select (((_seq find (_veh getVariable ["SB_ballOvr", ""])) + 1) mod 4)];
    };
    case "mode":  { _veh setVariable ["SB_lrfMode", ((_veh getVariable ["SB_lrfMode", 0]) + 1) mod 3] };
    case "delta": { _veh setVariable ["SB_delta", !(_veh getVariable ["SB_delta", false])] };

    case "hydr": {
        private _on = !(_veh getVariable ["SB_hydr", false]);
        _veh setVariable ["SB_hydr", _on];
        if (_on) then { _veh setVariable ["SB_hydrOn", time] } else { _veh setVariable ["SB_stab", false] };
    };
    case "stab": {
        if (_veh getVariable ["SB_hydr", false]) then {
            private _stabNew = !(_veh getVariable ["SB_stab", false]);
            _veh setVariable ["SB_stab", _stabNew];
            if (_stabNew) then { _veh setVariable ["SB_stabOn", time] };      // aşırı ısınma sayacı
        } else {
            systemChat "T-72: stabilizasyon icin once hidrolik acilmali.";
        };
    };
};
