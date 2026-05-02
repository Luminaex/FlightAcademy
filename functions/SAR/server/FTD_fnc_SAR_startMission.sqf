// FTD_fnc_SAR_startMission.sqf
// Spawns a lost person NPC at a random position inside the "snrZone" marker.
// The player must drag the person into a vehicle and fly them to the "Hos_2" marker.
// Must be called on the server.
// Usage: [] call FTD_fnc_SAR_startMission;

if (!isServer) exitWith {};

params [["_pilotUID", "", [""]]];

diag_log "[FTD][SAR] Starting SAR mission";

// Store the initiating pilot's UID so FTD_fnc_SAR_onRescue can credit them
missionNamespace setVariable ["SAR_pilotUID", _pilotUID, false];

call FTD_fnc_SAR_cleanup;

// Pick a random position inside the snrZone ellipse marker
private _markerPos = getMarkerPos "snrZone";
private _markerA   = markerSize "snrZone" select 0;
private _markerB   = markerSize "snrZone" select 1;
private _markerDir = markerDir "snrZone";

private _pos = [0,0,0];
private _found = false;
for "_i" from 0 to 99 do {
    private _rx = (_markerA * 2 * random 1) - _markerA;
    private _ry = (_markerB * 2 * random 1) - _markerB;
    private _rad = _markerDir * (pi / 180);
    private _wx = _rx * cos(_rad) - _ry * sin(_rad);
    private _wy = _rx * sin(_rad) + _ry * cos(_rad);
    if (((_rx / _markerA)^2 + (_ry / _markerB)^2) <= 1) then {
        _pos = [(_markerPos select 0) + _wx, (_markerPos select 1) + _wy, 0];
        _pos = [_pos, 0, 100, 10, 0, 0.5, 0] call BIS_fnc_findSafePos;
        _found = true;
        break;
    };
};

if (!_found) then {
    _pos = _markerPos;
    diag_log "[FTD][SAR] WARNING — could not find safe pos inside snrZone, using marker centre";
};

diag_log format ["[FTD][SAR] Spawn position: %1", _pos];

missionNamespace setVariable ["SAR_active",    true, true];
missionNamespace setVariable ["SAR_victimPos", _pos, true];

// Spawn the lost person
private _npc = createAgent ["C_man_1", _pos, [], 0, "NONE"];
_npc setDir (random 360);
_npc allowDamage false;
_npc disableAI "MOVE";
_npc disableAI "AUTOTARGET";
_npc disableAI "TARGET";
_npc disableAI "WEAPONAIM";
_npc disableAI "RADIOPROTOCOL";
_npc disableAI "CHECKVISIBLE";
_npc setVariable ["SAR_beingCarried", false, true];
missionNamespace setVariable ["SAR_victim", _npc, false];

// Keep the downed animation enforced — the AI engine overrides switchMove on the next tick,
// so we loop on the server to reapply it whenever the NPC is not being carried.
[_npc] spawn {
    params ["_npc"];
    while { alive _npc && { missionNamespace getVariable ["SAR_active", false] } } do {
        if !(_npc getVariable ["SAR_beingCarried", false]) then {
            [_npc] remoteExec ["FTD_fnc_SAR_applyDownedAnim", _npc];
        };
        sleep 2;
    };
};

diag_log format ["[FTD][SAR] NPC spawned: %1", _npc];

// Place the search marker at a random point within 1500m of the NPC.
// Players search this zone — the NPC is somewhere inside it but not at the centre.
private _angle      = random 360;
private _dist       = random 1500;
private _searchPos  = [
    (_pos select 0) + _dist * sin(_angle),
    (_pos select 1) + _dist * cos(_angle),
    0
];
// Fill marker — matches snrZone style (orange, diagonal fill)
private _searchMarker = createMarker ["SAR_SearchArea", _searchPos];
_searchMarker setMarkerShape "ELLIPSE";
_searchMarker setMarkerSize [1500, 1500];
_searchMarker setMarkerColor "ColorOrange";
_searchMarker setMarkerBrush "FDiagonal";
_searchMarker setMarkerAlpha 0.5;
_searchMarker setMarkerText "Search Area";

// Border marker — matches snrZone_1 style (black, border only)
private _searchBorder = createMarker ["SAR_SearchBorder", _searchPos];
_searchBorder setMarkerShape "ELLIPSE";
_searchBorder setMarkerSize [1500, 1500];
_searchBorder setMarkerColor "ColorBlack";
_searchBorder setMarkerBrush "Border";
_searchBorder setMarkerAlpha 1;

// Add drag/load actions and floating 3D icon on all clients
[_npc] remoteExec ["FTD_fnc_SAR_addDragActions", 0];

// Create BIS task pointing to the search area, not the exact NPC position
["SAR_create", allPlayers, _searchPos] remoteExec ["FTD_fnc_SAR_taskManager", 2];

// Notify all clients
[] remoteExec ["FTD_fnc_SAR_notify", 0];

call FTD_fnc_SAR_detection;
