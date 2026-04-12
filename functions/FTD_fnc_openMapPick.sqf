// FTD_fnc_openMapPick.sqf
// Lets the instructor click a custom landing location on the map.

if !(visibleMap) then { openMap [true, false]; };
[localize "STR_FI_Notify_MapPickTitle", localize "STR_FI_Notify_MapPickMsg", "info"] call FTD_fnc_notify;

private _mapCtrl = (findDisplay 12) displayCtrl 51;

private _ehID = _mapCtrl ctrlAddEventHandler ["MouseButtonUp", {
    params ["_ctrl", "_button", "_x", "_y"];
    if (_button != 0) exitWith {};
    private _worldPos = _ctrl ctrlMapScreenToWorld [_x, _y];
    private _finalPos = [_worldPos select 0, _worldPos select 1, 0];
    _ctrl ctrlRemoveEventHandler ["MouseButtonUp", _thisEventHandler];
    [_finalPos, localize "STR_FI_Loc_Custom"] call FTD_fnc_setLandingLocation;
}];
