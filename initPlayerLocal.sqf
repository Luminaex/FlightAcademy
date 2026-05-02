// Initialise locations (populates FI_locations global)
diag_log format ["[FTD][initPlayerLocal] Starting for %1 (%2)", name player, getPlayerUID player];
call FTD_fnc_locations;

// Clear any stale UI state from previous session
uiNamespace setVariable ["FI_overlayCtrls",   []];
uiNamespace setVariable ["FI_overlayOpening", false];
uiNamespace setVariable ["FI_earplugCtrls",   []];
uiNamespace setVariable ["FI_settingsReady",  true];

// Local settings
player enableStamina false;
player setVariable["Saved_Loadout",getUnitLoadout player];
player setVariable ["BIS_fnc_camera_allowThirdPerson", true, false];
setTerrainGrid 50;

// Apply saved settings from previous session
private _savedVol = profileNamespace getVariable ["FTD_setting_volume", 1.0];
private _savedVD  = profileNamespace getVariable ["FTD_setting_viewdist", 3000];
_savedVol fadeSound _savedVol;
missionNamespace setVariable ["FI_earplugVolume", _savedVol];
setViewDistance _savedVD;
setObjectViewDistance [_savedVD / 2, 50];

// Move to spawn position on first join — same location used on respawn
[] spawn {
    sleep 0.5;
    player setPosATL (getPosATL roofSpawn);
    player setDir 268;
    player setObjectTextureGlobal [0, "Textures\nhs_air_trauma_co.paa"];
};

// Respawn handler
player addEventHandler ["Respawn", {
    params ["_unit", "_corpse"];
    _unit setPosATL (getPosATL roofSpawn);
    _unit enableStamina false;
    _unit setUnitTrait ["weaponSway", false];
}];

// Determine role from DB-assigned variable set by FTD_fnc_whitelistCheck on the server.
// We wait briefly for it to propagate; fall back to "student" on timeout.
[] spawn {
    private _uid = getPlayerUID player;
    private _roleVar = format ["FI_playerRole_%1", _uid];
    private _timeout = diag_tickTime + 15;
    waitUntil {
        sleep 0.5;
        !(isNil { missionNamespace getVariable [_roleVar, nil] }) || diag_tickTime > _timeout
    };

    private _role = missionNamespace getVariable [_roleVar, "student"];
    diag_log format ["[FTD][initPlayerLocal] Role for %1 (%2): %3", name player, _uid, _role];

    if (_role == "instructor") then {

        // Assign Zeus on initial join
        [player] remoteExec ["FTD_fnc_reassignZeus", 2];

        // ── Instructor map binds ──────────────────────────────────────────────
        // Remove previous Map handler if registered (prevents accumulation on rejoin)
        private _prevMapEH = missionNamespace getVariable ["FI_mapEH", -1];
        if (_prevMapEH >= 0) then { removeMissionEventHandler ["Map", _prevMapEH]; };
        private _mapEH = addMissionEventHandler ["Map", {
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

                // Track mouse position for F / Shift+F keys
                _mapCtrl ctrlAddEventHandler ["MouseMoving", {
                    params ["_ctrl", "_x", "_y"];
                    uiNamespace setVariable ["FI_mapMousePos", [_x, _y, _ctrl]];
                }];

                // F — set landing location at cursor; Shift+F — time trial at cursor
                _mapDisplay displayAddEventHandler ["KeyDown", {
                    params ["_display", "_key", "_shift"];
                    if (_key != 33) exitWith { false }; // 33 = F
                    if !(isNil { uiNamespace getVariable ["FI_speedPickPos", nil] }) exitWith { false };
                    private _mouseData = uiNamespace getVariable ["FI_mapMousePos", []];
                    if (count _mouseData < 3) exitWith { false };
                    private _ctrl  = _mouseData select 2;
                    private _mx    = _mouseData select 0;
                    private _my    = _mouseData select 1;
                    private _worldPos = _ctrl ctrlMapScreenToWorld [_mx, _my];
                    private _pos = [_worldPos select 0, _worldPos select 1, 0];
                    { ctrlDelete _x } forEach (uiNamespace getVariable ["FI_overlayCtrls", []]);
                    uiNamespace setVariable ["FI_overlayCtrls", []];
                    deleteMarker "FI_PreviewMarker";
                    if (_shift) then {
                        // Shift+F — time trial
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
                            private _targets = (crew _heli) select {
                                isPlayer _x && { (missionNamespace getVariable [format ["FI_playerRole_%1", getPlayerUID _x], "student"]) == "instructor" }
                            };
                            [_startTime] remoteExec ["FTD_fnc_speedTimerHUD", _targets];
                            waitUntil { sleep 0.5;
                                !(missionNamespace getVariable ["FI_speedTimer_active", false]) ||
                                !(missionNamespace getVariable ["landingDetection_active", false]) ||
                                !alive _heli
                            };
                            missionNamespace setVariable ["FI_speedTimer_active", false];
                        };
                    } else {
                        // F — set landing location
                        [_pos, localize "STR_FI_Loc_Custom", false] call FTD_fnc_setLandingLocation;
                    };
                    true
                }];

            };
        }];
        missionNamespace setVariable ["FI_mapEH", _mapEH];

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

    } else {};

    // ── Y key opens settings panel for everyone ──────────────────────────────
    uiNamespace setVariable ["FI_settingsReady", true];
    [] spawn {
        waitUntil { sleep 0.2; !(isNull (findDisplay 46)) };
        (findDisplay 46) displayAddEventHandler ["KeyDown", {
            params ["_display", "_key", "_shift", "_ctrl", "_alt"];
            if (_key == 59 && !_shift && !_ctrl && !_alt) then { // 59 = F1
                // Don't do anything while map is open
                if (visibleMap) exitWith { false };
                if (!(isNull (findDisplay 9001))) then {
                    closeDialog 2;
                } else {
                    if (uiNamespace getVariable ["FI_settingsReady", true]) then {
                        uiNamespace setVariable ["FI_settingsReady", false];
                        call FTD_fnc_openEarplugUI;
                        [] spawn { sleep 1; uiNamespace setVariable ["FI_settingsReady", true]; };
                    };
                };
                true // consume F1 to suppress default command menu
            } else { false }
        }];
    };
};
