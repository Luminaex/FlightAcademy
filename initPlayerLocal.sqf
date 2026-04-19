// Initialise locations (populates FI_locations global)
diag_log format ["[FTD][initPlayerLocal] Starting for %1 (%2)", name player, getPlayerUID player];
call FTD_fnc_locations;

// Elevator action (added once per client session)
if (isNil "FTD_elevatorAction_added") then {
    FTD_elevatorAction_added = true;
    elevatorFloor addAction ["Go to Roof", {
        [] spawn {
            [{
                player setPosATL (getPosATL roofSpawn);
                player setDir 268;
            }] call FTD_fnc_fadeElevator;
        };
    }];
};

// Local settings
player enableStamina false;
player setVariable["Saved_Loadout",getUnitLoadout player];
player setVariable ["BIS_fnc_camera_allowThirdPerson", true, false];
setTerrainGrid 50; 

// Respawn handler
player addEventHandler ["Respawn", {
    params ["_unit", "_corpse"];
    _unit setPosATL (getPosATL roofSpawn);
    _unit enableStamina false;
    _unit setUnitTrait ["weaponSway", false];
}];

// Determine role and register keybinds once instructor slots are known.
// Named slots (FlightInstructor_0 etc.) are only non-null when a real player occupies them,
// so we wait in a thread — this must NOT block the main script for Noctors.
[] spawn {
    private _timeout = diag_tickTime + 10;
    waitUntil {
        sleep 0.5;
        (["FlightInstructor_0","FlightInstructor_1","FlightInstructor_2","FlightInstructor_3"] findIf {
            !isNull (missionNamespace getVariable [_x, objNull])
        }) != -1
        || diag_tickTime > _timeout
    };
    diag_log format ["[FTD][initPlayerLocal] Instructor slots populated for %1", name player];

    private _allowedUnits = [
        missionNamespace getVariable ["FlightInstructor_0", objNull],
        missionNamespace getVariable ["FlightInstructor_1", objNull],
        missionNamespace getVariable ["FlightInstructor_2", objNull],
        missionNamespace getVariable ["FlightInstructor_3", objNull]
    ];

    diag_log format ["[FTD][initPlayerLocal] Role check — player in instructors: %1", player in _allowedUnits];

    if (player in _allowedUnits) then {

        // Assign Zeus on initial join
        [player] remoteExec ["FTD_fnc_reassignZeus", 2];

        // ── Instructor map binds ──────────────────────────────────────────────
        addMissionEventHandler ["Map", {
            params ["_mapIsOpened"];
            if (!_mapIsOpened) exitWith {};

            private _mapDisplay = findDisplay 12;
            if (isNull _mapDisplay) exitWith {};
            private _mapCtrl = _mapDisplay displayCtrl 51;

            if (
                !(uiNamespace getVariable ["FI_overlayOpening", false]) &&
                (count (uiNamespace getVariable ["FI_overlayCtrls", []])) == 0
            ) then {
                call FTD_fnc_openInstructorUI;
            };

            if !(isNil { uiNamespace getVariable ["FI_speedPickPos", nil] }) then {
                // time trial pick mode — no extra binds needed
            } else {

                // Shift+click — time trial
                _mapCtrl ctrlAddEventHandler ["MouseButtonUp", {
                    params ["_ctrl", "_button", "_x", "_y", "_shift"];
                    if (_button != 0 || !_shift) exitWith {};
                    private _worldPos = _ctrl ctrlMapScreenToWorld [_x, _y];
                    private _pos = [_worldPos select 0, _worldPos select 1, 0];
                    { ctrlDelete _x } forEach (uiNamespace getVariable ["FI_overlayCtrls", []]);
                    uiNamespace setVariable ["FI_overlayCtrls", []];
                    deleteMarker "FI_PreviewMarker";
                    [_pos, localize "STR_FI_Loc_TimeTrial", false] call FTD_fnc_setLandingLocation;
                    missionNamespace setVariable ["FI_speedTimer_start", nil];
                    missionNamespace setVariable ["FI_speedTimer_active", false];
                    [] spawn {
                        waitUntil { sleep 0.2; vehicle player != player };
                        private _heli = vehicle player;
                        waitUntil { sleep 0.1; isEngineOn _heli || !alive _heli || vehicle player == player };
                        if (!alive _heli || vehicle player == player) exitWith {};
                        private _startTime = diag_tickTime;
                        missionNamespace setVariable ["FI_speedTimer_start", _startTime];
                        missionNamespace setVariable ["FI_speedTimer_active", true];
                        private _allowedUnits = [
                            missionNamespace getVariable ["FlightInstructor_0", objNull],
                            missionNamespace getVariable ["FlightInstructor_1", objNull],
                            missionNamespace getVariable ["FlightInstructor_2", objNull],
                            missionNamespace getVariable ["FlightInstructor_3", objNull]
                        ];
                        private _targets = (crew _heli) select { _x in _allowedUnits };
                        [_startTime] remoteExec ["FTD_fnc_speedTimerHUD", _targets];
                        waitUntil { sleep 0.5;
                            !(missionNamespace getVariable ["FI_speedTimer_active", false]) ||
                            !(missionNamespace getVariable ["landingDetection_active", false]) ||
                            !alive _heli
                        };
                        missionNamespace setVariable ["FI_speedTimer_active", false];
                    };
                }];

                _mapCtrl ctrlAddEventHandler ["MouseMoving", {
                    params ["_ctrl", "_x", "_y"];
                    uiNamespace setVariable ["FI_mapMousePos", [_x, _y, _ctrl]];
                }];

                _mapDisplay displayAddEventHandler ["KeyDown", {
                    params ["_display", "_key"];
                    if (_key != 33) exitWith { false }; // 33 = F
                    if !(isNil { uiNamespace getVariable ["FI_speedPickPos", nil] }) exitWith { false };
                    private _mouseData = uiNamespace getVariable ["FI_mapMousePos", []];
                    if (count _mouseData < 3) exitWith { false };
                    private _ctrl  = _mouseData select 2;
                    private _mx    = _mouseData select 0;
                    private _my    = _mouseData select 1;
                    private _worldPos = _ctrl ctrlMapScreenToWorld [_mx, _my];
                    private _targetPos = [_worldPos select 0, _worldPos select 1, 0];
                    [_targetPos] call FTD_fnc_openTpPlayerSelect;
                    true
                }];
            };
        }];

        // User10 opens instructor panel
        [] spawn {
            while { true } do {
                if (inputAction "User10" > 0) then {
                    call FTD_fnc_openInstructorUI;
                    sleep 1;
                };
                sleep 0.1;
            };
        };

        // Windows key opens instructor panel
        missionNamespace setVariable ["winKeyReady", true];
        (findDisplay 46) displayAddEventHandler ["KeyDown", {
            params ["_display", "_key", "_shift", "_ctrl", "_alt"];
            if (_key in [219, 220] && missionNamespace getVariable ["winKeyReady", true]) then {
                missionNamespace setVariable ["winKeyReady", false];
                call FTD_fnc_openInstructorUI;
                [] spawn { sleep 1; missionNamespace setVariable ["winKeyReady", true]; };
            };
        }];

    } else {

        // ── Noctor earplug keybinds ───────────────────────────────────────────
        [] spawn {
            private _ready = true;
            while { true } do {
                if (_ready && inputAction "User10" > 0) then {
                    _ready = false;
                    call FTD_fnc_openEarplugUI;
                    sleep 1;
                    _ready = true;
                };
                sleep 0.1;
            };
        };

        // Windows key opens earplug settings
        missionNamespace setVariable ["winKeyReady", true];
        (findDisplay 46) displayAddEventHandler ["KeyDown", {
            params ["_display", "_key", "_shift", "_ctrl", "_alt"];
            if (_key in [219, 220] && missionNamespace getVariable ["winKeyReady", true]) then {
                missionNamespace setVariable ["winKeyReady", false];
                call FTD_fnc_openEarplugUI;
                [] spawn { sleep 1; missionNamespace setVariable ["winKeyReady", true]; };
            };
        }];
    };
};
