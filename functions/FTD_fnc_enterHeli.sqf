// FTD_fnc_enterHeli.sqf
// Called via remoteExec with the vehicle as parameter
params [["_heli", objNull]];

diag_log format ["[FTD][enterHeli] Called for %1 (%2)", name player, typeOf _heli];

_heli spawn {
    private _veh = _this;
    sleep 1;
    if (isNull _veh) exitWith {
        diag_log "[FTD][enterHeli] Aborted — vehicle is null after sleep";
    };
    if (vehicleVarName player == "Noctor") then {
        diag_log format ["[FTD][enterHeli] Noctor %1 — waiting for driver seat in %2", name player, typeOf _veh];
        waitUntil { sleep 0.1; isNull (driver _veh) || driver _veh == player };
        player assignAsDriver _veh;
        player moveInDriver _veh;
        diag_log format ["[FTD][enterHeli] Noctor %1 moved into driver seat", name player];
    } else {
        player moveInAny _veh;
        diag_log format ["[FTD][enterHeli] Instructor %1 moved into %2", name player, typeOf _veh];
    };
};
