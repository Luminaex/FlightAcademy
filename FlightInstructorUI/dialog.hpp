// Flight Instructor Dialog — IDD: 9000

// ── Type constants ────────────────────────────────────────────────────────────
#define CT_STATIC       0
#define CT_BUTTON       1
#define CT_LISTBOX      5
#define CT_MAP          101
#define ST_LEFT         0
#define ST_CENTER       2

// ── Base classes ──────────────────────────────────────────────────────────────
class RscText {
    access = 0; type = CT_STATIC; idc = -1; style = ST_LEFT;
    colorBackground[] = {0,0,0,0}; colorText[] = {1,1,1,1};
    font = "RobotoCondensed"; sizeEx = 0.022; text = "";
    fixedWidth = 0; x = 0; y = 0; w = 0.1; h = 0.04;
};

class RscButton {
    access = 0; type = CT_BUTTON; idc = -1; style = ST_CENTER;
    text = ""; font = "RobotoCondensed"; sizeEx = 0.020;
    colorText[] = {0.85,0.85,0.85,1};
    colorBackground[]         = {0.137, 0.122, 0.125, 0.95};
    colorBackgroundActive[]   = {0.18,0.18,0.18,1.0};
    colorBackgroundDisabled[] = {0.137, 0.122, 0.125, 0.9};
    colorFocused[]            = {0.18,0.18,0.18,1.0};
    colorDisabled[]           = {0.35,0.35,0.35,1};
    colorBorder[]  = {0.30,0.30,0.30,1};
    colorShadow[]  = {0,0,0,0};
    borderSize = 0.002;
    offsetX = 0; offsetY = 0;
    offsetPressedX = 0; offsetPressedY = 0;
    soundEnter[]   = {"\A3\ui_f\data\sound\RscButton\soundEnter",  0.1, 1};
    soundPush[]    = {"\A3\ui_f\data\sound\RscButton\soundPush",   0.1, 1};
    soundClick[]   = {"\A3\ui_f\data\sound\RscButton\soundClick",  0.1, 1};
    soundEscape[]  = {"\A3\ui_f\data\sound\RscButton\soundEscape", 0.1, 1};
    x = 0; y = 0; w = 0.15; h = 0.05; action = "";
};

class RscEdit {
    access = 0; type = 2; idc = -1; style = ST_CENTER;
    font = "RobotoCondensed"; sizeEx = 0.022;
    colorText[]       = {1, 1, 1, 1};
    colorBackground[] = {0.10, 0.10, 0.10, 1};
    colorSelection[]  = {0.0, 0.369, 0.722, 1};
    colorDisabled[]   = {0.4, 0.4, 0.4, 1};
    colorBorder[]     = {0.30, 0.30, 0.30, 1};
    borderSize = 0.001;
    autocomplete = "";
    text = ""; x = 0; y = 0; w = 0.1; h = 0.04;
};

class RscXSliderH {
    access = 0; type = 43; idc = -1; style = 0;
    color[]         = {0.0, 0.369, 0.722, 1};
    colorActive[]   = {0.1, 0.5,   0.9,   1};
    colorDisabled[] = {0.5, 0.5,   0.5,   1};
    arrowEmpty = "\A3\ui_f\data\gui\cfg\slider\arrowEmpty_ca.paa";
    arrowFull  = "\A3\ui_f\data\gui\cfg\slider\arrowFull_ca.paa";
    border     = "\A3\ui_f\data\gui\cfg\slider\border_ca.paa";
    thumb      = "\A3\ui_f\data\gui\cfg\slider\thumb_ca.paa";
    x = 0; y = 0; w = 0.3; h = 0.034;
};

class RscStructuredText {
    access = 0; type = 13; idc = -1; style = 2;
    colorBackground[] = {0,0,0,0};
    font = "RobotoCondensed"; size = 0.022; text = "";
    x = 0; y = 0; w = 0.3; h = 0.04;
};

// ── Settings Dialog — IDD 9001 ─────────────────────────────────────────────
#define SD_W        0.44
#define SD_H        0.38
#define SD_X        (safeZoneX + (safeZoneW - SD_W) / 2)
#define SD_Y        (safeZoneY + (safeZoneH - SD_H) / 2)
#define SD_PAD      0.010
#define SD_STRIP_H  0.006
#define SD_TITLE_H  0.036
#define SD_ROW_H    0.036
#define SD_PRESET_H 0.034
#define SD_BTN_H    0.044
#define SD_IW       (SD_W - SD_PAD * 2)
#define SD_IX       (SD_X + SD_PAD)
#define SD_LBL_W    0.110
#define SD_EDIT_W   0.060
#define SD_EDIT_X   (SD_IX + SD_LBL_W + SD_PAD)
#define SD_P5W      ((SD_IW - SD_EDIT_W - SD_LBL_W - SD_PAD * 5) / 5)

// Y anchors
#define SD_Y_TITLE    (SD_Y + SD_STRIP_H)
#define SD_Y_VOLROW   (SD_Y_TITLE + SD_TITLE_H + SD_PAD)
#define SD_Y_VOLPRE   (SD_Y_VOLROW + SD_ROW_H + SD_PAD * 0.5)
#define SD_Y_VDROW    (SD_Y_VOLPRE + SD_PRESET_H + SD_PAD * 1.5)
#define SD_Y_VDPRE    (SD_Y_VDROW + SD_ROW_H + SD_PAD * 0.5)
#define SD_Y_BTNS     (SD_Y + SD_H - SD_BTN_H - SD_PAD)
#define SD_MAIN_BTN_W ((SD_W - SD_PAD * 3) / 2)

// Preset button X positions (5 buttons filling space after label+edit)
#define SD_PX0  (SD_EDIT_X + SD_EDIT_W + SD_PAD)
#define SD_PX1  (SD_PX0 + SD_P5W + SD_PAD)
#define SD_PX2  (SD_PX1 + SD_P5W + SD_PAD)
#define SD_PX3  (SD_PX2 + SD_P5W + SD_PAD)
#define SD_PX4  (SD_PX3 + SD_P5W + SD_PAD)

class FTD_SettingsDialog {
    idd = 9001;
    movingEnable = 0;
    enableSimulation = 1;
    class controls {

        // ── Chrome ────────────────────────────────────────────────────────────
        class Background: RscText {
            idc = 100;
            x = SD_X; y = SD_Y; w = SD_W; h = SD_H;
            colorBackground[] = {0.137, 0.122, 0.125, 0.97};
        };
        class Strip: RscText {
            idc = 101;
            x = SD_X; y = SD_Y; w = SD_W; h = SD_STRIP_H;
            colorBackground[] = {0.0, 0.369, 0.722, 1};
        };
        class Title: RscStructuredText {
            idc = 102;
            x = SD_X; y = SD_Y_TITLE; w = SD_W; h = SD_TITLE_H;
            colorBackground[] = {0.04, 0.04, 0.04, 0.95};
            text = "<t align='center' font='RobotoCondensedBold' size='0.85' color='#FFFFFF'>SETTINGS</t>";
        };

        // ── Volume row ────────────────────────────────────────────────────────
        class VolLabel: RscStructuredText {
            idc = 110;
            x = SD_IX; y = SD_Y_VOLROW; w = SD_LBL_W; h = SD_ROW_H;
            text = "<t font='RobotoCondensedBold' size='0.75' color='#AAAAAA'>Volume</t>";
        };
        class VolEdit: RscEdit {
            idc = 111;
            x = SD_EDIT_X; y = SD_Y_VOLROW; w = SD_EDIT_W; h = SD_ROW_H;
            text = "100";
        };
        // Presets: 1% 10% 50% 75% 100%
        class VolPre1: RscButton {
            idc = -1; text = "1%";
            x = SD_PX0; y = SD_Y_VOLPRE; w = SD_P5W; h = SD_PRESET_H;
            action = "(findDisplay 9001 displayCtrl 111) ctrlSetText '1';";
        };
        class VolPre2: RscButton {
            idc = -1; text = "10%";
            x = SD_PX1; y = SD_Y_VOLPRE; w = SD_P5W; h = SD_PRESET_H;
            action = "(findDisplay 9001 displayCtrl 111) ctrlSetText '10';";
        };
        class VolPre3: RscButton {
            idc = -1; text = "50%";
            x = SD_PX2; y = SD_Y_VOLPRE; w = SD_P5W; h = SD_PRESET_H;
            action = "(findDisplay 9001 displayCtrl 111) ctrlSetText '50';";
        };
        class VolPre4: RscButton {
            idc = -1; text = "75%";
            x = SD_PX3; y = SD_Y_VOLPRE; w = SD_P5W; h = SD_PRESET_H;
            action = "(findDisplay 9001 displayCtrl 111) ctrlSetText '75';";
        };
        class VolPre5: RscButton {
            idc = -1; text = "100%";
            x = SD_PX4; y = SD_Y_VOLPRE; w = SD_P5W; h = SD_PRESET_H;
            action = "(findDisplay 9001 displayCtrl 111) ctrlSetText '100';";
        };

        // ── View Distance row ─────────────────────────────────────────────────
        class VdLabel: RscStructuredText {
            idc = 112;
            x = SD_IX; y = SD_Y_VDROW; w = SD_LBL_W; h = SD_ROW_H;
            text = "<t font='RobotoCondensedBold' size='0.75' color='#AAAAAA'>View Dist</t>";
        };
        class VdEdit: RscEdit {
            idc = 113;
            x = SD_EDIT_X; y = SD_Y_VDROW; w = SD_EDIT_W; h = SD_ROW_H;
            text = "3000";
        };
        // Presets: 500m 1000m 2500m 5000m 10000m
        class VdPre1: RscButton {
            idc = -1; text = "500";
            x = SD_PX0; y = SD_Y_VDPRE; w = SD_P5W; h = SD_PRESET_H;
            action = "(findDisplay 9001 displayCtrl 113) ctrlSetText '500';";
        };
        class VdPre2: RscButton {
            idc = -1; text = "1000";
            x = SD_PX1; y = SD_Y_VDPRE; w = SD_P5W; h = SD_PRESET_H;
            action = "(findDisplay 9001 displayCtrl 113) ctrlSetText '1000';";
        };
        class VdPre3: RscButton {
            idc = -1; text = "2500";
            x = SD_PX2; y = SD_Y_VDPRE; w = SD_P5W; h = SD_PRESET_H;
            action = "(findDisplay 9001 displayCtrl 113) ctrlSetText '2500';";
        };
        class VdPre4: RscButton {
            idc = -1; text = "5000";
            x = SD_PX3; y = SD_Y_VDPRE; w = SD_P5W; h = SD_PRESET_H;
            action = "(findDisplay 9001 displayCtrl 113) ctrlSetText '5000';";
        };
        class VdPre5: RscButton {
            idc = -1; text = "10000";
            x = SD_PX4; y = SD_Y_VDPRE; w = SD_P5W; h = SD_PRESET_H;
            action = "(findDisplay 9001 displayCtrl 113) ctrlSetText '10000';";
        };

        // ── Confirm buttons ───────────────────────────────────────────────────
        class BtnApply: RscButton {
            idc = 1; text = "Apply";
            x = SD_IX; y = SD_Y_BTNS;
            w = SD_MAIN_BTN_W; h = SD_BTN_H;
            action = "[] call FTD_fnc_settingsApply;";
        };
        class BtnCancel: RscButton {
            idc = 2; text = "Cancel";
            x = (SD_IX + SD_MAIN_BTN_W + SD_PAD); y = SD_Y_BTNS;
            w = SD_MAIN_BTN_W; h = SD_BTN_H;
            action = "closeDialog 2;";
        };
    };
};

class RscListBox {
    access = 0; type = CT_LISTBOX; idc = -1; style = ST_LEFT;
    font = "RobotoCondensed"; sizeEx = 0.024; rowHeight = 0.044;
    colorText[]             = {0.85,0.85,0.85,1};
    colorBackground[]       = {0.137, 0.122, 0.125, 1};
    colorSelect[]           = {1,1,1,1};
    colorSelectBackground[] = {0.20,0.20,0.20,1};
    colorSelectText[]       = {1,1,1,1};
    colorScrollbar[]        = {0.25,0.25,0.25,1};
    colorDisabled[]         = {0.4,0.4,0.4,1};
    colorShadow[]           = {0,0,0,0};
    borderSize = 0;
    soundSelect[]   = {"\A3\ui_f\data\sound\RscListbox\soundSelect",   0.1, 1};
    soundExpand[]   = {"\A3\ui_f\data\sound\RscListbox\soundExpand",   0.1, 1};
    soundCollapse[] = {"\A3\ui_f\data\sound\RscListbox\soundCollapse", 0.1, 1};
    x = 0; y = 0; w = 0.2; h = 0.3; onLBSelChanged = ""; multiSelect = 1;
    class ListScrollBar {
        color[]           = {0.8,0.8,0.8,0.5};
        autoScrollEnabled = 0;
        autoScrollDelay   = 5;
        autoScrollRewind  = 0;
        autoScrollSpeed   = -1;
        width       = 0.018;
        height      = 0.5;
        scrollSpeed = 0.06;
        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
        arrowFull  = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
        border     = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
        thumb      = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
    };
};

