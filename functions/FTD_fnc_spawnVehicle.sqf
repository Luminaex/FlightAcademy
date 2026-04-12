params [["_vehicleClass", "B_Heli_Light_01_F"], ["_spawnPos", []], ["_spawnDir", -1]];

private _t0 = diag_tickTime;
private _uid = getPlayerUID player;
diag_log format ["[FTD][spawnVehicle] %1 requesting %2", _uid, _vehicleClass];

// Delete this instructor's existing vehicle if they have one
private _varName = format ["FI_heli_%1", _uid];
private _existingVehicle = missionNamespace getVariable [_varName, objNull];
if (!isNull _existingVehicle) then {
    diag_log format ["[FTD][spawnVehicle] Deleting existing vehicle for %1: %2", _uid, typeOf _existingVehicle];
    deleteVehicle _existingVehicle;
};

// Spawn position: use provided pos, otherwise fall back to heliSpawn object
private _helipadPos = if (count _spawnPos > 0) then { _spawnPos } else { getPosATL heliSpawn };
private _helipadDir = if (_spawnDir >= 0) then { _spawnDir } else { getDir heliSpawn };

// Check spawn point is clear of other vehicles
private _nearby = nearestObjects [_helipadPos, ["LandVehicle", "Air", "Ship"], 8];
_nearby = _nearby select { alive _x };
if (count _nearby > 0) exitWith {
    diag_log format ["[FTD][spawnVehicle] BLOCKED for %1 — %2 vehicle(s) at spawn: %3", _uid, count _nearby, _nearby apply { typeOf _x }];
    [localize "STR_FI_Notify_SpawnBlockedTitle", localize "STR_FI_Notify_SpawnBlockedMsg", "warning"] call FTD_fnc_notify;
};

private _vehicle = createVehicle [_vehicleClass, _helipadPos, [], 0, "NONE"];
_vehicle setDir _helipadDir;
_vehicle setPosATL _helipadPos;
_vehicle setVariable ["BIS_enableRandomization", false];
_vehicle setVariable ["FI_ownerUID", _uid, true];

switch (typeOf _vehicle) do {
    case "B_Heli_Light_01_F": {
        _vehicle setObjectTextureGlobal [0, "Textures\FSm900.paa"];
    };
    case "O_Heli_Light_02_unarmed_F": {
        _vehicle setObjectTextureGlobal [0, "Textures\FSorca.paa"];
    };
    default {};
};

clearWeaponCargoGlobal _vehicle;
clearMagazineCargoGlobal _vehicle;
clearItemCargoGlobal _vehicle;
clearBackpackCargoGlobal _vehicle;

// Store under this instructor's UID so multiple instructors can have their own heli
missionNamespace setVariable [_varName, _vehicle, true];

private _heliName = switch (_vehicleClass) do {
    case "B_Heli_Light_01_F":     { "M900" };
    case "O_Heli_Light_02_unarmed_F":   { "Orca" };
    default { _vehicleClass };
};
player setVariable ["FI_activeHeliName", _heliName, true];

diag_log format ["[FTD][spawnVehicle] %1 spawned %2 (%3) at %4 in %5s", _uid, _heliName, _vehicleClass, _helipadPos, round ((diag_tickTime - _t0) * 100) / 100];

[_vehicle] remoteExec ["FTD_fnc_enterHeli", player];

_vehicle spawn {
    private _veh = _this;
    while { !isNull _veh && alive _veh } do {
        if (isAutoHoverOn _veh) then {
            _veh forceSpeed -1;
            {
                [localize "STR_FI_Notify_AutoHoverTitle", localize "STR_FI_Notify_AutoHoverMsg", "warning"] call FTD_fnc_notify;
                _veh action ["AutoHoverCancel", _veh];
            } forEach crew _veh;
        };
        sleep 0.5;
    };
};
