// FTD_fnc_reassignZeus
// Called server-side after an instructor respawns.
// Re-points the curator (Zeus) module at the new player entity so Zeus is restored.
// Params: [_unit] — the newly respawned instructor

params ["_unit"];
diag_log format ["[FTD][reassignZeus] Called for unit %1", _unit];

{
    private _curator = _x;
    private _ownerSlot = _curator getVariable ["Owner", ""];

    // Owner may already have been updated to the new unit object, or still hold the slot name string.
    // Match either way: check if the slot name resolves to this unit.
    private _slotUnit = missionNamespace getVariable [_ownerSlot, objNull];

    if (!isNull _slotUnit && { _slotUnit == _unit }) then {
        diag_log format ["[FTD][reassignZeus] Reassigned curator '%1' (slot '%2') to unit %3", _curator, _ownerSlot, _unit];
        _curator setVariable ["Owner", _unit, true];
    };
} forEach (allMissionObjects "ModuleCurator_F");
