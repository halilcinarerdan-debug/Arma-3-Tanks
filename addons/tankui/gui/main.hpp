// Panel geometrisi (safeZone'a göre, ekranın ortasında)
#define SB_X (safeZoneX + safeZoneW * 0.2)
#define SB_Y (safeZoneY + safeZoneH * 0.08)
#define SB_W (safeZoneW * 0.6)
#define SB_H (safeZoneH * 0.84)

#define SB_IDD 7440

class SB_TankUI_Main {
    idd = SB_IDD;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "[_this select 0] call SB_fnc_onLoad;";
    onUnload = "[] call SB_fnc_onUnload;";

    class controlsBackground {};

    class controls {
        // Dış gövde (olive)
        class Frame: SB_RscText {
            idc = 7401;
            x = SB_X; y = SB_Y; w = SB_W; h = SB_H;
            colorBackground[] = {0.20, 0.25, 0.17, 1};
        };
        // Köşe blokları
        class CornerTL: SB_RscText {
            x = SB_X; y = SB_Y; w = SB_W * 0.04; h = SB_H * 0.05;
            colorBackground[] = {0.03, 0.03, 0.03, 1};
        };
        class CornerTR: CornerTL { x = SB_X + SB_W * 0.96; };
        class CornerBL: CornerTL { y = SB_Y + SB_H * 0.95; };
        class CornerBR: CornerTL { x = SB_X + SB_W * 0.96; y = SB_Y + SB_H * 0.95; };

        // Siyah ekran alanı
        class Screen: SB_RscText {
            idc = 7402;
            x = SB_X + SB_W * 0.03; y = SB_Y + SB_H * 0.04;
            w = SB_W * 0.94; h = SB_H * 0.92;
            colorBackground[] = {0.01, 0.02, 0.01, 1};
        };
        class Title: SB_RscText {
            idc = 7403;
            x = SB_X + SB_W * 0.05; y = SB_Y + SB_H * 0.05;
            w = SB_W * 0.55; h = SB_H * 0.06;
            sizeEx = safeZoneH * 0.04;
            text = "TANK";
        };
        class VehicleName: SB_RscText {
            idc = 7404;
            style = 1; // sağa hizalı
            x = SB_X + SB_W * 0.58; y = SB_Y + SB_H * 0.05;
            w = SB_W * 0.37; h = SB_H * 0.06;
            sizeEx = safeZoneH * 0.03;
        };
        // Sekmeler
        class TabAmmo: SB_RscButton {
            idc = 7411;
            x = SB_X + SB_W * 0.05; y = SB_Y + SB_H * 0.12;
            w = SB_W * 0.16; h = SB_H * 0.05;
            text = "MUHIMMAT";
            action = "[0] call SB_fnc_setTab;";
        };
        class TabStatus: TabAmmo {
            idc = 7412;
            x = SB_X + SB_W * 0.22;
            text = "DURUM";
            action = "[1] call SB_fnc_setTab;";
        };
        // Kapat
        class Close: SB_RscButton {
            idc = 7499;
            x = SB_X + SB_W * 0.79; y = SB_Y + SB_H * 0.89;
            w = SB_W * 0.16; h = SB_H * 0.05;
            text = "KAPAT";
            action = "closeDialog 0;";
        };
    };
};
