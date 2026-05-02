// FTD_fnc_db.sqf
// Central extDB3 wrapper using SteezCram extDB3 async protocol.
//
// Usage:  [<action>, <params>] call FTD_fnc_db;
//
// Actions (all server-side only):
//   ["init"]                                    — connect extDB3 to the database
//   ["whitelist_check",  [steam64]]             — returns [whitelisted, role]
//   ["player_load",      [steam64]]             — returns player row as array, or []
//   ["player_upsert",    [steam64, name]]        — insert or update name + times_joined + last_seen
//   ["player_stat_inc",  [steam64, column]]      — increment a counter column by 1
//   ["player_time_add",  [steam64, seconds]]     — add to time_played
//   ["time_trial_update",[steam64, time_secs]]   — update fastest_time_trial if new time is better
//   ["session_open",     [steam64]]             — insert a session row, returns session id
//   ["session_close",    [session_id, seconds]] — set left_at and duration

if (!isServer) exitWith {};

params [["_action", "", [""]], ["_args", [], [[]]]];

// Escape single quotes — native SQF, no BIS function dependency
FTD_fnc_dbEscape = {
    params ["_s"];
    private _out = "";
    {
        if (_x == 39) then { _out = _out + "''" } else { _out = _out + (toString [_x]) };
    } forEach (toArray _s);
    _out
};

// Send an async SQL query and block-poll until result is ready, then return parsed data.
// Mode 1 = fire-and-forget (INSERT/UPDATE), mode 2 = returns rows (SELECT)
FTD_fnc_dbQuery = {
    params ["_sql", ["_mode", 1, [0]]];

    // Send query — returns [2,"<id>"] for async queries
    private _keyRaw = "extDB3" callExtension format ["%1:sql:%2", _mode, _sql];

    // Fire-and-forget — no result needed
    if (_mode == 1) exitWith { [] };

    // Parse the query ID from [2,"<id>"]
    private _keyParsed = call compile _keyRaw;
    if (isNil "_keyParsed" || { !(_keyParsed isEqualType []) } || { count _keyParsed < 2 }) exitWith {
        diag_log format ["[FTD][DB] Bad query key: %1 | SQL: %2", _keyRaw, _sql];
        []
    };
    private _queryId = _keyParsed select 1;

    // Poll for result using protocol 4 with the numeric ID
    private _result = "";
    private _timeout = diag_tickTime + 10;
    while { true } do {
        _result = "extDB3" callExtension format ["4:%1", _queryId];
        if (_result == "[3]") then {
            // Still processing
            if (diag_tickTime > _timeout) exitWith {
                diag_log format ["[FTD][DB] Query timeout | SQL: %1", _sql];
                _result = "";
            };
            uiSleep 0.05;
        } else {
            break;
        };
    };


    if (_result == "" || _result == "[]") exitWith {
        diag_log format ["[FTD][DB] Empty result | SQL: %1", _sql];
        []
    };

    // extDB3 returns unquoted strings e.g. [1,[[instructor]]]
    // Parse char-by-char and quote bare alpha tokens so SQF can compile the result
    private _quoted = "";
    private _inStr = false;
    private _token = "";
    {
        private _c = toString [_x];
        if (_inStr) then {
            _quoted = _quoted + _c;
            if (_x == 34) then { _inStr = false }; // 34 = "
        } else {
            if (_x == 34) then {
                _inStr = true;
                _quoted = _quoted + _c;
            } else {
                if ((_x >= 65 && _x <= 90) || (_x >= 97 && _x <= 122) || _x == 95) then {
                    _token = _token + _c;
                } else {
                    if (_token != "") then {
                        _quoted = _quoted + format ['"%1"', _token];
                        _token = "";
                    };
                    _quoted = _quoted + _c;
                };
            };
        };
    } forEach (toArray _result);
    if (_token != "") then { _quoted = _quoted + format ['"%1"', _token]; };
    private _parsed = call compile _quoted;

    if (isNil "_parsed" || { !(_parsed isEqualType []) } || { count _parsed < 2 }) exitWith {
        diag_log format ["[FTD][DB] Parse error: %1 | SQL: %2", _result, _sql];
        []
    };

    private _status = _parsed select 0;
    private _data   = _parsed select 1;

    if (_status != 1) exitWith {
        diag_log format ["[FTD][DB] Query error: %1 | SQL: %2", _data, _sql];
        []
    };

    _data
};

switch (_action) do {

    // ── Initialise extDB3 connection ──────────────────────────────────────────
    case "init": {
        private _r1 = "extDB3" callExtension "9:ADD_DATABASE:flightacademy";
        diag_log format ["[FTD][DB] ADD_DATABASE: %1", _r1];
        private _r2 = "extDB3" callExtension "9:ADD_DATABASE_PROTOCOL:flightacademy:sql:sql";
        diag_log format ["[FTD][DB] ADD_PROTOCOL: %1", _r2];
    };

    // ── Whitelist check ───────────────────────────────────────────────────────
    case "whitelist_check": {
        _args params [["_steam64", "", [""]]];
        private _esc = [_steam64] call FTD_fnc_dbEscape;
        private _sql = format ["SELECT `role` FROM `whitelist` WHERE `steam64`='%1' LIMIT 1", _esc];
        private _rows = [_sql, 2] call FTD_fnc_dbQuery;
        if (count _rows == 0) exitWith { [false, ""] };
        private _row = _rows select 0;
        if (count _row == 0) exitWith { [false, ""] };
        [true, (_row select 0)]
    };

    // ── Load player row ───────────────────────────────────────────────────────
    case "player_load": {
        _args params [["_steam64", "", [""]]];
        private _esc = [_steam64] call FTD_fnc_dbEscape;
        private _sql = format [
            "SELECT `name`,`times_joined`,`time_played`,`landings_completed`,`crashes`,`fastest_time_trial` FROM `players` WHERE `steam64`='%1' LIMIT 1",
            _esc
        ];
        private _rows = [_sql, 2] call FTD_fnc_dbQuery;
        if (count _rows == 0) exitWith { [] };
        _rows select 0
    };

    // ── Upsert player ─────────────────────────────────────────────────────────
    case "player_upsert": {
        _args params [["_steam64", "", [""]], ["_name", "", [""]]];
        private _escSteam = [_steam64] call FTD_fnc_dbEscape;
        private _escName  = [_name]    call FTD_fnc_dbEscape;
        private _sql = format [
            "INSERT INTO `players` (`steam64`,`name`,`times_joined`,`last_seen`) VALUES ('%1','%2',1,NOW()) ON DUPLICATE KEY UPDATE `name`='%2', `times_joined`=`times_joined`+1, `last_seen`=NOW()",
            _escSteam, _escName
        ];
        [_sql, 1] call FTD_fnc_dbQuery;
    };

    // ── Increment a counter column ────────────────────────────────────────────
    case "player_stat_inc": {
        _args params [["_steam64", "", [""]], ["_col", "", [""]]];
        if !(_col in ["landings_completed","crashes"]) exitWith {
            diag_log format ["[FTD][DB] player_stat_inc: unknown column '%1'", _col];
        };
        private _esc = [_steam64] call FTD_fnc_dbEscape;
        private _sql = format ["UPDATE `players` SET `%1`=`%1`+1 WHERE `steam64`='%2'", _col, _esc];
        [_sql, 1] call FTD_fnc_dbQuery;
    };

    // ── Add seconds to time_played ────────────────────────────────────────────
    case "player_time_add": {
        _args params [["_steam64", "", [""]], ["_secs", 0, [0]]];
        private _esc = [_steam64] call FTD_fnc_dbEscape;
        private _sql = format ["UPDATE `players` SET `time_played`=`time_played`+%1 WHERE `steam64`='%2'", floor _secs, _esc];
        [_sql, 1] call FTD_fnc_dbQuery;
    };

    // ── Update fastest time trial (only if better) ────────────────────────────
    case "time_trial_update": {
        _args params [["_steam64", "", [""]], ["_time", 0, [0]]];
        private _esc = [_steam64] call FTD_fnc_dbEscape;
        private _sql = format [
            "UPDATE `players` SET `fastest_time_trial`=%1 WHERE `steam64`='%2' AND (`fastest_time_trial` IS NULL OR `fastest_time_trial`>%1)",
            _time, _esc
        ];
        [_sql, 1] call FTD_fnc_dbQuery;
    };

    // ── Open a session row, return the new session id ─────────────────────────
    case "session_open": {
        _args params [["_steam64", "", [""]]];
        private _esc = [_steam64] call FTD_fnc_dbEscape;
        private _sql = format ["INSERT INTO `sessions` (`steam64`,`joined_at`) VALUES ('%1',NOW())", _esc];
        [_sql, 2] call FTD_fnc_dbQuery;
        private _idRows = ["SELECT LAST_INSERT_ID()", 2] call FTD_fnc_dbQuery;
        if (count _idRows == 0) exitWith { -1 };
        private _idval = (_idRows select 0) select 0;
        if (_idval isEqualType 0) exitWith { _idval };
        parseNumber _idval
    };

    // ── Close a session ───────────────────────────────────────────────────────
    case "session_close": {
        _args params [["_sessionId", -1, [0]], ["_secs", 0, [0]]];
        if (_sessionId < 0) exitWith {};
        private _sql = format [
            "UPDATE `sessions` SET `left_at`=NOW(), `duration`=%1 WHERE `id`=%2",
            floor _secs, _sessionId
        ];
        [_sql, 1] call FTD_fnc_dbQuery;
    };

    default {
        diag_log format ["[FTD][DB] Unknown action: '%1'", _action];
    };
};
