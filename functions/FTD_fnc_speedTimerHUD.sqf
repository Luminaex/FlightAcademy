// FTD_fnc_speedTimerHUD.sqf
// Shows the flight time HUD on this machine. Called via remoteExec on all
// instructors who are crew of the heli when SPEED is pressed.
// Params: [startTime]

params ["_startTime"];

private _heli    = vehicle player;
private _display = findDisplay 46;

// ── Layout — top-centre ───────────────────────────────────────────────────────
private _hw      = 0.18;
private _labelH  = 0.025;
private _timeH   = 0.060;
private _hx      = safeZoneX + (safeZoneW - _hw) / 2;
private _hy      = safeZoneY + 0.016;

// ── TIMER label — blue strip ──────────────────────────────────────────────────
private _hudLabel = _display ctrlCreate ["RscStructuredText", 9502];
_hudLabel ctrlSetPosition [_hx, _hy, _hw, _labelH];
_hudLabel ctrlSetBackgroundColor [0.000, 0.369, 0.722, 1.0];
_hudLabel ctrlSetStructuredText parseText format ["<t align='center' font='RobotoCondensedBold' size='0.60' color='#FFFFFF'>%1</t>", localize "STR_FI_Dlg_TimerLabel"];
_hudLabel ctrlCommit 0;

// ── Dark time background ──────────────────────────────────────────────────────
private _hudTimeBg = _display ctrlCreate ["RscText", 9501];
_hudTimeBg ctrlSetPosition [_hx, _hy + _labelH, _hw, _timeH];
_hudTimeBg ctrlSetBackgroundColor [0.08, 0.08, 0.08, 0.92];
_hudTimeBg ctrlCommit 0;

// ── Time text — FTD_TimerText uses ST_CENTER|ST_VCENTER so Arma centres it ────
private _hudTime = _display ctrlCreate ["FTD_TimerText", 9503];
_hudTime ctrlSetPosition [_hx, _hy + _labelH, _hw, _timeH];
_hudTime ctrlSetBackgroundColor [0,0,0,0];
_hudTime ctrlSetFontHeight 0.040;
_hudTime ctrlSetText "0:00";
_hudTime ctrlCommit 0;

// ── Update loop ───────────────────────────────────────────────────────────────
while {
    missionNamespace getVariable ["FI_speedTimer_active", false]
    && missionNamespace getVariable ["landingDetection_active", false]
    && alive _heli
    && vehicle player == _heli
} do {
    private _elapsed = diag_tickTime - _startTime;
    private _mins    = floor (_elapsed / 60);
    private _secs    = _elapsed - (_mins * 60);
    _hudTime ctrlSetText format ["%1:%2", _mins, [floor _secs, 2] call BIS_fnc_numberText];
    sleep 0.1;
};

// ── Clean up ──────────────────────────────────────────────────────────────────
{ ctrlDelete _x } forEach [_hudLabel, _hudTimeBg, _hudTime];
