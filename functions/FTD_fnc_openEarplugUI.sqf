// FTD_fnc_openEarplugUI.sqf
// Opens a small overlay dialog to set volume from 0-100.
// Works on the map display if open, otherwise on the main HUD display.

private _d = findDisplay 12;
if (isNull _d) then { _d = findDisplay 46; };
if (isNull _d) exitWith {};

{ if (!isNull _x) then { ctrlDelete _x; }; } forEach (uiNamespace getVariable ["FI_earplugCtrls", []]);
uiNamespace setVariable ["FI_earplugCtrls", []];

// ── Layout ────────────────────────────────────────────────────────────────────
private _pad     = 0.008;
private _stripH  = 0.006;
private _edgeH   = 0.003;
private _titleH  = 0.034;
private _labelH  = 0.032;
private _sliderH = 0.028;
private _btnH    = 0.046;
private _w       = 0.32;
private _h       = _stripH + _titleH + _pad + _labelH + _pad + _sliderH + _pad + _btnH + _pad;
private _x       = safeZoneX + (safeZoneW - _w) / 2;
private _y       = safeZoneY + (safeZoneH - _h) / 2;
private _btnY    = _y + _stripH + _titleH + _pad + _labelH + _pad + _sliderH + _pad;
private _btnW    = (_w - _pad * 3) / 2;

// ── Colours ───────────────────────────────────────────────────────────────────
private _dark    = [0.137, 0.122, 0.125, 1.00];
private _blue    = [0.000, 0.369, 0.722, 1.00];
private _textW   = [1,1,1,1];
private _hiGreen = [0.10, 0.72, 0.10, 1.00];
private _hiRed   = [0.72, 0.10, 0.10, 1.00];
private _shEdge  = [0.00, 0.00, 0.00, 0.70];

// ── Background ────────────────────────────────────────────────────────────────
private _bg = _d ctrlCreate ["RscText", -1];
_bg ctrlSetPosition [_x, _y, _w, _h];
_bg ctrlSetBackgroundColor _dark;
_bg ctrlCommit 0;

// ── Top accent strip ──────────────────────────────────────────────────────────
private _stripT = _d ctrlCreate ["RscText", -1];
_stripT ctrlSetPosition [_x, _y, _w, _stripH];
_stripT ctrlSetBackgroundColor _blue;
_stripT ctrlCommit 0;

// ── Title ─────────────────────────────────────────────────────────────────────
private _title = _d ctrlCreate ["RscStructuredText", -1];
_title ctrlSetPosition [_x, _y + _stripH, _w, _titleH];
_title ctrlSetBackgroundColor [0.04, 0.04, 0.04, 0.95];
_title ctrlSetStructuredText parseText format ["<t align='center' font='RobotoCondensedBold' size='0.85' color='#FFFFFF'>%1</t>", localize "STR_FI_Dlg_VolumeTitle"];
_title ctrlCommit 0;

// ── Current level label ───────────────────────────────────────────────────────
private _currentVol = round ((missionNamespace getVariable ["FI_earplugVolume", 1.0]) * 100);
private _labelY = _y + _stripH + _titleH + _pad;
private _label = _d ctrlCreate ["RscStructuredText", -1];
_label ctrlSetPosition [_x, _labelY, _w, _labelH];
_label ctrlSetBackgroundColor [0,0,0,0];
_label ctrlSetStructuredText parseText format ["<t align='center' font='RobotoCondensedBold' size='1.0' color='#FFFFFF'>%1%%</t>", _currentVol];
_label ctrlCommit 0;
uiNamespace setVariable ["FI_earplugLabel", _label];

// ── Slider ────────────────────────────────────────────────────────────────────
private _sliderY = _labelY + _labelH + _pad;
private _slider = _d ctrlCreate ["RscXSliderH", -1];
_slider ctrlSetPosition [_x + _pad, _sliderY, _w - _pad * 2, _sliderH];
_slider sliderSetRange [0, 100];
_slider sliderSetSpeed [1, 10];
_slider sliderSetPosition _currentVol;
_slider ctrlCommit 0;

_slider ctrlAddEventHandler ["SliderPosChanged", {
    params ["_ctrl", "_val"];
    private _lbl = uiNamespace getVariable ["FI_earplugLabel", controlNull];
    if (!isNull _lbl) then {
        _lbl ctrlSetStructuredText parseText format ["<t align='center' font='RobotoCondensedBold' size='1.0' color='#FFFFFF'>%1%%</t>", round _val];
    };
}];
uiNamespace setVariable ["FI_earplugSlider", _slider];

// ── Buttons ───────────────────────────────────────────────────────────────────
private _fnc_makeBtn = {
    params ["_bx","_by","_bw","_bh","_label","_bgCol","_hiCol"];
    private _btn = _d ctrlCreate ["RscButton", -1];
    _btn ctrlSetPosition [_bx, _by, _bw, _bh];
    _btn ctrlSetText _label;
    _btn ctrlSetFont "RobotoCondensed";
    _btn ctrlSetFontHeight 0.020;
    _btn ctrlSetBackgroundColor _bgCol;
    _btn ctrlSetTextColor [1,1,1,1];
    _btn ctrlCommit 0;
    private _hi = _d ctrlCreate ["RscText", -1];
    _hi ctrlSetPosition [_bx, _by, _bw, _edgeH];
    _hi ctrlSetBackgroundColor _hiCol;
    _hi ctrlCommit 0;
    private _sh = _d ctrlCreate ["RscText", -1];
    _sh ctrlSetPosition [_bx, _by + _bh - _edgeH, _bw, _edgeH];
    _sh ctrlSetBackgroundColor _shEdge;
    _sh ctrlCommit 0;
    [_btn, _hi, _sh]
};

private _rApply  = [_x + _pad,              _btnY, _btnW, _btnH, localize "STR_FI_Btn_Apply",  _dark, _hiGreen] call _fnc_makeBtn;
private _rCancel = [_x + _pad * 2 + _btnW,  _btnY, _btnW, _btnH, localize "STR_FI_Btn_Cancel", _dark, _hiRed  ] call _fnc_makeBtn;

private _btnApply  = _rApply  select 0;
private _btnCancel = _rCancel select 0;

uiNamespace setVariable ["FI_earplugCtrls", [_bg, _stripT, _title, _label, _slider,
    _btnApply,  _rApply  select 1, _rApply  select 2,
    _btnCancel, _rCancel select 1, _rCancel select 2]];

_btnApply ctrlAddEventHandler ["ButtonClick", {
    private _sl = uiNamespace getVariable ["FI_earplugSlider", controlNull];
    if (isNull _sl) exitWith {};
    private _val = sliderPosition _sl;
    private _volume = _val / 100;
    _volume fadeSound _volume;
    missionNamespace setVariable ["FI_earplugVolume", _volume];
    { if (!isNull _x) then { ctrlDelete _x; }; } forEach (uiNamespace getVariable ["FI_earplugCtrls", []]);
    uiNamespace setVariable ["FI_earplugCtrls", []];
    [localize "STR_FI_Notify_VolumeTitle", format [localize "STR_FI_Notify_VolumeMsg", round _val], "info"] call FTD_fnc_notify;
}];

_btnCancel ctrlAddEventHandler ["ButtonClick", {
    { if (!isNull _x) then { ctrlDelete _x; }; } forEach (uiNamespace getVariable ["FI_earplugCtrls", []]);
    uiNamespace setVariable ["FI_earplugCtrls", []];
}];
