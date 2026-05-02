// FTD_fnc_openInstructorUI.sqf
// Injects the instructor overlay onto the vanilla map display.

diag_log format ["[FTD][openInstructorUI] Opening for %1", name player];
private _t0 = diag_tickTime;

// Clean up any existing overlay first
{ if (!isNull _x) then { ctrlDelete _x; }; } forEach (uiNamespace getVariable ["FI_overlayCtrls", []]);
uiNamespace setVariable ["FI_overlayCtrls", []];

// Guard to prevent Map event handler from re-triggering this function
uiNamespace setVariable ["FI_overlayOpening", true];

if !(visibleMap) then { openMap [true, false]; };
waitUntil { !isNull (findDisplay 12) };
private _d = findDisplay 12;

// ── Layout ────────────────────────────────────────────────────────────────────
private _pad        = 0.006;
private _sz_x       = safeZoneX;
private _sz_y       = safeZoneY;
private _sz_w       = safeZoneW;
private _sz_h       = safeZoneH;
private _vanillaTopH = 0.060;
private _btnH       = 0.046;
private _btnW       = 0.100;
private _btnGap     = 0.004;
private _btnBarH    = _btnH + (_pad * 2);
private _listW      = 0.26;
private _hintH      = 0.030;
private _btnY       = _sz_y + _sz_h - _btnH - _pad;
private _listX      = _sz_x + _sz_w - _listW;
private _listY      = _sz_y + _vanillaTopH;
private _listH      = (_sz_y + _sz_h) - _listY - _btnH - _pad;

private _fnc_btnL = { (_sz_x + _pad) + (_btnW * _this) + (_btnGap * _this) };
private _fnc_btnR = { _sz_x + _sz_w - (_btnW * (_this + 1)) - (_btnGap * _this) - _pad };

// ── Colours ───────────────────────────────────────────────────────────────────
private _nhsBlueS = [0.000, 0.369, 0.722, 1.00];
private _dark     = [0.137, 0.122, 0.125, 1.00];
private _darkS    = [0.137, 0.122, 0.125, 1.00];
private _textW    = [1,1,1,1];
private _hiEdge   = [0.35, 0.35, 0.35, 0.85];
private _hiBlue   = [0.000, 0.369, 0.722, 0.90];
private _hiGreen  = [0.10, 0.72, 0.10, 1.00];
private _hiRed    = [0.72, 0.10, 0.10, 1.00];
private _shEdge   = [0.00, 0.00, 0.00, 0.70];
private _edgeH    = 0.003;

// ── Helper: make a static text control ───────────────────────────────────────
private _fnc_makeText = {
    params ["_x","_y","_w","_h","_text","_bg","_fg","_font","_sz"];
    private _c = _d ctrlCreate ["RscText", -1];
    _c ctrlSetPosition [_x, _y, _w, _h];
    _c ctrlSetBackgroundColor _bg;
    _c ctrlSetTextColor _fg;
    _c ctrlSetText _text;
    _c ctrlSetFont _font;
    _c ctrlSetFontHeight _sz;
    _c ctrlCommit 0;
    _c
};

// ── Helper: make a button ─────────────────────────────────────────────────────
private _fnc_makeBtn = {
    params ["_x","_y","_w","_h","_text","_bg","_fg","_action"];
    private _c = _d ctrlCreate ["RscButton", -1];
    _c ctrlSetPosition [_x, _y, _w, _h];
    _c ctrlSetBackgroundColor _bg;
    _c ctrlSetTextColor _fg;
    _c ctrlSetText _text;
    _c ctrlSetFont "RobotoCondensed";
    _c ctrlSetFontHeight 0.020;
    _c ctrlCommit 0;
    _c ctrlAddEventHandler ["ButtonClick", _action];
    _c
};

// ── Helper: add highlight/shadow edges to a button for depth ─────────────────
private _fnc_addDepth = {
    params ["_x","_y","_w","_h","_hiCol"];
    private _hi = [_x, _y,            _w, _edgeH, "", _hiCol,  [0,0,0,0], "RobotoCondensed", 0.01] call _fnc_makeText;
    private _sh = [_x, _y+_h-_edgeH, _w, _edgeH, "", _shEdge, [0,0,0,0], "RobotoCondensed", 0.01] call _fnc_makeText;
    [_hi, _sh]
};

// ── Right panel background ────────────────────────────────────────────────────
private _listBg = [_listX, _listY, _listW, _listH, "", _dark, [0,0,0,0], "RobotoCondensed", 0.020] call _fnc_makeText;

// ── Location list ─────────────────────────────────────────────────────────────
private _list = _d ctrlCreate ["RscListBox", -1];
_list ctrlSetPosition [_listX, _listY, _listW, _listH];
_list ctrlSetBackgroundColor _darkS;
_list ctrlSetFont "RobotoCondensed";
_list ctrlSetFontHeight 0.024;
_list ctrlCommit 0;
uiNamespace setVariable ["FI_mapOverlayList", _list];

lbClear _list;
{
    _x params ["_pos", "_name", "_rooftop"];
    private _idx = _list lbAdd _name;
    _list lbSetData [_idx, str [_pos, _rooftop]];
} forEach FI_locations;
_list lbSetCurSel 0;

// ── Helper: start spinning preview marker ─────────────────────────────────────
private _fnc_startSpin = {
    private _spinID = (uiNamespace getVariable ["FI_markerSpinID", 0]) + 1;
    uiNamespace setVariable ["FI_markerSpinID", _spinID];
    [_spinID] spawn {
        params ["_myID"];
        private _dir = 0;
        private _scale = 0.4;
        private _scaleDir = 0.02;
        while {
            (uiNamespace getVariable ["FI_markerSpinID", 0] == _myID) &&
            (getMarkerType "FI_PreviewMarker" != "")
        } do {
            "FI_PreviewMarker" setMarkerDir _dir;
            "FI_PreviewMarker" setMarkerSize [_scale, _scale];
            _dir = (_dir + 10) % 360;
            _scale = _scale + _scaleDir;
            if (_scale <= 0.3 || _scale >= 0.6) then { _scaleDir = -_scaleDir; };
            sleep 0.05;
        };
    };
};

// ── Helper: place preview marker and start spin ───────────────────────────────
private _fnc_placeMarker = {
    params ["_pos"];
    deleteMarker "FI_PreviewMarker";
    private _m = createMarker ["FI_PreviewMarker", _pos];
    _m setMarkerType "selector_selectedEnemy";
    _m setMarkerColor "ColorRed";
    _m setMarkerAlpha 1;
    call _fnc_startSpin;
};

// List selection — pan map, place marker
_list ctrlAddEventHandler ["LBSelChanged", {
    params ["_ctrl", "_idx"];
    if (_idx < 0) exitWith {};
    private _raw = call compile (_ctrl lbData _idx);
    private _pos = _raw select 0;
    private _mapCtrl = (findDisplay 12) displayCtrl 51;
    _mapCtrl ctrlMapAnimAdd [0.4, 0.03, [_pos select 0, _pos select 1]];
    ctrlMapAnimCommit _mapCtrl;
    [_pos] call (uiNamespace getVariable ["FI_fnc_placeMarker", {}]);
}];

// Store helper so event handler closure can reach it
uiNamespace setVariable ["FI_fnc_placeMarker", _fnc_placeMarker];

// List double-click — set landing and close
_list ctrlAddEventHandler ["LBDblClick", {
    params ["_ctrl", "_idx"];
    if (_idx < 0) exitWith {};
    private _raw = call compile (_ctrl lbData _idx);
    private _pos = _raw select 0;
    private _rooftop = _raw select 1;
    private _name = _ctrl lbText _idx;
    if (count _pos > 0) then {
        deleteMarker "FI_PreviewMarker";
        [_pos, _name, _rooftop] call FTD_fnc_setLandingLocation;
        { ctrlDelete _x } forEach (uiNamespace getVariable ["FI_overlayCtrls", []]);
        uiNamespace setVariable ["FI_overlayCtrls", []];
        openMap [false, false];
    };
}];

private _pathOn = missionNamespace getVariable ["FI_pathShown", false];

// ── Hint line ─────────────────────────────────────────────────────────────────
private _hintY = _btnY - _pad - _hintH;
private _hint = _d ctrlCreate ["RscStructuredText", -1];
_hint ctrlSetPosition [_sz_x, _hintY, _sz_w, _hintH];
_hint ctrlSetBackgroundColor [0,0,0,0];
_hint ctrlSetStructuredText parseText format ["<t align='center' font='RobotoCondensed' size='0.70' color='#888888'>%1</t>", localize "STR_FI_Hint_Keybinds"];
_hint ctrlCommit 0;

// ── Bottom bar ────────────────────────────────────────────────────────────────
private _bottomBar = [_sz_x, _btnY - _pad, _sz_w, _btnBarH, "", _darkS, [0,0,0,0], "RobotoCondensed", 0.020] call _fnc_makeText;

// ── Left buttons ──────────────────────────────────────────────────────────────
private _btnM900 = [0 call _fnc_btnL, _btnY, _btnW, _btnH, localize "STR_FI_Btn_SpawnM900", _dark, _textW,
    { ["B_Heli_Light_01_F"] call FTD_fnc_openSpawnConfirm; }] call _fnc_makeBtn;
private _depM900 = [0 call _fnc_btnL, _btnY, _btnW, _btnH, _hiEdge] call _fnc_addDepth;

private _btnOrca = [1 call _fnc_btnL, _btnY, _btnW, _btnH, localize "STR_FI_Btn_SpawnOrca", _dark, _textW,
    { ["O_Heli_Light_02_unarmed_F"] call FTD_fnc_openSpawnConfirm; }] call _fnc_makeBtn;
private _depOrca = [1 call _fnc_btnL, _btnY, _btnW, _btnH, _hiEdge] call _fnc_addDepth;

private _btnSpeed = [2 call _fnc_btnL, _btnY, _btnW, _btnH, localize "STR_FI_Btn_TimeTrial", _dark, _textW,
    { [] call FTD_fnc_quickStart; }] call _fnc_makeBtn;
private _depSpeed = [2 call _fnc_btnL, _btnY, _btnW, _btnH, _hiEdge] call _fnc_addDepth;

private _btnCar = [3 call _fnc_btnL, _btnY, _btnW, _btnH, localize "STR_FI_Btn_RespawnCar", _dark, _textW,
    { [] remoteExec ["FTD_fnc_respawnCar", 2]; }] call _fnc_makeBtn;
private _depCar = [3 call _fnc_btnL, _btnY, _btnW, _btnH, _hiEdge] call _fnc_addDepth;

private _btnPath = [4 call _fnc_btnL, _btnY, _btnW, _btnH,
    localize (if (_pathOn) then {"STR_FI_Btn_PathOn"} else {"STR_FI_Btn_PathOff"}), _dark, _textW,
    {
        private _shown = missionNamespace getVariable ["FI_pathShown", false];
        private _btnP  = uiNamespace getVariable ["FI_mapOverlayBtnPath", controlNull];
        private _pathHi = uiNamespace getVariable ["FI_mapOverlayPathHi", controlNull];
        private _newState = !_shown;
        private _alpha = if (_newState) then {1} else {0};
        for "_i" from 0 to 8 do { (format ["path_%1", _i]) setMarkerAlpha _alpha; };
        if (!isNull _btnP) then { _btnP ctrlSetText localize (if (_newState) then {"STR_FI_Btn_PathOn"} else {"STR_FI_Btn_PathOff"}); };
        if (!isNull _pathHi) then {
            _pathHi ctrlSetBackgroundColor (if (_newState) then {[0.10,0.72,0.10,1.00]} else {[0.72,0.10,0.10,1.00]});
        };
        missionNamespace setVariable ["FI_pathShown", _newState];
    }] call _fnc_makeBtn;
uiNamespace setVariable ["FI_mapOverlayBtnPath", _btnPath];
private _depPath = [4 call _fnc_btnL, _btnY, _btnW, _btnH, if (_pathOn) then {_hiGreen} else {_hiRed}] call _fnc_addDepth;
uiNamespace setVariable ["FI_mapOverlayPathHi", _depPath select 0];

private _btnVolume = [5 call _fnc_btnL, _btnY, _btnW, _btnH, localize "STR_FI_Btn_Volume", _dark, _textW,
    { call FTD_fnc_openEarplugUI; }] call _fnc_makeBtn;
private _depVolume = [5 call _fnc_btnL, _btnY, _btnW, _btnH, _hiEdge] call _fnc_addDepth;

private _btnSAR = [6 call _fnc_btnL, _btnY, _btnW, _btnH, "SAR Mission", _dark, _textW,
    {
        if (missionNamespace getVariable ["SAR_active", false]) then {
            call FTD_fnc_SAR_openConfirm;
        } else {
            [getPlayerUID player] remoteExec ["FTD_fnc_SAR_startMission", 2];
        };
    }] call _fnc_makeBtn;
private _depSAR = [6 call _fnc_btnL, _btnY, _btnW, _btnH, _hiEdge] call _fnc_addDepth;

// ── Right buttons ─────────────────────────────────────────────────────────────
private _btnSet = [2 call _fnc_btnR, _btnY, _btnW, _btnH, localize "STR_FI_Btn_SetLanding", _dark, _textW,
    {
        private _list = uiNamespace getVariable ["FI_mapOverlayList", controlNull];
        if (isNull _list) exitWith {};
        private _idx = lbCurSel _list;
        if (_idx < 0) exitWith {};
        private _raw = call compile (_list lbData _idx);
        private _pos = _raw select 0;
        private _rooftop = _raw select 1;
        private _name = _list lbText _idx;
        if (count _pos > 0) then {
            deleteMarker "FI_PreviewMarker";
            [_pos, _name, _rooftop] call FTD_fnc_setLandingLocation;
            { ctrlDelete _x } forEach (uiNamespace getVariable ["FI_overlayCtrls", []]);
            uiNamespace setVariable ["FI_overlayCtrls", []];
            openMap [false, false];
        };
    }] call _fnc_makeBtn;
private _depSet = [2 call _fnc_btnR, _btnY, _btnW, _btnH, _hiBlue] call _fnc_addDepth;

private _btnMapPick = [1 call _fnc_btnR, _btnY, _btnW, _btnH, localize "STR_FI_Btn_MapPick", _dark, _textW,
    { call FTD_fnc_openMapPick; }] call _fnc_makeBtn;
private _depMapPick = [1 call _fnc_btnR, _btnY, _btnW, _btnH, _hiEdge] call _fnc_addDepth;

private _btnClear = [0 call _fnc_btnR, _btnY, _btnW, _btnH, localize "STR_FI_Btn_ClearTask", _dark, _textW,
    {
        missionNamespace setVariable ["landingDetection_active", false];
        missionNamespace setVariable ["FI_speedTimer_start", nil];
        ["delete"] remoteExec ["FTD_fnc_taskManager", 2];
        deleteMarker "LandingMarker";
        [localize "STR_FI_Notify_TaskClearedTitle", localize "STR_FI_Notify_TaskClearedMsg", "info"] call FTD_fnc_notify;
    }] call _fnc_makeBtn;
private _depClear = [0 call _fnc_btnR, _btnY, _btnW, _btnH, _hiEdge] call _fnc_addDepth;

private _sarActive = missionNamespace getVariable ["SAR_active", false];
private _btnSARMark = [3 call _fnc_btnR, _btnY, _btnW, _btnH, "Mark Pilot", if (_sarActive) then {_dark} else {[0.08,0.08,0.08,0.95]}, if (_sarActive) then {_textW} else {[0.4,0.4,0.4,1]},
    {
        if !(missionNamespace getVariable ["SAR_active", false]) exitWith {
            ["SAR Inactive", "No SAR mission is currently active.", "warning"] call FTD_fnc_notify;
        };
        private _victim = missionNamespace getVariable ["SAR_victim", objNull];
        if (isNull _victim) exitWith {};
        private _pos = getPosATL (vehicle _victim);
        deleteMarker "SAR_InstructorMark";
        private _m = createMarker ["SAR_InstructorMark", _pos];
        _m setMarkerShape "ICON";
        _m setMarkerType "hd_dot";
        _m setMarkerColor "ColorRed";
        _m setMarkerText "Pilot";
        ["Pilot Marked", "Pilot position marked on the map.", "info", _pos] call FTD_fnc_notify;
    }] call _fnc_makeBtn;
private _depSARMark = [3 call _fnc_btnR, _btnY, _btnW, _btnH, if (_sarActive) then {_hiEdge} else {[0.15,0.15,0.15,0.5]}] call _fnc_addDepth;

// Store all controls for cleanup
private _ctrls = [_hint, _listBg, _list, _bottomBar,
    _btnM900,  _depM900 select 0,  _depM900 select 1,
    _btnOrca,  _depOrca select 0,  _depOrca select 1,
    _btnSpeed, _depSpeed select 0, _depSpeed select 1,
    _btnCar,   _depCar select 0,   _depCar select 1,
    _btnPath,  _depPath select 0,  _depPath select 1,
    _btnVolume,_depVolume select 0,_depVolume select 1,
    _btnSAR,   _depSAR select 0,   _depSAR select 1,
    _btnSet,     _depSet select 0,     _depSet select 1,
    _btnMapPick, _depMapPick select 0, _depMapPick select 1,
    _btnClear,   _depClear select 0,   _depClear select 1,
    _btnSARMark, _depSARMark select 0, _depSARMark select 1];
uiNamespace setVariable ["FI_overlayCtrls", _ctrls];
uiNamespace setVariable ["FI_overlayOpening", false];

diag_log format ["[FTD][openInstructorUI] UI built in %1s — %2 locations", round ((diag_tickTime - _t0) * 100) / 100, count FI_locations];

// Pan map and place initial marker
private _firstPos = (FI_locations select 0) select 0;
private _mapCtrl = _d displayCtrl 51;
_mapCtrl ctrlMapAnimAdd [0, 0.03, [_firstPos select 0, _firstPos select 1]];
ctrlMapAnimCommit _mapCtrl;
[_firstPos] call _fnc_placeMarker;

// Clean up overlay when map is closed — register only once
if ((uiNamespace getVariable ["FI_mapCleanupEH", -1]) == -1) then {
    private _ehID = addMissionEventHandler ["Map", {
        params ["_isOpen"];
        if (_isOpen) exitWith {};
        { if (!isNull _x) then { ctrlDelete _x; }; } forEach (uiNamespace getVariable ["FI_overlayCtrls", []]);
        uiNamespace setVariable ["FI_overlayCtrls", []];
        deleteMarker "FI_PreviewMarker";
    }];
    uiNamespace setVariable ["FI_mapCleanupEH", _ehID];
};
