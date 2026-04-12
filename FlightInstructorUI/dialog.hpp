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

