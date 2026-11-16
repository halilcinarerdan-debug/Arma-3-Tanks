class CfgPatches {
    class SB_TankUI {
        name = "Steel Tank UI";
        author = "halilcinarerdan-debug";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.0;
        // CUP araçları string eşleştirme ile algılanır (aşağıda CfgSBTankUI), CUP'a sert bağımlılık yok.
        requiredAddons[] = {"A3_Ui_F", "cba_main", "ace_main"};
    };
};

class CfgFunctions {
    class SB {
        class TankUI {
            file = "z\tank33\addons\tankui\functions";
            class openMenu {};
            class getProfile {};
            class getRole {};
            class getAmmoList {};
            class getHit {};
            class bar {};
            class onLoad {};
            class onUnload {};
            class setTab {};
            class refresh {};
            class drawAmmo {};
            class drawStatus {};
            class selectAmmo {};
            class ammoClass {};
            class ammoCount {};
            class drawStation {};
            class drawStationT72 {};
            class drawStationT72Driver {};
            class drawStationT72Cmdr {};
            class drawStationLeo2 {};
            class drawStationLeo2Cmdr {};
            class drawStationLeo2Driver {};
            class drawStationM1 {};
            class drawStationT72B3 {};
            class drawStationM1Cmdr {};
            class gpsText {};
            class leoSetRange {};
            class ballEnv {};
            class ballInput {};
            class drawStationLeo2Ball {};
            class leoMain {};
            class atgmReady {};
            class tProfile {};
            class syncSel {};
            class t72ActionX {};
            class t72Action {};
            class placeRect {};
            class lbl {};
            class stabEffective {};
            class firedEH {};
            class findWeapon {};
            class weaponRoles {};
            class coaxCount {};
            class rangeValue {};
            class rangeText {};
            class turretLock {};
            class applyEffects {};
            class selectWeapon {};
            class setGunStab {};
            class realStab {};
            class isLoading {};
            class hudBuild {};
            class hudUpdate {};
        };
    };
};

class Extended_PreInit_EventHandlers {
    class SB_TankUI {
        init = "call compile preprocessFileLineNumbers 'z\tank33\addons\tankui\XEH_preInit.sqf'";
    };
};

// Atış sapması (stabilizasyon/balistik anahtarı etkileri). Tüm Tank türevlerine uygulanır; kod yalnızca "SB_armed" araçlarda iş yapar.
class Extended_Fired_EventHandlers {
    class Tank {
        class SB_TankUI {
            fired = "_this call SB_fnc_firedEH";
        };
    };
};

class Extended_PostInit_EventHandlers {
    class SB_TankUI {
        clientInit = "call compile preprocessFileLineNumbers 'z\tank33\addons\tankui\XEH_postInit.sqf'";
    };
};

/*
 * Araç profilleri. match[] = sınıf adında (küçük harf) geçen parçalar.
 * İlk eşleşen profil kullanılır; hiçbiri uymazsa Generic.
 */
class CfgSBTankUI {
    // ctrlSetAngle yönü: 1 = pozitif açı saat yönü. Oyunda ibreler ters dönerse -1 yapın.
    angleSign = 1;
    class Profiles {
        class M1A2 {
            title = "M1A2 ABRAMS - CREW DISPLAY";
            language = "en";
            match[] = {"m1a2", "m1a1", "m1_abrams", "m1a2_tusk"};
            palette = "m1";
            station = "M1";
        };
        class Strv122 {
            title = "STRV 122 - CREW DISPLAY";
            language = "sv";
            match[] = {"strv"};
            palette = "leo";
            station = "LEO2";
            ballInputs = 1; smokeArm = 1;
            bsRange = 1100;      // Strv 122: savaş nişanı 1100 m (SB Strv 122 kılavuzu)
        };
        class Leopard2 {
            title = "LEOPARD 2 - CREW DISPLAY";
            language = "de";
            match[] = {"leopard2", "leopard_2", "leo2"};   // "leopard" tek başına Leopard 1'i de yakalardı; Leopard 1 ayrı araç (SB: ayrı kontrol listesi)
            palette = "leo";
            ballInputs = 1; smokeArm = 1;
            bsRange = 1000;      // Leopard 2 (DE): "E 1000" tuşu (SB iç görseli)
            station = "LEO2"; // Leopard 2 ailesi (Strv 122 mantığı); gunner/commander için ISTASYON sekmesi
        };
        class Challenger2 {
            title = "CHALLENGER 2 - CREW DISPLAY";
            language = "en";
            match[] = {"challenger2", "challenger_2"};
        };
        // Rus T serisi (hepsi station "T72" ekranını kullanır; sistem farkları aşağıdaki özelliklerle gelir).
        // fcs: 1 = T-72M1 sınıfı (lazer + elle lead, LRF modları), 2 = T-72B (1A40-1: lazer + analog balistik bilgisayar, otomatik lead),
        //      3 = T-80U / T-90A (1A45 Irtysh). lrfMax: LRF azami menzil (m). lrfModes: 1200/1800 mod şalteri var mı.
        //      atgm: gövde topundan ATGM (Svir / Refleks / Invar) seçimi var mı; atgmMin/atgmMax: kılavuzlu füze menzil penceresi (m).
        // NOT: sayılar genel kaynaklardan (internet + genel bilgi); Steel Beasts kılavuzlarıyla doğrulanacak.
        class T90 {
            title = "T-90 - CREW DISPLAY";
            language = "ru";
            match[] = {"t90"};
            station = "T72"; palette = "t72";
            fcs = 3; lrfMax = 4000; lrfModes = 0; atgm = 1; atgmMin = 100; atgmMax = 4000;
        };
        class T80 {
            title = "T-80 - CREW DISPLAY";
            language = "ru";
            match[] = {"t80"};
            station = "T72"; palette = "t72";
            fcs = 3; lrfMax = 4000; lrfModes = 0; atgm = 1; atgmMin = 100; atgmMax = 4000;
        };
        class T72B3 {
            title = "T-72B3 - CREW DISPLAY";
            language = "ru";
            match[] = {"t72b3"};
            station = "T72B3"; palette = "t72";
            fcs = 2; lrfMax = 4000; lrfModes = 0; atgm = 1; atgmMin = 100; atgmMax = 4000;
        };
        class T72B {
            title = "T-72B - CREW DISPLAY";
            language = "ru";
            match[] = {"t72b"};
            station = "T72"; palette = "t72";
            fcs = 2; lrfMax = 4000; lrfModes = 0; atgm = 0; atgmMin = 0; atgmMax = 0;   // SB "T-72" kontrol listesinde ATGM tuşu yok (B1/B: Svir yok)
        };
        class T72 {
            title = "T-72 - CREW DISPLAY";
            language = "ru";
            match[] = {"t72"};
            station = "T72"; palette = "t72"; // gunner için ISTASYON sekmesi (drawStationT72)
            fcs = 1; lrfMax = 3000; lrfModes = 1; atgm = 0; atgmMin = 0; atgmMax = 0;
        };
    };
    class Generic {
        title = "TANK - CREW DISPLAY";
        language = "tr";
    };

    // Koltuk bazlı ekranlar. Roller CBA/Arma fullCrew rolleriyle aynı: driver, gunner, commander.
    // tabs[]: "ammo" (mühimmat), "status" (durum). Steel Beasts ekranları geldikçe her rol genişletilecek.
    class Roles {
        class driver    { label = "DRIVER";    tabs[] = {"station", "status"}; };
        class gunner    { label = "GUNNER";    tabs[] = {"station", "ammo", "status"}; };
        class commander { label = "COMMANDER"; tabs[] = {"station", "ammo", "status"}; };
        class other     { label = "CREW";      tabs[] = {"status"}; };
    };
};

#include "gui\baseClasses.hpp"
#include "gui\main.hpp"
#include "gui\hud.hpp"
