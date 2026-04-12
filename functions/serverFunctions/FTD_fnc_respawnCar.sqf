// fn_respawnCar.sqf
if (!isServer) exitWith {};

diag_log "[FTD][respawnCar] Respawning SUV";

// Delete existing SUV
private _existing = vehicles select { typeOf _x == "C_SUV_01_F" };
diag_log format ["[FTD][respawnCar] Deleting %1 existing SUV(s)", count _existing];
{ deleteVehicle _x; } forEach _existing;

// Spawn at original position
private _spawnPos = [3744.96, 12981.1, 18.744];
private _spawnDir = 180;

private _car = "C_SUV_01_F" createVehicle _spawnPos;
_car setDir _spawnDir;
_car setPosATL _spawnPos;
_car setObjectTextureGlobal [0, "Textures\suv.paa"];
_car lock 1;
diag_log format ["[FTD][respawnCar] SUV spawned at %1", _spawnPos];