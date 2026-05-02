// FTD_fnc_dbProxy.sqf
// Thin server-side relay so client scripts can trigger DB calls via remoteExec
// without needing direct extDB3 access on the client.
//
// Usage (from any machine):
//   [action, args] remoteExec ["FTD_fnc_dbProxy", 2];
//
// This just passes the call straight through to FTD_fnc_db — the separation
// keeps FTD_fnc_db server-only while still being safely callable remotely.

if (!isServer) exitWith {};
params [["_action", "", [""]], ["_args", [], [[]]]];
[_action, _args] call FTD_fnc_db;
