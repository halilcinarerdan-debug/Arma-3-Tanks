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
