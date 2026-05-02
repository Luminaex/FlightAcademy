// FTD_fnc_SAR_cleanup.sqf
// Removes SAR NPC, markers, and resets all SAR state variables.
// Safe to call when no mission is active.
// Usage: call FTD_fnc_SAR_cleanup;

if (!isServer) exitWith {};

diag_log "[FTD][SAR] Cleanup started";

// Stop detection loop
missionNamespace setVariable ["SAR_detection_active", false];

// Delete NPC
private _victim = missionNamespace getVariable ["SAR_victim", objNull];
if (!isNull _victim) then {
    deleteVehicle _victim;
    diag_log "[FTD][SAR] Victim NPC deleted";
};

// Delete markers
deleteMarker "SAR_SearchArea";
deleteMarker "SAR_SearchBorder";
deleteMarker "SAR_InstructorMark";

// Cancel any active task
["SAR_delete"] remoteExec ["FTD_fnc_SAR_taskManager", 2];

// Reset state
missionNamespace setVariable ["SAR_active",       false,  true];
missionNamespace setVariable ["SAR_victim",        objNull, false];
missionNamespace setVariable ["SAR_victimPos",    [],     true];
missionNamespace setVariable ["SAR_locationName", "",     true];

diag_log "[FTD][SAR] Cleanup complete";
