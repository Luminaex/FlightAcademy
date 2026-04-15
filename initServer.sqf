// Initialise locations (populates FI_locations global)
diag_log "[FTD][initServer] Starting server init";
private _t0 = diag_tickTime;
call FTD_fnc_locations;
diag_log format ["[FTD][initServer] Locations loaded: %1 entries", count FI_locations];

// Broadcast instructor slot variables to all clients
{
    missionNamespace setVariable [_x, missionNamespace getVariable [_x, objNull], true];
} forEach ["FlightInstructor_0", "FlightInstructor_1", "FlightInstructor_2", "FlightInstructor_3"];

// Lock time to midday
setDate [date select 0, date select 1, date select 2, 12, 0];
setTimeMultiplier 0;

// Auto-clear task when the last player leaves so joining players don't see stale tasks
addMissionEventHandler ["PlayerDisconnected", {
    [] spawn {
        sleep 5;
        if (count allPlayers == 0) then {
            ["delete"] call FTD_fnc_taskManager;
        };
    };
}];

// Make all mission objects indestructible
{ _x allowDamage false; } forEach (allMissionObjects "All");
diag_log "[FTD][initServer] All mission objects set indestructible";

// Respawn terrain objects (trees, walls, rocks etc.) when destroyed
// allowDamage doesn't work on terrain objects so we recreate them instead
{
    private _obj = _x;
    private _class = typeOf _obj;
    private _pos = getPosASL _obj;
    private _dir = getDir _obj;
    private _vectorUp = vectorUp _obj;

    if !(_obj isKindOf "Man") then {
        _obj addEventHandler ["HandleDamage", { 0 }];
        _obj addEventHandler ["Killed", {
            params ["_killed"];
            private _class = _killed getVariable ["FI_terrainClass", ""];
            private _pos   = _killed getVariable ["FI_terrainPos",  []];
            private _dir   = _killed getVariable ["FI_terrainDir",  0];
            private _up    = _killed getVariable ["FI_terrainUp",   [0,0,1]];
            if (_class == "" || count _pos == 0) exitWith {};

            private _new = createSimpleObject [_class, _pos];
            _new setDir _dir;
            _new setVectorUp _up;
            _new setPosASL _pos;
        }];
    };

    _obj setVariable ["FI_terrainClass", _class];
    _obj setVariable ["FI_terrainPos",   _pos];
    _obj setVariable ["FI_terrainDir",   _dir];
    _obj setVariable ["FI_terrainUp",    _vectorUp];
} forEach (nearestObjects [[0,0,0], [], 100000]);
diag_log "[FTD][initServer] Terrain object respawn handlers registered";

diag_log format ["[FTD][initServer] Server init complete in %1s", round ((diag_tickTime - _t0) * 100) / 100];
