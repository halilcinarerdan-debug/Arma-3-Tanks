// AIFMS tarzı koyu zemin / yeşil fosfor temel kontrol sınıfları.
class SB_RscText {
    access = 0;
    idc = -1;
    type = 0;
    style = 0;
    x = 0; y = 0; w = 0.1; h = 0.04;
    font = "RobotoCondensed";
    sizeEx = 0.035;
    colorBackground[] = {0, 0, 0, 0};
    colorText[] = {0.55, 1, 0.55, 1};
    text = "";
    shadow = 0;
    linespacing = 1;
    fixedWidth = 0;
};

class SB_RscButton {
    access = 0;
    idc = -1;
    type = 1;
    style = 2;
    x = 0; y = 0; w = 0.1; h = 0.04;
    text = "";
    font = "RobotoCondensed";
    sizeEx = 0.035;
    shadow = 0;
    colorText[] = {0.55, 1, 0.55, 1};
    colorDisabled[] = {0.3, 0.4, 0.3, 1};
    colorBackground[] = {0.05, 0.08, 0.05, 1};
    colorBackgroundDisabled[] = {0.02, 0.03, 0.02, 1};
    colorBackgroundActive[] = {0.12, 0.25, 0.12, 1};
    colorFocused[] = {0.12, 0.25, 0.12, 1};
    colorShadow[] = {0, 0, 0, 0};
    colorBorder[] = {0.55, 1, 0.55, 1};
    borderSize = 0;
    offsetX = 0;
    offsetY = 0;
    offsetPressedX = 0.002;
    offsetPressedY = 0.002;
    soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter", 0.09, 1};
    soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush", 0.09, 1};
    soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick", 0.09, 1};
    soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape", 0.09, 1};
};
