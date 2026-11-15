// ---- Mühimmat yükleme: araç sahibinde (local) çalışmalı -> CBA targetEvent (remoteExec beyaz listesine takılmaz).
// Bu olay TÜM makinelerde kayıtlıdır: araç MP'de sunucuda/başka istemcide yerel olabilir.
["SB_TankUI_loadMagazine", {
    params ["_veh", "_turret", "_weapon", "_mag", ["_caller", objNull]];
    _veh loadMagazine [_turret, _weapon, _mag];
    // 1,5 sn sonra gerçekten yüklendi mi? Sonucu isteyen oyuncuya bildir (tanılama + geri bildirim)
    [{
        params ["_veh", "_turret", "_weapon", "_mag", "_caller"];
        ["SB_TankUI_loadResult", [_mag, _veh currentMagazineTurret _turret, _weapon, _turret], _caller] call CBA_fnc_targetEvent;
    }, [_veh, _turret, _weapon, _mag, _caller], 1.5] call CBA_fnc_waitAndExecute;
}] call CBA_fnc_addEventHandler;

["SB_TankUI_loadResult", {
    params ["_mag", "_cur", "_weapon", "_turret"];
    private _ok = _cur isEqualTo _mag;
    diag_log format ["[SB_TankUI] loadMagazine sonuc: istenen=%1 mevcut=%2 silah=%3 taret=%4 basarili=%5", _mag, _cur, _weapon, _turret, _ok];
    systemChat (if (_ok) then {
        format ["Yuklendi: %1", getText (configFile >> "CfgMagazines" >> _mag >> "displayName")]
    } else {
        format ["Yukleme basarisiz (istenen: %1, mevcut: %2). RPT'ye bakin.", _mag, _cur]
    });
}] call CBA_fnc_addEventHandler;

// Sürücü/komutan eylemleri: araç sahibinde çalışır (tüm makinelerde kayıtlı)
["SB_TankUI_engine", { params ["_veh", "_on"]; _veh engineOn _on }] call CBA_fnc_addEventHandler;
["SB_TankUI_turretLimits", { params ["_veh", "_lim"]; _veh setTurretLimits _lim }] call CBA_fnc_addEventHandler;
["SB_TankUI_gunStab", compile "params ['_veh', '_turret', '_mode']; _veh enableGunStabilization [_mode, _turret];"] call CBA_fnc_addEventHandler;
["SB_TankUI_fire", { params ["_veh", "_weapon"]; _veh fire _weapon }] call CBA_fnc_addEventHandler;

if (!hasInterface) exitWith {};

// Tuş ataması: Controls > Configure Addons > Steel Tank UI üzerinden değiştirilebilir.
// Varsayılan: Ctrl + T
["Steel Tank UI", "SB_openMenu", "Tank ekranını aç/kapat",
    {[] call SB_fnc_openMenu; true},
    {},
    [0x14, [false, true, false]]
] call CBA_fnc_addKeybind;

// ---- CBA ayarları (Addon Options > Steel Tank UI), istemci tarafı ----
["SB_TankUI_labelLang", "LIST",
    ["Etiket dili", "Panel etiketlerinin dili. 'Arac dili' her arac icin kendi dilini kullanir (T-72: Rusca, Leopard: Almanca, M1/Challenger: Ingilizce)."],
    "Steel Tank UI",
    [[0, 1, 2, 3, 4], ["Arac dili (otomatik)", "Turkce", "English", "Русский", "Deutsch"], 0],
    0
] call CBA_fnc_addSetting;

["SB_TankUI_dirt", "SLIDER",
    ["Cihaz kirliligi", "Cam uzerindeki kir/toz katmaninin opakligi (0 = temiz)."],
    "Steel Tank UI", [0, 100, 60, 0], 0
] call CBA_fnc_addSetting;

["SB_TankUI_loadTime", "SLIDER",
    ["Otomatik yukleyici suresi (sn)", "T-72 mekanik yukleyicisinin bir mermiyi yuklemesi (kilavuz: normalde ~6 sn)."],
    "Steel Tank UI", [1, 20, 6, 0], 0
] call CBA_fnc_addSetting;

["SB_TankUI_angleSign", "LIST",
    ["Ibre yonu", "Ibreler/kollar ters donuyorsa 'Ters' secin (ctrlSetAngle yonu)."],
    "Steel Tank UI", [[1, -1], ["Normal", "Ters"], 0], 0
] call CBA_fnc_addSetting;

["SB_TankUI_useTextures", "CHECKBOX",
    ["Dokulari kullan", "Kapatilirsa duz renkli yedek gorunum kullanilir (doku sorunlarini ayirt etmek icin)."],
    "Steel Tank UI", true, 0
] call CBA_fnc_addSetting;

["SB_TankUI_effects", "CHECKBOX",
    ["Panel etkileri", "Acikken STAB/HIDROLIK/balistik anahtari atisi etkiler (stabilizasyon yokken hareket halinde sapma, yanlis balistik indeks). Etkiler istasyon ekrani bir kez acilinca devreye girer."],
    "Steel Tank UI", true, 0
] call CBA_fnc_addSetting;

["SB_TankUI_effectScale", "SLIDER",
    ["Sapma siddeti (%)", "Panel etkilerinin sapma miktari (100 = varsayilan, 0 = sapma yok)."],
    "Steel Tank UI", [0, 200, 100, 0], 0
] call CBA_fnc_addSetting;

["SB_TankUI_hud", "CHECKBOX",
    ["Nisangah plakalari", "Nisancı optigine bakarken yan seritlerde stabilizasyon/mermi/menzil plakalarini gosterir."],
    "Steel Tank UI", true, 0
] call CBA_fnc_addSetting;

["SB_TankUI_hudScale", "SLIDER",
    ["Nisangah plaka boyutu (%)", "Plakalarin olcegi (115 = varsayilan, 100 = daha kucuk)."],
    "Steel Tank UI", [50, 200, 115, 0], 0
] call CBA_fnc_addSetting;

["SB_TankUI_rangeSource", "LIST",
    ["Menzil kaynagi", "Menzil ekranlarinin (istasyon, nisangah plakasi) verisi: Arma'nin kendi lazer menzili (nisangahtaki sayi) ya da panelin LAZER dugmesiyle olctugu."],
    "Steel Tank UI", [[0, 1], ["Arma lazeri (nisangah ile ayni)", "Panel lazeri (LAZER dugmesi)"], 0], 0
] call CBA_fnc_addSetting;

["SB_TankUI_turretLock", "CHECKBOX",
    ["Hidrolik kapaliyken taret kilitlenir", "HIDROLIK salteri kapatilinca taret mevcut yonunde kilitlenir (elle krank yok); acilinca serbest kalir."],
    "Steel Tank UI", true, 0
] call CBA_fnc_addSetting;

["SB_TankUI_opticStab", "CHECKBOX",
    ["Ayna kilidi optik stabilizasyonu etkiler", "Hidrolik acik + ayna acik + 120 sn isinma tamamsa optik yon stabilizasyonu acilir. Yalnizca optik modunda config'te directionStabilized varsa etkilidir."],
    "Steel Tank UI", true, 0
] call CBA_fnc_addSetting;

["SB_TankUI_stabMode", "LIST",
    ["Stabilizasyon yontemi", "STAB salterinin etkisi: gercek top stabilizasyonu (enableGunStabilization, Arma 2.22+) ya da hareket halinde atis sapmasi simulasyonu. 2.22 altinda otomatik olarak sapma simulasyonu kullanilir."],
    "Steel Tank UI", [[0, 1], ["Gercek top stabilizasyonu (2.22+)", "Atis sapmasi simulasyonu"], 0], 0
] call CBA_fnc_addSetting;
