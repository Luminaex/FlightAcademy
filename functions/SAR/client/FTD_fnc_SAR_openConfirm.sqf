// FTD_fnc_SAR_openConfirm.sqf
// Confirmation dialog shown when a SAR mission is already running and the instructor
// presses "SAR Mission" again. Prevents accidental instant-restart.
// Usage: call FTD_fnc_SAR_openConfirm;

private _existing = uiNamespace getVariable ["FI_SARConfirmCtrls", []];
{ ctrlDelete _x } forEach _existing;
uiNamespace setVariable ["FI_SARConfirmCtrls", []];

private _display = findDisplay 12;
if (isNull _display) exitWith {};

// ── Layout ────────────────────────────────────────────────────────────────────
private _pad    = 0.008;
private _stripH = 0.006;
private _edgeH  = 0.003;
private _titleH = 0.034;
private _btnH   = 0.046;
private _btnW   = 0.120;
private _w      = 0.38;
private _h      = _stripH + _titleH + _pad * 3 + _btnH;
private _x      = safeZoneX + (safeZoneW - _w) * 0.5;
private _y      = safeZoneY + (safeZoneH - _h) * 0.5;
private _btnY   = _y + _stripH + _titleH + _pad * 2;

// ── Colours ───────────────────────────────────────────────────────────────────
private _dark   = [0.137, 0.122, 0.125, 1.00];
private _blue   = [0.000, 0.369, 0.722, 1.00];
private _hiGreen = [0.10, 0.72, 0.10, 1.00];
private _hiRed   = [0.72, 0.10, 0.10, 1.00];
private _shEdge  = [0.00, 0.00, 0.00, 0.70];

private _fnc_makeBtn = {
    params ["_bx","_by","_bw","_bh","_label","_bg","_hiCol"];
    private _btn = _display ctrlCreate ["RscButton", -1];
    _btn ctrlSetPosition [_bx, _by, _bw, _bh];
    _btn ctrlSetText _label;
    _btn ctrlSetFont "RobotoCondensed";
    _btn ctrlSetFontHeight 0.020;
    _btn ctrlSetBackgroundColor _bg;
    _btn ctrlSetTextColor [1,1,1,1];
    _btn ctrlCommit 0;
    private _hi = _display ctrlCreate ["RscText", -1];
    _hi ctrlSetPosition [_bx, _by, _bw, _edgeH];
    _hi ctrlSetBackgroundColor _hiCol;
    _hi ctrlCommit 0;
    private _sh = _display ctrlCreate ["RscText", -1];
    _sh ctrlSetPosition [_bx, _by + _bh - _edgeH, _bw, _edgeH];
    _sh ctrlSetBackgroundColor _shEdge;
    _sh ctrlCommit 0;
    [_btn, _hi, _sh]
};

// ── Background ────────────────────────────────────────────────────────────────
private _bg = _display ctrlCreate ["RscText", -1];
_bg ctrlSetPosition [_x, _y, _w, _h];
_bg ctrlSetBackgroundColor _dark;
_bg ctrlCommit 0;

private _strip = _display ctrlCreate ["RscText", -1];
_strip ctrlSetPosition [_x, _y, _w, _stripH];
_strip ctrlSetBackgroundColor _blue;
_strip ctrlCommit 0;

// ── Title ─────────────────────────────────────────────────────────────────────
private _title = _display ctrlCreate ["RscStructuredText", -1];
_title ctrlSetPosition [_x, _y + _stripH, _w, _titleH];
_title ctrlSetBackgroundColor [0.04, 0.04, 0.04, 0.95];
_title ctrlSetStructuredText parseText "<t align='center' font='RobotoCondensedBold' size='0.85' color='#FFFFFF'>SAR MISSION ALREADY ACTIVE — RESTART?</t>";
_title ctrlCommit 0;

// ── Buttons ───────────────────────────────────────────────────────────────────
private _totalBtnW = _btnW * 2 + _pad;
private _btnStartX = _x + (_w - _totalBtnW) / 2;

private _rRestart = [_btnStartX,              _btnY, _btnW, _btnH, "Restart", _dark, _hiGreen] call _fnc_makeBtn;
private _rCancel  = [_btnStartX + _btnW + _pad, _btnY, _btnW, _btnH, "Cancel",  _dark, _hiRed  ] call _fnc_makeBtn;

private _btnRestart = _rRestart select 0;
private _btnCancel  = _rCancel  select 0;

uiNamespace setVariable ["FI_SARConfirmCtrls", [_bg, _strip, _title,
    _btnRestart, _rRestart select 1, _rRestart select 2,
    _btnCancel,  _rCancel  select 1, _rCancel  select 2]];

_btnRestart ctrlAddEventHandler ["ButtonClick", {
    { ctrlDelete _x } forEach (uiNamespace getVariable ["FI_SARConfirmCtrls", []]);
    uiNamespace setVariable ["FI_SARConfirmCtrls", []];
    [getPlayerUID player] remoteExec ["FTD_fnc_SAR_startMission", 2];
}];

_btnCancel ctrlAddEventHandler ["ButtonClick", {
    { ctrlDelete _x } forEach (uiNamespace getVariable ["FI_SARConfirmCtrls", []]);
    uiNamespace setVariable ["FI_SARConfirmCtrls", []];
}];
