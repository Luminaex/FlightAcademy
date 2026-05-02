// FTD_fnc_reassignZeus.sqf
// Creates a Zeus curator module for the given instructor unit.
// Params: [_unit]

if (!isServer) exitWith {};

params ["_unit"];

// Prevent concurrent calls for the same player
private _uid = getPlayerUID _unit;
if (missionNamespace getVariable [format ["FI_zeusCreating_%1", _uid], false]) exitWith {
    diag_log format ["[FTD][Zeus] reassignZeus already running for %1, skipping duplicate", _uid];
};
missionNamespace setVariable [format ["FI_zeusCreating_%1", _uid], true, false];

// Wait for the unit to be fully ready as a player
private _timeout = diag_tickTime + 10;
waitUntil {
    sleep 0.5;
    (isPlayer _unit && !isNull _unit) || diag_tickTime > _timeout
};

if (isNull _unit || !isPlayer _unit) exitWith {
    diag_log "[FTD][Zeus] reassignZeus — unit not ready, skipping";
};

private _varName = format ["FI_curator_%1", _uid];

// Delete existing curator for this player if one exists
private _existing = missionNamespace getVariable [_varName, objNull];
if (!isNull _existing) then {
    diag_log format ["[FTD][Zeus] Deleting old curator for %1", name _unit];
    deleteVehicle _existing;
    missionNamespace setVariable [_varName, objNull, false];
};

// Create curator module in a logic group
private _grp = createGroup [sideLogic, true];
private _curator = _grp createUnit ["ModuleCurator_F", [0,0,0], [], 0, "NONE"];

_curator setVariable ["Owner", _unit, true];
_curator setVariable ["Addons", 2, true];
_curator setVariable ["Costs", 0, true];

missionNamespace setVariable [_varName, _curator, false];
missionNamespace setVariable [format ["FI_zeusCreating_%1", _uid], false, false];

// Assign curator to player on their machine so Zeus key works
[[_curator], { player assignCurator (_this select 0); }] remoteExec ["call", _unit];

diag_log format ["[FTD][Zeus] Curator created for %1 (%2) — curator: %3", name _unit, _uid, _curator];
