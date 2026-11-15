// Nişangâh plakaları: girişi engellemeyen ekran katmanı (RscTitles). İçeriği SB_fnc_hudBuild çizer.
class RscTitles {
    class SB_TankUI_Hud {
        idd = 7450;
        duration = 100000000;
        fadeIn = 0;
        fadeOut = 0;
        movingEnable = 0;
        enableSimulation = 1;
        onLoad = "uiNamespace setVariable ['SB_TankUI_hudDisplay', _this select 0]; [_this select 0] call SB_fnc_hudBuild;";
        class controls {
            // Görünmez tuval: kit bu denetimin konumunu çizim alanı olarak kullanır
            class Canvas: SB_RscText {
                idc = 7402;
                x = safeZoneX; y = safeZoneY; w = safeZoneW; h = safeZoneH;
                colorBackground[] = {0, 0, 0, 0};
            };
        };
    };
};
