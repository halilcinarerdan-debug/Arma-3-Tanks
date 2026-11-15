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
    // sürücü/komutan eylemleri ayrı (yalıtılmış) dosyada
    default { [_action] call SB_fnc_t72ActionX };
    case "load": {
        if ([_veh] call SB_fnc_isLoading) exitWith {};
        private _type = _veh getVariable ["SB_selType", ""];
        if (_type == "") exitWith { systemChat "T-72: mermi secici KAPALI." };

        private _row = ([_veh] call SB_fnc_getAmmoList) select {
            (_x select 0) isEqualTo _turret && {([_x select 1] call SB_fnc_ammoClass) == _type}
        };
        if (_row isEqualTo []) exitWith { systemChat format ["T-72: %1 mermisi kalmadi.", _type] };

        private _mag = (_row select 0) select 1;
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
        // "yükleniyor" göstergesi zaman damgasıyla biter (geri çağrıma bağlı değil): toplam süre + 1 sn pay
        _veh setVariable ["SB_loadEnd", time + (_target max _engine) + 1];
        [{
            params ["_veh", "_turret", "_mag"];
            [_turret, _mag, _veh] call SB_fnc_selectAmmo;
        }, [_veh, _turret, _mag], _delay] call CBA_fnc_waitAndExecute;
    };

    // ---- Leopard 2 ailesi: ateş kontrol modu, mermi (seç + yükle), savaş nişanı ----
    case "fc_normal": {
        _veh setVariable ["SB_hydr", true];
        _veh setVariable ["SB_hydrOn", time - 120];        // Leopard stabilizasyonu anında hazır (T-72'deki 120 sn ısınma yok)
        _veh setVariable ["SB_stab", true];
        _veh setVariable ["SB_stabOn", time];
        if (missionNamespace getVariable ["SB_TankUI_turretLock", true]) then { [_veh, _turret, false] call SB_fnc_turretLock };
    };
    case "fc_emerg": {
        _veh setVariable ["SB_hydr", true];
        _veh setVariable ["SB_hydrOn", time - 120];
        _veh setVariable ["SB_stab", false];
        if (missionNamespace getVariable ["SB_TankUI_turretLock", true]) then { [_veh, _turret, false] call SB_fnc_turretLock };
    };
    case "fc_manual": {
        _veh setVariable ["SB_hydr", false];
        _veh setVariable ["SB_stab", false];
        if (missionNamespace getVariable ["SB_TankUI_turretLock", true]) then { [_veh, _turret, true] call SB_fnc_turretLock };
    };
    case "am_KE": { _veh setVariable ["SB_selType", "KE"]; [_veh, _turret] call SB_fnc_leoMain; ["load"] call SB_fnc_t72Action };
    case "am_HE": {
        // HE-T: HE yoksa HEAT mermisine düş (CUP sürümüne göre değişir)
        private _hasHE = (([_veh] call SB_fnc_getAmmoList) findIf {
            (_x select 0) isEqualTo _turret && {([_x select 1] call SB_fnc_ammoClass) == "HE"}
        }) >= 0;
        _veh setVariable ["SB_selType", ["HEAT", "HE"] select _hasHE];
        [_veh, _turret] call SB_fnc_leoMain;
        ["load"] call SB_fnc_t72Action;
    };
    // elle menzil (Avstånd MAN): savaş nişanı / SS 1500 / +-100 m
    case "bs_1100": { [_veh, 1100] call SB_fnc_leoSetRange };
    case "bs_1500": { [_veh, 1500] call SB_fnc_leoSetRange };
    case "rng_dn":  { [_veh, ((_veh getVariable ["SB_range", 1100]) - 100) max 200] call SB_fnc_leoSetRange };
    case "rng_up":  { [_veh, ((_veh getVariable ["SB_range", 1100]) + 100) min 9990] call SB_fnc_leoSetRange };
    case "rngmode": { _veh setVariable ["SB_rngMan", !(_veh getVariable ["SB_rngMan", false])] };

    case "lase": {
        if ((missionNamespace getVariable ["SB_TankUI_rangeSource", 0]) == 0) exitWith { systemChat "Menzil kaynagi Arma lazeri: nisangahta lazer tusunu kullanin (CBA: Menzil kaynagi)." };
        if !(_veh getVariable ["SB_lrfOn", false]) exitWith { systemChat "T-72: LRF kapali (LRF ACIK salterini acin)." };
        if (time < (_veh getVariable ["SB_lrfReadyAt", 0])) exitWith { systemChat "T-72: LRF hazir degil." };
        _veh setVariable ["SB_lrfReadyAt", time + 3];
        _veh setVariable ["SB_rngMan", false];     // lazer ölçümü otomatik menzile döner

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

    case "reset": { _veh setVariable ["SB_range", 0]; _veh setVariable ["SB_rngMan", false] };
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
        [_veh, _turret, _target, _target] call SB_fnc_selectWeapon;
        [{
            params ["_veh", "_turret", "_target"];
            if ((_veh currentWeaponTurret _turret) != _target) then {
                systemChat "Silah secilemedi (selectWeapon etkisiz kaldi). RPT'ye bakin.";
                diag_log format ["[SB_TankUI] TOP/PKT secimi basarisiz: istenen=%1 mevcut=%2", _target, _veh currentWeaponTurret _turret];
            };
        }, [_veh, _turret, _target], 0.9] call CBA_fnc_waitAndExecute;
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
        // hidrolik kapanınca taret kilitlenir (elle krank yok), açılınca serbest kalır
        if (missionNamespace getVariable ["SB_TankUI_turretLock", true]) then { [_veh, _turret, !_on] call SB_fnc_turretLock };
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
