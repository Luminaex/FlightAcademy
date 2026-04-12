// FTD_fnc_setLandingLocation.sqf
// Called by preset buttons and map pick
// Usage: [position, locationName] call FTD_fnc_setLandingLocation;

params [
    ["_pos",      [0,0,0]],
    ["_name",     localize "STR_FI_Loc_Custom"],
    ["_rooftop",  false]
];

diag_log format ["[FTD][setLandingLocation] '%1' pos=%2 rooftop=%3 by %4", _name, _pos, _rooftop, name player];

missionNamespace setVariable ["landingIsRooftop", _rooftop, false];

// Clean up marker (task cleanup handled inside "create" case of FTD_fnc_taskManager)
deleteMarker "LandingMarker";

// Kill existing detection loop
missionNamespace setVariable ["landingDetection_active", false, false];

// Store position
missionNamespace setVariable ["landingPos", _pos, false];
missionNamespace setVariable ["landingName", _name, false];

// Create task for all crew
private _crewUnits = crew vehicle player;
if (count _crewUnits == 0) then {
    diag_log "[FTD][setLandingLocation] No crew in vehicle — falling back to player only";
    _crewUnits = [player];
};
diag_log format ["[FTD][setLandingLocation] Creating task for %1 unit(s)", count _crewUnits];
["create", _crewUnits, _name, _pos] remoteExec ["FTD_fnc_taskManager", 2];

missionNamespace setVariable ["FlightTask_active", player, false];

[localize "STR_FI_Notify_LandingSetTitle", _name, "landing_set", _pos] call FTD_fnc_notify;

// Start detection loop
private _id = (missionNamespace getVariable ["landingDetection_id", 0]) + 1;
missionNamespace setVariable ["landingDetection_id", _id];
missionNamespace setVariable ["landingDetection_active", true, false];
diag_log format ["[FTD][setLandingLocation] Starting detection loop id=%1 for '%2'", _id, _name];
call FTD_fnc_landingDetection;