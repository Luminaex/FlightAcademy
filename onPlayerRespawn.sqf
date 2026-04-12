removeAllWeapons player;
removeGoggles player;
removeHeadgear player;
removeVest player;
removeUniform player;
removeAllAssignedItems player;
clearAllItemsFromBackpack player;
removeBackpack player;

player setUnitLoadout(player getVariable["Saved_Loadout",[]]);
player setPosATL (getPosATL roofSpawn);
player setDir 268;
player setObjectTextureGlobal [0, "Textures\nhs_air_trauma_co.paa"];

private _allowedUnits = [
    missionNamespace getVariable ["FlightInstructor_0", objNull],
    missionNamespace getVariable ["FlightInstructor_1", objNull],
    missionNamespace getVariable ["FlightInstructor_2", objNull],
    missionNamespace getVariable ["FlightInstructor_3", objNull]
];

// All players are invulnerable — this is a training mission
player allowDamage false;

// Re-assign Zeus curator to the new player entity after respawn
// (the curator module loses its owner when the old entity is destroyed)
if (player in _allowedUnits) then {
    private _respawnedPlayer = player;
    [_respawnedPlayer] remoteExec ["FTD_fnc_reassignZeus", 2];
};

// Instructors get a heli crash monitor: if their heli is destroyed, respawn it 100m up
if (player in _allowedUnits) then {
    [] spawn {
        private _uid = getPlayerUID player;
        private _varName = format ["FI_heli_%1", _uid];

        while { alive player } do {
            // Wait until this instructor has an active heli
            waitUntil { sleep 0.5; !isNull (missionNamespace getVariable [_varName, objNull]) };
            private _heli = missionNamespace getVariable [_varName, objNull];
            if (isNull _heli) exitWith {};

            // Monitor until destroyed or player respawns (heli var cleared)
            waitUntil {
                sleep 0.5;
                !alive _heli ||
                isNull (missionNamespace getVariable [_varName, objNull])
            };

            // Only act if it was destroyed (not just deleted/replaced)
            if (!alive _heli && !isNull _heli) then {
                private _crashPos = getPosATL _heli;
                private _class = typeOf _heli;
                private _crashDir = getDir _heli;
                private _respawnPos = [_crashPos select 0, _crashPos select 1, (_crashPos select 2) + 100];

                deleteVehicle _heli;

                private _newHeli = createVehicle [_class, _respawnPos, [], 0, "FLY"];
                _newHeli setDir _crashDir;
                _newHeli setVariable ["BIS_enableRandomization", false];
                _newHeli setVariable ["FI_ownerUID", _uid, true];

                switch (_class) do {
                    case "B_Heli_Light_01_F": {
                        _newHeli setObjectTextureGlobal [0, "Textures\FSm900.paa"];
                    };
                    case "O_Heli_Light_02_unarmed_F": {
                        _newHeli setObjectTextureGlobal [0, "Textures\FSorca.paa"];
                    };
                    default {};
                };

                clearWeaponCargoGlobal _newHeli;
                clearMagazineCargoGlobal _newHeli;
                clearItemCargoGlobal _newHeli;
                clearBackpackCargoGlobal _newHeli;

                missionNamespace setVariable [_varName, _newHeli, true];

                [_newHeli] remoteExec ["FTD_fnc_enterHeli", player];
                [localize "STR_FI_Notify_HeliRespawnTitle", localize "STR_FI_Notify_HeliRespawnMsg", "warning"] call FTD_fnc_notify;
            };
        };
    };
};
