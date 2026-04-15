// fn_taskManager.sqf
// params: ["action", ...]
// actions: "create", "delete", "succeed"
if (!isServer) exitWith {};
params ["_action"];
diag_log format ["[FTD][taskManager] Action: %1", _action];

// ── Helper: delete current task cleanly ──────────────────────────────────────
private _fnc_deleteCurrent = {
    private _id = missionNamespace getVariable ["FlightTask_currentTaskId", ""];
    if (_id != "" && { [_id] call BIS_fnc_taskExists }) then {
        [_id] call BIS_fnc_deleteTask;
    };
    missionNamespace setVariable ["FlightTask_currentTaskId", ""];
};

switch _action do {
    case "create": {
        params ["_action", "_units", "_name", "_pos"];

        // Debounce: collapse rapid-fire creates — only act on the latest one
        private _createGen = (missionNamespace getVariable ["FlightTask_createGen", 0]) + 1;
        missionNamespace setVariable ["FlightTask_createGen", _createGen];
        [_createGen, _name, _pos] spawn {
            params ["_myGen", "_name", "_pos"];
            sleep 0.1;
            if ((missionNamespace getVariable ["FlightTask_createGen", 0]) != _myGen) exitWith {
                diag_log format ["[FTD][taskManager] Create gen %1 superseded — skipping", _myGen];
            };

            // Cancel any pending delayed deletion from a previous succeed
            missionNamespace setVariable ["FlightTask_deleteId", (missionNamespace getVariable ["FlightTask_deleteId", 0]) + 1];

            // Delete previous task (inline: _fnc_deleteCurrent is not accessible inside spawn)
            private _prevId = missionNamespace getVariable ["FlightTask_currentTaskId", ""];
            if (_prevId != "" && { [_prevId] call BIS_fnc_taskExists }) then {
                [_prevId] call BIS_fnc_deleteTask;
            };
            missionNamespace setVariable ["FlightTask_currentTaskId", ""];

            // Generate a unique task ID
            private _counter = (missionNamespace getVariable ["FlightTask_counter", 0]) + 1;
            missionNamespace setVariable ["FlightTask_counter", _counter];
            private _taskId = format ["FlightTask_%1", _counter];
            missionNamespace setVariable ["FlightTask_currentTaskId", _taskId];
            diag_log format ["[FTD][taskManager] Creating task '%1' for '%2'", _taskId, _name];

            // false = not JIP-persistent, so players joining later won't receive it
            [
                allPlayers,
                _taskId,
                [format [localize "STR_FI_Task_Title", _name], localize "STR_FI_Task_Type", localize "STR_FI_Task_Desc"],
                _pos,
                "ASSIGNED",
                1,
                false
            ] call BIS_fnc_taskCreate;
        };
    };
    case "succeed": {
        private _taskId = missionNamespace getVariable ["FlightTask_currentTaskId", ""];
        if (_taskId != "" && { [_taskId] call BIS_fnc_taskExists }) then {
            diag_log format ["[FTD][taskManager] Task '%1' succeeded", _taskId];
            [_taskId, "SUCCEEDED"] call BIS_fnc_taskSetState;
        } else {
            diag_log format ["[FTD][taskManager] succeed called but no active task (id='%1')", _taskId];
        };
        private _deleteId = (missionNamespace getVariable ["FlightTask_deleteId", 0]) + 1;
        missionNamespace setVariable ["FlightTask_deleteId", _deleteId];
        [_deleteId, _taskId] spawn {
            params ["_myId", "_tid"];
            sleep 2;
            if ((missionNamespace getVariable ["FlightTask_deleteId", 0]) == _myId) then {
                if (_tid != "" && { [_tid] call BIS_fnc_taskExists }) then {
                    [_tid] call BIS_fnc_deleteTask;
                };
                missionNamespace setVariable ["FlightTask_currentTaskId", ""];
            };
        };
    };
    case "delete": {
        // Cancel any pending succeed-deletion
        missionNamespace setVariable ["FlightTask_deleteId", (missionNamespace getVariable ["FlightTask_deleteId", 0]) + 1];
        call _fnc_deleteCurrent;
    };
};
