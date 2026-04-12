// FTD_fnc_notify.sqf
// Custom HUD notification — replaces hint
// Usage: [_title, _message, _type, _pos] call FTD_fnc_notify
//   _type : "info" | "warning" | "landing_set" | "landing_success"
//   _pos  : optional [x,y,z] — enables GPS minimap when provided

params [
    ["_title",   "Notification", [""]],
    ["_message", "",             [""]],
    ["_type",    "info",         [""]],
    ["_pos",     [],             [[]]]
];

private _showMap = (count _pos > 0);

// ── Remove any existing notification ─────────────────────────────────────────
{ if (!isNull _x) then { ctrlDelete _x; }; } forEach (missionNamespace getVariable ["FTD_notify_ctrls", []]);
missionNamespace setVariable ["FTD_notify_ctrls", []];

// ── Layout constants ──────────────────────────────────────────────────────────
private _pad    = 0.010;
private _panelW = 0.34;
private _stripH = 0.005;
private _titleH = 0.034;
private _msgH   = 0.026;
private _mapH   = if (_showMap) then { 0.26 } else { 0 };
private _mapGap = if (_showMap) then { _pad } else { 0 };
private _panelH = _stripH + _titleH + _msgH + _mapGap + _mapH + _pad + _stripH;

private _panelX = safeZoneX + safeZoneW - _panelW - 0.012;
private _panelY = safeZoneY + 0.012;

// ── Accent colour ─────────────────────────────────────────────────────────────
private _accent = switch (_type) do {
    case "landing_set":     { [0.000, 0.369, 0.722, 1.0] }; // NHS Blue
    case "landing_success": { [0.098, 0.627, 0.259, 1.0] }; // Green
    case "warning":         { [0.859, 0.392, 0.000, 1.0] }; // Orange
    default                 { [0.420, 0.420, 0.420, 1.0] }; // Gray
};

private _display = findDisplay 46;
private _ctrls   = [];

// ── Background panel ──────────────────────────────────────────────────────────
private _ctrlBg = _display ctrlCreate ["FTD_NotifyText", -1];
_ctrlBg ctrlSetPosition [_panelX, _panelY, _panelW, _panelH];
_ctrlBg ctrlSetBackgroundColor [0.08, 0.08, 0.08, 0.95];
_ctrlBg ctrlCommit 0;
_ctrls pushBack _ctrlBg;

// ── Top accent strip ──────────────────────────────────────────────────────────
private _ctrlStrip = _display ctrlCreate ["FTD_NotifyText", -1];
_ctrlStrip ctrlSetPosition [_panelX, _panelY, _panelW, _stripH];
_ctrlStrip ctrlSetBackgroundColor _accent;
_ctrlStrip ctrlCommit 0;
_ctrls pushBack _ctrlStrip;

// ── Title ─────────────────────────────────────────────────────────────────────
private _ctrlTitle = _display ctrlCreate ["RscStructuredText", -1];
_ctrlTitle ctrlSetPosition [_panelX, _panelY + _stripH, _panelW, _titleH];
_ctrlTitle ctrlSetBackgroundColor [0,0,0,0];
_ctrlTitle ctrlSetStructuredText parseText format ["<t align='center' font='RobotoCondensedBold' size='0.85' color='#FFFFFF'>%1</t>", _title];
_ctrlTitle ctrlCommit 0;
_ctrls pushBack _ctrlTitle;

// ── Message ───────────────────────────────────────────────────────────────────
private _ctrlMsg = _display ctrlCreate ["RscStructuredText", -1];
_ctrlMsg ctrlSetPosition [_panelX, _panelY + _stripH + _titleH, _panelW, _msgH];
_ctrlMsg ctrlSetBackgroundColor [0,0,0,0];
_ctrlMsg ctrlSetStructuredText parseText format ["<t align='center' font='RobotoCondensed' size='0.72' color='#BBBBBB'>%1</t>", _message];
_ctrlMsg ctrlCommit 0;
_ctrls pushBack _ctrlMsg;

// ── GPS minimap ───────────────────────────────────────────────────────────────
if (_showMap) then {
    private _mapY  = _panelY + _stripH + _titleH + _msgH + _mapGap;
    private _borderW = _panelW - (_pad * 2);
    private _borderX = _panelX + _pad;
    private _bPad  = 0.003;

    // Correct horizontal pad for aspect ratio so all four border sides appear equal width
    private _bPadX = _bPad * (safeZoneW / safeZoneH);
    private _bPadY = _bPad;

    // Border
    private _ctrlMapBorder = _display ctrlCreate ["FTD_NotifyText", -1];
    _ctrlMapBorder ctrlSetPosition [_borderX, _mapY, _borderW, _mapH];
    _ctrlMapBorder ctrlSetBackgroundColor [0.20, 0.20, 0.20, 0.95];
    _ctrlMapBorder ctrlCommit 0;
    _ctrls pushBack _ctrlMapBorder;

    // Map inset
    private _ctrlMap = _display ctrlCreate ["FTD_NotifyMap", -1];
    _ctrlMap ctrlSetPosition [_borderX + _bPadX, _mapY + _bPadY, _borderW - (_bPadX * 2), _mapH - (_bPadY * 2)];
    _ctrlMap ctrlCommit 0;
    _ctrls pushBack _ctrlMap;

    [_ctrlMap, _pos] spawn {
        params ["_m", "_p"];
        waitUntil { ctrlMapAnimDone _m };
        private _scale = 0.08;
        private _offsetY = _scale * worldSize * 0.01;
        _m ctrlMapAnimAdd [0, _scale, [_p select 0, (_p select 1) + _offsetY]];
        ctrlMapAnimCommit _m;
    };
};

// ── Bottom strip ──────────────────────────────────────────────────────────────
private _ctrlStripB = _display ctrlCreate ["FTD_NotifyText", -1];
_ctrlStripB ctrlSetPosition [_panelX, _panelY + _panelH - _stripH, _panelW, _stripH];
_ctrlStripB ctrlSetBackgroundColor [0.08, 0.08, 0.08, 0.95];
_ctrlStripB ctrlCommit 0;
_ctrls pushBack _ctrlStripB;

// ── Store refs and auto-dismiss ───────────────────────────────────────────────
missionNamespace setVariable ["FTD_notify_ctrls", _ctrls];

[_ctrls] spawn {
    params ["_cs"];
    sleep 7;
    { _x ctrlSetFade 1; _x ctrlCommit 0.5; } forEach _cs;
    sleep 0.6;
    { ctrlDelete _x; } forEach _cs;
};
