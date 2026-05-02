// FTD_fnc_SAR_addDragActions.sqf
// Adds vanilla action-menu entries to the lost person NPC (runs on each client).
//   "Carry Person"    — attaches NPC to the acting player, player enters carry stance
//   "Load into Vehicle" — moves carried NPC into nearest player vehicle as cargo
//   "Release Person" — detaches NPC and drops them at the player's feet
// Usage: [_npc] call FTD_fnc_SAR_addDragActions;

params ["_npc"];
if (isNull _npc) exitWith {};

// ── Drag ──────────────────────────────────────────────────────────────────────
_npc addAction [
    "<t color='#ffcc00'>Carry Person</t>",
    {
        params ["_target", "_caller"];
        if (_target getVariable ["SAR_beingCarried", false]) exitWith {};

        _target setVariable ["SAR_beingCarried", true, true];
        _target setVariable ["SAR_carrier", _caller, true];

        // Switch NPC to a supported standing pose so they look held rather than frozen
        _target setUnitPos "UP";
        _target playMoveNow "Acts_WoundedReceivingHelp_intro";

        // Attach NPC to the side of the player at standing height
        _target attachTo [_caller, [0.5, 0.2, 0]];
        _target setDir getDir _caller;

        // Keep NPC direction synced and animation held while being dragged
        [_target, _caller] spawn {
            params ["_npc", "_carrier"];
            while { _npc getVariable ["SAR_beingCarried", false] } do {
                _npc setDir (getDir _carrier);
                // Re-apply if the engine resets the pose
                if (animationState _npc != "acts_woundedreceivinghelp_intro") then {
                    _npc playMoveNow "Acts_WoundedReceivingHelp_intro";
                };
                sleep 0.2;
            };
        };

        diag_log format ["[FTD][SAR] %1 started dragging person", name _caller];
    },
    [],     // arguments
    1.5,    // priority
    true,   // showWindow
    false,  // hideOnUse
    "",     // shortcut
    // Condition: not already carried, player close enough, on foot
    "!(_target getVariable ['SAR_beingCarried', false]) && (player distance _target < 4) && (vehicle player == player)"
];

// ── Load into vehicle ─────────────────────────────────────────────────────────
_npc addAction [
    "<t color='#00ccff'>Load Person into Vehicle</t>",
    {
        params ["_target", "_caller"];

        // Find the nearest land vehicle or aircraft within 20m
        private _nearby = nearestObjects [_caller, ["LandVehicle", "Air"], 20];
        private _veh = objNull;
        {
            // Skip the caller themselves and other players being used as a "vehicle"
            if !(_x isKindOf "Man") exitWith { _veh = _x; };
        } forEach _nearby;

        if (isNull _veh) exitWith {
            ["No Vehicle", "No vehicle within 20m. Get closer to the helicopter.", "warning"] call FTD_fnc_notify;
        };

        detach _target;
        _target setVariable ["SAR_beingCarried", false, true];
        _target setVariable ["SAR_carrier", objNull, true];
        _target moveInCargo [_veh, -1];
        diag_log format ["[FTD][SAR] Person loaded into %1 by %2", typeOf _veh, name _caller];
    },
    [],
    1.5,
    true,
    false,
    "",
    // Condition: currently being carried by this player
    "(_target getVariable ['SAR_beingCarried', false]) && (_target getVariable ['SAR_carrier', objNull] == player)"
];

// ── Release ───────────────────────────────────────────────────────────────────
_npc addAction [
    "<t color='#ff6666'>Release Person</t>",
    {
        params ["_target", "_caller"];
        detach _target;
        _target setVariable ["SAR_beingCarried", false, true];
        _target setVariable ["SAR_carrier", objNull, true];
        // Return to injured crouching pose when dropped
        _target setUnitPos "MIDDLE";
        _target playMoveNow "Acts_AidlPpneMstpSnonWnonDnon_injured";
        diag_log format ["[FTD][SAR] %1 released person", name _caller];
    },
    [],
    1.5,
    true,
    false,
    "",
    "(_target getVariable ['SAR_beingCarried', false]) && (_target getVariable ['SAR_carrier', objNull] == player)"
];
