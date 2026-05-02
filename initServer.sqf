// Initialise locations (populates FI_locations global)
diag_log "[FTD][initServer] Starting server init";
private _t0 = diag_tickTime;

// Set true to skip DB/whitelist checks — everyone gets instructor, no extDB3 needed
FTD_devMode = true;

// Initialise extDB3 database connection
if (!FTD_devMode) then {
    ["init"] call FTD_fnc_db;
    diag_log "[FTD][initServer] extDB3 initialised";
} else {
    diag_log "[FTD][initServer] DEV MODE — extDB3 skipped";
};

call FTD_fnc_locations;
diag_log format ["[FTD][initServer] Locations loaded: %1 entries", count FI_locations];

// Lock time to midday
setDate [date select 0, date select 1, date select 2, 12, 0];
setTimeMultiplier 0;

// Whitelist + DB session open on connect
addMissionEventHandler ["PlayerConnected", {
    params ["_id", "_uid", "_name", "_jip", "_owner"];
    [_uid, _name, _owner] spawn FTD_fnc_whitelistCheck;
}];

// Session close + time_played on disconnect
addMissionEventHandler ["PlayerDisconnected", {
    params ["_id", "_uid", "_name", "_jip", "_owner"];
    private _joinTime  = missionNamespace getVariable [format ["FI_joinTime_%1",  _uid], -1];
    private _sessionId = missionNamespace getVariable [format ["FI_sessionId_%1", _uid], -1];

    if (_joinTime >= 0) then {
        private _secs = time - _joinTime;
        ["player_time_add",  [_uid, _secs]]       call FTD_fnc_db;
        ["session_close",    [_sessionId, _secs]]  call FTD_fnc_db;
        diag_log format ["[FTD][DB] Session closed for %1 — %2s played", _name, floor _secs];
    };

    // Delete Zeus curator if this player had one
    private _curator = missionNamespace getVariable [format ["FI_curator_%1", _uid], objNull];
    if (!isNull _curator) then {
        deleteVehicle _curator;
        diag_log format ["[FTD][Zeus] Curator deleted for %1 on disconnect", _name];
    };

    // Clean up per-player namespace keys
    missionNamespace setVariable [format ["FI_joinTime_%1",  _uid], nil, false];
    missionNamespace setVariable [format ["FI_sessionId_%1", _uid], nil, false];
    missionNamespace setVariable [format ["FI_playerRole_%1", _uid], nil, false];
    missionNamespace setVariable [format ["FI_curator_%1",   _uid], nil, false];

    // Auto-clear task when the last player leaves so joining players don't see stale tasks
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
