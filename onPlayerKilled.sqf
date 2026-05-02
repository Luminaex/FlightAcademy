player setVariable["Saved_Loadout",getUnitLoadout player];

// Log crash stat — only count it when the player was piloting a helicopter
private _killer = _this select 1;
if (_killer isKindOf "Air") then {
    private _uid = getPlayerUID player;
    ["player_stat_inc", [_uid, "crashes"]] remoteExec ["FTD_fnc_dbProxy", 2];
    diag_log format ["[FTD][DB] Crash logged for %1 (%2)", name player, _uid];
};
