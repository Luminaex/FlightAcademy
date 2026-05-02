// FTD_fnc_landingDetection.sqf
// Monitors the helicopter and triggers task success on landing
[] spawn {
    private _targetPos    = missionNamespace getVariable ["landingPos",  [0,0,0]];
    private _locationName = missionNamespace getVariable ["landingName", "Location"];
    private _myId         = missionNamespace getVariable ["landingDetection_id", 0];
    private _landed       = false;
    diag_log format ["[FTD][landingDetection] Loop %1 started — target: '%2' pos=%3", _myId, _locationName, _targetPos];

    while {missionNamespace getVariable ["landingDetection_active", false] &&
           (missionNamespace getVariable ["landingDetection_id", 0] == _myId)} do {
        sleep 0.5;

        private _heli = vehicle player;

        // If heli is gone exit cleanly
        if (isNull _heli || !alive _heli) then {
            diag_log format ["[FTD][landingDetection] Loop %1 — heli lost (null or dead), aborting", _myId];
            missionNamespace setVariable ["landingDetection_active", false];
        } else {
            private _isElevated = missionNamespace getVariable ["landingIsRooftop", false];
            private _altCheck = if (_isElevated) then {
                ((getPosATL _heli select 2) < 20) && ((getPosATL _heli select 2) > 3)
            } else {
                (getPosATL _heli select 2) < 1.5
            };

            if ((_heli distance2D _targetPos < 100)
                && (vectorMagnitude velocity _heli < 0.5)
                && _altCheck
                && (abs ((velocity _heli) select 2) < 0.1)) then {
                diag_log format ["[FTD][landingDetection] Loop %1 — LANDED at '%2', dist=%3m, alt=%4m", _myId, _locationName, round (_heli distance2D _targetPos), round (getPosATL _heli select 2)];
                _landed = true;
                missionNamespace setVariable ["landingDetection_active", false];
            };
        };
    };

    diag_log format ["[FTD][landingDetection] Loop %1 exited — landed=%2", _myId, _landed];
    if !_landed exitWith {};

    // ── Task succeeded ────────────────────────────────────────────────────────
    private _heli = vehicle player;
    missionNamespace setVariable ["FlightTask_active", objNull, false];
    missionNamespace setVariable ["FI_speedTimer_active", false];
    if (isPlayer player && { count (crew _heli) > 0 } && { player == (crew _heli select 0) }) then {
        private _uid       = getPlayerUID player;
        private _startTime = missionNamespace getVariable ["FI_speedTimer_start", nil];
        if (!isNil "_startTime") then {
            private _elapsed = diag_tickTime - _startTime;
            private _mins = floor (_elapsed / 60);
            private _secs = _elapsed - (_mins * 60);
            [format [localize "STR_FI_Notify_LandedTitle", _locationName], format [localize "STR_FI_Notify_LandedMsgTimer", _mins, [round _secs, 2] call BIS_fnc_numberText, round (_heli distance2D _targetPos)], "landing_success", _targetPos] call FTD_fnc_notify;
            missionNamespace setVariable ["FI_speedTimer_start", nil];
            // Log time trial result — only update if it's a personal best
            ["time_trial_update", [_uid, _elapsed]] remoteExec ["FTD_fnc_dbProxy", 2];
        } else {
            [format [localize "STR_FI_Notify_LandedTitle", _locationName], format [localize "STR_FI_Notify_LandedMsgDist", round (_heli distance2D _targetPos)], "landing_success", _targetPos] call FTD_fnc_notify;
        };
        // Increment landing counter server-side
        ["player_stat_inc", [_uid, "landings_completed"]] remoteExec ["FTD_fnc_dbProxy", 2];
    };
    ["succeed"] remoteExec ["FTD_fnc_taskManager", 2];
    deleteMarker "LandingMarker";
};
