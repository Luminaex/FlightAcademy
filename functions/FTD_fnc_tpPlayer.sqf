// FTD_fnc_tpPlayer.sqf
// Executed on the target player's machine via remoteExec.
// params: [_pos]

params ["_pos"];

private _heli = vehicle player;
private _inVehicle = (_heli != player);

diag_log format ["[FTD][tpPlayer] Teleporting %1 to %2 (inVehicle=%3, vehicle=%4)", name player, _pos, _inVehicle, typeOf _heli];

player setPosATL [_pos select 0, _pos select 1, 0];
if (_inVehicle) then { _heli setPosATL [_pos select 0, _pos select 1, 0]; };

["TELEPORTED", format ["Moved to %1 by instructor", mapGridPosition _pos], "info"] call FTD_fnc_notify;
