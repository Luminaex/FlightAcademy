// FTD_fnc_quickStart.sqf
// Spawn Orca, set landing location, start engine timer.
// Params: [pos, name] — defaults to Agios Hospital if not provided.

params [
    ["_pos",  [9719.65, 15880.2, 0], [[]]],
    ["_name", localize "STR_FI_QuickStart_DefaultName", [""]]
];

diag_log format ["[FTD][quickStart] Started by %1 — target: '%2'", name player, _name];

// Close overlay and map, clean up preview marker
deleteMarker "FI_PreviewMarker";
private _oc = uiNamespace getVariable ["FI_overlayCtrls", []];
{ if (!isNull _x) then { ctrlDelete _x; }; } forEach _oc;
uiNamespace setVariable ["FI_overlayCtrls", []];

// Spawn Orca
["O_Heli_Light_02_unarmed_F"] spawn FTD_fnc_spawnVehicle;

// Set landing location
[_pos, _name, false] call FTD_fnc_setLandingLocation;

// Clear any previous timer
missionNamespace setVariable ["FI_speedTimer_start", nil];
missionNamespace setVariable ["FI_speedTimer_active", false];

// Engine monitor + HUD timer (local to instructor only)
[] spawn {
    // Wait until player is in a vehicle
    waitUntil { sleep 0.2; vehicle player != player };
    private _heli = vehicle player;
    diag_log format ["[FTD][quickStart] Player entered vehicle: %1", typeOf _heli];

    // Wait for engine start
    waitUntil { sleep 0.1; isEngineOn _heli || !alive _heli || vehicle player == player };
    if (!alive _heli || vehicle player == player) exitWith {
        diag_log format ["[FTD][quickStart] Aborted — heli lost or player exited before engine start (alive=%1)", alive _heli];
    };

    // Record start time
    private _startTime = diag_tickTime;
    missionNamespace setVariable ["FI_speedTimer_start", _startTime];
    missionNamespace setVariable ["FI_speedTimer_active", true];
    diag_log format ["[FTD][quickStart] Engine started — timer running for %1", typeOf _heli];

    // Show HUD on all instructors currently in this heli
    private _allowedUnits = [
        missionNamespace getVariable ["FlightInstructor_0", objNull],
        missionNamespace getVariable ["FlightInstructor_1", objNull],
        missionNamespace getVariable ["FlightInstructor_2", objNull],
        missionNamespace getVariable ["FlightInstructor_3", objNull]
    ];
    private _targets = (crew _heli) select { _x in _allowedUnits };
    [_startTime] remoteExec ["FTD_fnc_speedTimerHUD", _targets];

    // Wait for timer to end on this machine
    waitUntil { sleep 0.5;
        !(missionNamespace getVariable ["FI_speedTimer_active", false]) ||
        !(missionNamespace getVariable ["landingDetection_active", false]) ||
        !alive _heli
    };
    missionNamespace setVariable ["FI_speedTimer_active", false];
};
