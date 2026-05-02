// FTD_fnc_whitelistCheck.sqf
// Called server-side on PlayerConnected. Checks the whitelist table for the
// connecting player's Steam64 ID. If found, sets their role to "instructor"
// so initPlayerLocal grants them the panel. Everyone else joins as "student".
// Nobody is kicked — the whitelist only controls panel access.
//
// Params: [uid, name, clientId]

if (!isServer) exitWith {};

params [
    ["_uid",      "", [""]],
    ["_name",     "", [""]],
    ["_clientId", 0,  [0]]
];

diag_log format ["[FTD][Whitelist] Checking %1 (%2)", _name, _uid];

// Dev bypass — set FTD_devMode = true in initServer.sqf to skip DB and give everyone instructor
if (missionNamespace getVariable ["FTD_devMode", false]) exitWith {
    diag_log format ["[FTD][Whitelist] DEV MODE — assigning instructor to %1", _name];
    missionNamespace setVariable [format ["FI_playerRole_%1", _uid], "instructor", true];
    missionNamespace setVariable [format ["FI_joinTime_%1",  _uid], time, false];
    missionNamespace setVariable [format ["FI_sessionId_%1", _uid], -1,   false];
};

private _result = ["whitelist_check", [_uid]] call FTD_fnc_db;

private _role = "student";
if (count _result == 2 && { (_result select 0) isEqualTo true }) then {
    private _dbrole = _result select 1;
    if (_dbrole in ["instructor","student"]) then { _role = _dbrole; };
    diag_log format ["[FTD][Whitelist] %1 (%2) — role: %3", _name, _uid, _role];
} else {
    diag_log format ["[FTD][Whitelist] %1 (%2) — not in whitelist, joining as student", _name, _uid];
};

// Broadcast role to all clients so initPlayerLocal can read it
missionNamespace setVariable [format ["FI_playerRole_%1", _uid], _role, true];

// Track stats for everyone
["player_upsert", [_uid, _name]] call FTD_fnc_db;
private _sessionId = ["session_open", [_uid]] call FTD_fnc_db;
missionNamespace setVariable [format ["FI_sessionId_%1", _uid], _sessionId, false];
missionNamespace setVariable [format ["FI_joinTime_%1",  _uid], time,       false];

diag_log format ["[FTD][Whitelist] Session %1 opened for %2", _sessionId, _name];
