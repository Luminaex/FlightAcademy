// FTD_fnc_SAR_onRescue.sqf
// Called server-side when rescue conditions are met.
// Handles the success state and cleans up after a delay.
// Usage: call FTD_fnc_SAR_onRescue;

if (!isServer) exitWith {};

diag_log "[FTD][SAR] Rescue successful — handling completion";

missionNamespace setVariable ["SAR_active", false, true];

// Log SAR completion for the pilot who initiated it
private _pilotUID = missionNamespace getVariable ["SAR_pilotUID", ""];
if (_pilotUID != "") then {
    ["player_stat_inc", [_pilotUID, "landings_completed"]] call FTD_fnc_db;
    diag_log format ["[FTD][DB] SAR completion logged for UID %1", _pilotUID];
};

// Notify all clients of success
[] remoteExec ["FTD_fnc_SAR_notifySuccess", 0];

// Remove the NPC and clean up after a short delay so clients can see the result
[] spawn {
    sleep 5;
    call FTD_fnc_SAR_cleanup;
    diag_log "[FTD][SAR] Cleanup complete after rescue";
};
