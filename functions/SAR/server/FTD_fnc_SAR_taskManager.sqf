// FTD_fnc_SAR_taskManager.sqf
// Server-side task lifecycle for SAR missions.
// Actions: "SAR_create", "SAR_pickup", "SAR_succeed", "SAR_delete"

if (!isServer) exitWith {};
params ["_action"];
diag_log format ["[FTD][SAR][taskManager] Action: %1", _action];

private _fnc_deleteCurrent = {
    private _id = missionNamespace getVariable ["SAR_currentTaskId", ""];
    if (_id != "" && { [_id] call BIS_fnc_taskExists }) then {
        [_id] call BIS_fnc_deleteTask;
    };
    missionNamespace setVariable ["SAR_currentTaskId", ""];
};

private _fnc_newId = {
    private _counter = (missionNamespace getVariable ["SAR_task_counter", 0]) + 1;
    missionNamespace setVariable ["SAR_task_counter", _counter];
    format ["SARTask_%1", _counter]
};

switch _action do {
    case "SAR_create": {
        params ["_action", "_units", "_pos"];

        call _fnc_deleteCurrent;

        private _taskId = call _fnc_newId;
        missionNamespace setVariable ["SAR_currentTaskId", _taskId];
        diag_log format ["[FTD][SAR][taskManager] Creating search task '%1'", _taskId];

        [
            allPlayers,
            _taskId,
            [
                "SAR — Search Area",
                "SAR",
                "Locate the lost person in the search zone. Land nearby, drag them into your aircraft, then fly them to the hospital."
            ],
            _pos,
            "ASSIGNED",
            1,
            false
        ] call BIS_fnc_taskCreate;
    };
    case "SAR_pickup": {
        // Person is now in a vehicle — update task destination to the hospital
        params ["_action", "_hospPos"];

        call _fnc_deleteCurrent;

        private _taskId = call _fnc_newId;
        missionNamespace setVariable ["SAR_currentTaskId", _taskId];
        diag_log format ["[FTD][SAR][taskManager] Creating transport task '%1'", _taskId];

        [
            allPlayers,
            _taskId,
            [
                "SAR — Fly to Hospital",
                "SAR",
                "Person is aboard. Fly to the hospital and land to complete the rescue."
            ],
            _hospPos,
            "ASSIGNED",
            1,
            false
        ] call BIS_fnc_taskCreate;
    };
    case "SAR_succeed": {
        private _taskId = missionNamespace getVariable ["SAR_currentTaskId", ""];
        if (_taskId != "" && { [_taskId] call BIS_fnc_taskExists }) then {
            diag_log format ["[FTD][SAR][taskManager] Task '%1' succeeded", _taskId];
            [_taskId, "SUCCEEDED"] call BIS_fnc_taskSetState;
        };

        [_taskId] spawn {
            params ["_tid"];
            sleep 5;
            if (_tid != "" && { [_tid] call BIS_fnc_taskExists }) then {
                [_tid] call BIS_fnc_deleteTask;
            };
            missionNamespace setVariable ["SAR_currentTaskId", ""];
        };
    };
    case "SAR_delete": {
        call _fnc_deleteCurrent;
    };
};
