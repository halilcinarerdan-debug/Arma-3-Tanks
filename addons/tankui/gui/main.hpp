// Tek parça tablet cihazı (zeytin gövde + siyah köşe tamponları + cam ekran).
// Başlık/sekme yok: ekranlar donanım düğmeleriyle (soldaki 3 düğme) değişir; içerik cihazın ekranında çizilir.
#define DEV_X (safeZoneX + safeZoneW * 0.2)
#define DEV_Y (safeZoneY + safeZoneH * 0.08)
#define DEV_W (safeZoneW * 0.6)
#define DEV_H (safeZoneH * 0.84)

#define SB_IDD 7440

class SB_TankUI_Main {
    idd = SB_IDD;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "[_this select 0] call SB_fnc_onLoad;";
    onUnload = "[] call SB_fnc_onUnload;";

    class controlsBackground {};

    class controls {
        // Doku yokken yedek gövde (doku varsa onLoad gizler)
        class Frame: SB_RscText {
            idc = 7401;
            x = DEV_X; y = DEV_Y; w = DEV_W; h = DEV_H;
            colorBackground[] = {0.25, 0.30, 0.20, 1};
        };
        // Ekran (cihazın camı)
        class Screen: SB_RscText {
            idc = 7402;
            x = DEV_X + DEV_W * 0.115; y = DEV_Y + DEV_H * 0.07;
            w = DEV_W * 0.845; h = DEV_H * 0.86;
            colorBackground[] = {0.012, 0.018, 0.014, 1};
        };
        // Gövde dokusu (ekran deliği şeffaf)
        class Housing: SB_RscPicture {
            idc = 7405;
            x = DEV_X; y = DEV_Y; w = DEV_W; h = DEV_H;
            text = "\z\tank33\addons\tankui\data\housing_ca.paa";
        };
        // Donanım düğmeleri (gövdedeki yuvalarla aynı konum)
        class BtnAmmo: SB_RscButton {
            idc = 7411;
            x = DEV_X + DEV_W * 0.022; y = DEV_Y + DEV_H * 0.20;
            w = DEV_W * 0.076; h = DEV_H * 0.075;
            text = "MUHIMMAT";
            sizeEx = safeZoneH * 0.011;
            colorBackground[] = {0.07, 0.08, 0.06, 1};
            colorBackgroundActive[] = {0.14, 0.22, 0.12, 1};
            colorFocused[] = {0.14, 0.22, 0.12, 1};
            colorBorder[] = {0, 0, 0, 0};
            colorText[] = {0.62, 0.78, 0.58, 1};
            action = "[0] call SB_fnc_setTab;";
        };
        class BtnStatus: BtnAmmo {
            idc = 7412;
            y = DEV_Y + DEV_H * 0.32;
            text = "DURUM";
            action = "[1] call SB_fnc_setTab;";
        };
        class BtnStation: BtnAmmo {
            idc = 7413;
            y = DEV_Y + DEV_H * 0.44;
            text = "ISTASYON";
            action = "[2] call SB_fnc_setTab;";
        };
        class Close: BtnAmmo {
            idc = 7499;
            y = DEV_Y + DEV_H * 0.80;
            text = "KAPAT";
            action = "closeDialog 0;";
        };
    };
};
