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
            file = "sb\tankui\functions";
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
            class t72Action {};
        };
    };
};

class Extended_PreInit_EventHandlers {
    class SB_TankUI {
        init = "call compile preprocessFileLineNumbers 'sb\tankui\XEH_preInit.sqf'";
    };
};

class Extended_PostInit_EventHandlers {
    class SB_TankUI {
        clientInit = "call compile preprocessFileLineNumbers 'sb\tankui\XEH_postInit.sqf'";
    };
};

/*
 * Araç profilleri. match[] = sınıf adında (küçük harf) geçen parçalar.
 * İlk eşleşen profil kullanılır; hiçbiri uymazsa Generic.
 */
class CfgSBTankUI {
    class Profiles {
        class M1A2 {
            title = "M1A2 ABRAMS - CREW DISPLAY";
            match[] = {"m1a2", "m1a1", "m1_abrams", "m1a2_tusk"};
        };
        class Leopard2 {
            title = "LEOPARD 2 - CREW DISPLAY";
            match[] = {"leopard2", "leopard_2", "leo2"};
        };
        class Challenger2 {
            title = "CHALLENGER 2 - CREW DISPLAY";
            match[] = {"challenger2", "challenger_2"};
        };
        class T72 {
            title = "T-72 - CREW DISPLAY";
            match[] = {"t72", "t90", "t80"};
            station = "T72"; // gunner için ISTASYON sekmesi (drawStationT72)
        };
    };
    class Generic {
        title = "TANK - CREW DISPLAY";
    };

    // Koltuk bazlı ekranlar. Roller CBA/Arma fullCrew rolleriyle aynı: driver, gunner, commander.
    // tabs[]: "ammo" (mühimmat), "status" (durum). Steel Beasts ekranları geldikçe her rol genişletilecek.
    class Roles {
        class driver    { label = "DRIVER";    tabs[] = {"status"}; };
        class gunner    { label = "GUNNER";    tabs[] = {"station", "ammo", "status"}; };
        class commander { label = "COMMANDER"; tabs[] = {"ammo", "status"}; };
        class other     { label = "CREW";      tabs[] = {"status"}; };
    };
};

#include "gui\baseClasses.hpp"
#include "gui\main.hpp"
