// FTD_fnc_openSpawnConfirm.sqf
params [["_vehicleClass", "B_Heli_Light_01_F"]];

private _heliLabel = switch (_vehicleClass) do {
    case "B_Heli_Light_01_F":         { "M900" };
    case "O_Heli_Light_02_unarmed_F": { "Orca" };
    default { _vehicleClass };
};

uiNamespace setVariable ["FI_confirmVehicleClass", _vehicleClass];

private _existing = uiNamespace getVariable ["FI_confirmCtrls", []];
{ ctrlDelete _x } forEach _existing;
uiNamespace setVariable ["FI_confirmCtrls", []];

private _display = findDisplay 12;
if (isNull _display) exitWith {};

// ── Layout ────────────────────────────────────────────────────────────────────
private _pad     = 0.008;
private _stripH  = 0.006;
private _edgeH   = 0.003;
private _titleH  = 0.034;
private _btnH    = 0.046;
private _btnW    = 0.110;
private _w       = 0.38;
private _h       = _stripH + _titleH + _pad * 3 + _btnH;
private _x       = safeZoneX + (safeZoneW - _w) * 0.5;
private _y       = safeZoneY + (safeZoneH - _h) * 0.5;
private _btnY    = _y + _stripH + _titleH + _pad * 2;

// ── Colours ───────────────────────────────────────────────────────────────────
private _dark    = [0.137, 0.122, 0.125, 1.00];
private _blue    = [0.000, 0.369, 0.722, 1.00];
private _textW   = [1,1,1,1];
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
    // depth edges
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

// ── Top accent strip ──────────────────────────────────────────────────────────
private _stripT = _display ctrlCreate ["RscText", -1];
_stripT ctrlSetPosition [_x, _y, _w, _stripH];
_stripT ctrlSetBackgroundColor _blue;
_stripT ctrlCommit 0;

// ── Title ─────────────────────────────────────────────────────────────────────
private _titleCtrl = _display ctrlCreate ["RscStructuredText", -1];
_titleCtrl ctrlSetPosition [_x, _y + _stripH, _w, _titleH];
_titleCtrl ctrlSetBackgroundColor [0.04, 0.04, 0.04, 0.95];
_titleCtrl ctrlSetStructuredText parseText format ["<t align='center' font='RobotoCondensedBold' size='0.85' color='#FFFFFF'>%1</t>", format [localize "STR_FI_Dlg_SpawnWhere", toUpper _heliLabel]];
_titleCtrl ctrlCommit 0;

// ── Buttons ───────────────────────────────────────────────────────────────────
private _totalBtnW = _btnW * 3 + _pad * 2;
private _btnStartX = _x + (_w - _totalBtnW) / 2;

private _rKavala = [_btnStartX,                  _btnY, _btnW, _btnH, localize "STR_FI_Btn_Kavala", _dark, _hiGreen] call _fnc_makeBtn;
private _rHere   = [_btnStartX + _btnW + _pad,   _btnY, _btnW, _btnH, localize "STR_FI_Btn_Here",   _dark, _hiGreen] call _fnc_makeBtn;
private _rCancel = [_btnStartX + (_btnW + _pad)*2,_btnY, _btnW, _btnH, localize "STR_FI_Btn_Cancel", _dark, _hiRed  ] call _fnc_makeBtn;

private _btnKavala = _rKavala select 0;
private _btnHere   = _rHere   select 0;
private _btnCancel = _rCancel select 0;

uiNamespace setVariable ["FI_confirmCtrls", [_bg, _stripT, _titleCtrl,
    _btnKavala, _rKavala select 1, _rKavala select 2,
    _btnHere,   _rHere   select 1, _rHere   select 2,
    _btnCancel, _rCancel select 1, _rCancel select 2]];

_btnKavala ctrlAddEventHandler ["ButtonClick", {
    { ctrlDelete _x } forEach (uiNamespace getVariable ["FI_confirmCtrls", []]);
    uiNamespace setVariable ["FI_confirmCtrls", []];
    private _vc = uiNamespace getVariable ["FI_confirmVehicleClass", "B_Heli_Light_01_F"];
    { ctrlDelete _x } forEach (uiNamespace getVariable ["FI_overlayCtrls", []]);
    uiNamespace setVariable ["FI_overlayCtrls", []];
    openMap [false, false];
    [_vc, [3731.7, 12976.3, 19.596], 180] call FTD_fnc_spawnVehicle;
}];

_btnHere ctrlAddEventHandler ["ButtonClick", {
    { ctrlDelete _x } forEach (uiNamespace getVariable ["FI_confirmCtrls", []]);
    uiNamespace setVariable ["FI_confirmCtrls", []];
    private _vc = uiNamespace getVariable ["FI_confirmVehicleClass", "B_Heli_Light_01_F"];
    { ctrlDelete _x } forEach (uiNamespace getVariable ["FI_overlayCtrls", []]);
    uiNamespace setVariable ["FI_overlayCtrls", []];
    openMap [false, false];
    [_vc] spawn {
        params ["_vc"];
        private _pos = player modelToWorldVisual [0, 5, 0];
        _pos set [2, 0];
        private _dir = getDir player;
        [_vc, _pos, _dir] call FTD_fnc_spawnVehicle;
    };
}];

_btnCancel ctrlAddEventHandler ["ButtonClick", {
    { ctrlDelete _x } forEach (uiNamespace getVariable ["FI_confirmCtrls", []]);
    uiNamespace setVariable ["FI_confirmCtrls", []];
}];
