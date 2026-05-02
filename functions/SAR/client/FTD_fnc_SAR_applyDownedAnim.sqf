// FTD_fnc_SAR_applyDownedAnim.sqf
// Forces the downed-on-back animation on the person NPC. Must run on the NPC's local machine.
// Usage: [_npc] remoteExec ["FTD_fnc_SAR_applyDownedAnim", _npc];

params ["_npc"];
if (isNull _npc) exitWith {};
_npc setUnitPos "MIDDLE";
_npc playMoveNow "Acts_AidlPpneMstpSnonWnonDnon_injured";
