// FTD_fnc_openTpPlayerSelect.sqf
// Teleports the instructor and all checked players in the left panel to _targetPos.
// params: [_targetPos]

params ["_targetPos"];

private _ctrls = uiNamespace getVariable ["FI_playerCheckboxes", []];

private _selected = [];
{
    private _cb = _x select 0;
    private _pl = _x select 2;
    if (ctrlChecked _cb) then { _selected pushBack _pl; };
} forEach _ctrls;

{ ctrlDelete _x } forEach (uiNamespace getVariable ["FI_overlayCtrls", []]);
uiNamespace setVariable ["FI_overlayCtrls", []];

player setPosATL [_targetPos select 0, _targetPos select 1, 0];
openMap [false, false];
[localize "STR_FI_Notify_TeleportedTitle", format [localize "STR_FI_Notify_TeleportedMsg", mapGridPosition _targetPos], "info"] call FTD_fnc_notify;
{ [_targetPos] remoteExec ["FTD_fnc_tpPlayer", _x]; } forEach _selected;
