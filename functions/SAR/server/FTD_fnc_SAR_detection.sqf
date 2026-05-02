// FTD_fnc_SAR_detection.sqf
// Server-side polling loop tracking three states:
//   SEARCHING  — person on ground, waiting to be picked up
//   CARRYING   — person attached to a player (being dragged on foot)
//   IN_VEHICLE — person loaded into a player vehicle
// Completes when the carrying vehicle lands within 100m of "Hos_2" and is on the ground.
// Usage: call FTD_fnc_SAR_detection;

if (!isServer) exitWith {};

private _loopId = (missionNamespace getVariable ["SAR_detection_id", 0]) + 1;
missionNamespace setVariable ["SAR_detection_id", _loopId];
missionNamespace setVariable ["SAR_detection_active", true];

diag_log format ["[FTD][SAR] Detection loop started (id=%1)", _loopId];

[_loopId] spawn {
    params ["_myId"];

    private _HOSP_RANGE = 100;
    private _hospPos    = getMarkerPos "Hos_2";
    private _lastState  = "SEARCHING";

    while {
        missionNamespace getVariable ["SAR_detection_active", false]
        && { (missionNamespace getVariable ["SAR_detection_id", 0]) == _myId }
    } do {
        private _victim = missionNamespace getVariable ["SAR_victim", objNull];
        if (isNull _victim) exitWith {
            diag_log "[FTD][SAR] Detection: victim is null — stopping loop";
        };

        private _inVehicle    = vehicle _victim != _victim;
        private _beingCarried = _victim getVariable ["SAR_beingCarried", false];

        private _state = if (_inVehicle) then { "IN_VEHICLE" } else { if (_beingCarried) then { "CARRYING" } else { "SEARCHING" } };

        switch _state do {
            case "IN_VEHICLE": {
                if (_lastState != "IN_VEHICLE") then {
                    _lastState = "IN_VEHICLE";
                    diag_log "[FTD][SAR] State → IN_VEHICLE";
                    [] remoteExec ["FTD_fnc_SAR_notifyBoarded", 0];
                    ["SAR_pickup", _hospPos] remoteExec ["FTD_fnc_SAR_taskManager", 2];
                };

                private _veh  = vehicle _victim;
                private _dist = _veh distance2D _hospPos;
                private _alt  = getPosATL _veh select 2;
                private _spd  = vectorMagnitude velocity _veh;
                private _vspd = abs (velocity _veh select 2);

                // Same guards as landingDetection: within range, on the ground, not moving
                if (_dist < _HOSP_RANGE && { _alt < 1.5 } && { _spd < 0.5 } && { _vspd < 0.1 }) then {
                    diag_log format ["[FTD][SAR] Landed at Hos_2 (dist=%1m alt=%2m spd=%3)", round _dist, round _alt, round _spd];
                    missionNamespace setVariable ["SAR_detection_active", false];
                    ["SAR_succeed"] remoteExec ["FTD_fnc_SAR_taskManager", 2];
                    call FTD_fnc_SAR_onRescue;
                    break;
                };
            };
            case "CARRYING": {
                if (_lastState != "CARRYING") then {
                    _lastState = "CARRYING";
                    diag_log "[FTD][SAR] State → CARRYING";
                };
            };
            default {
                if (_lastState == "IN_VEHICLE") then {
                    diag_log "[FTD][SAR] Person unloaded before reaching hospital — back to SEARCHING";
                    [] remoteExec ["FTD_fnc_SAR_notifyUnloaded", 0];
                    private _victimPos = missionNamespace getVariable ["SAR_victimPos", [0,0,0]];
                    ["SAR_create", allPlayers, _victimPos] remoteExec ["FTD_fnc_SAR_taskManager", 2];
                };
                if (_lastState != "SEARCHING") then {
                    _lastState = "SEARCHING";
                    diag_log "[FTD][SAR] State → SEARCHING";
                };
            };
        };

        sleep 0.5;
    };

    diag_log format ["[FTD][SAR] Detection loop %1 exited", _myId];
};
