# Flight Academy

An Arma 3 multiplayer mission set on Altis designed to help players learn and improve helicopter flying. Supports 1–7 players with up to 4 instructor slots and unlimited student (noctor) slots.

## Overview

Instructors set landing targets for students via a custom map overlay. Students fly to the target location and land — the mission detects a successful landing and marks the task complete. The mission is sandbox with no AI, instant respawn, and time locked to midday.

## Roles

### Instructor
Occupies one of the `FlightInstructor_0–3` slots. Has access to the full instructor panel (opened with the Windows key or User10 action) which provides:

- **Location list** — a scrollable list of named landing zones across Altis. Single-click pans the map to it with a preview marker; double-click or the Set button assigns it as the active task for all players.
- **Spawn buttons** — spawns an MH-9 Hummingbird (`M-900`) or an Orca for students to fly.
- **Time trial** — Shift+click on the map or the Time Trial button starts a timed run. A HUD timer is shown to instructors in the helicopter and the elapsed time is displayed when the student lands.
- **Teleport** — press F on the map to open a player select dialog and teleport a student to the hovered position.
- **Path toggle** — shows/hides a predefined flight path overlay on the map.
- **Respawn car** — respawns the ground vehicle at its start position.
- **Volume** — opens the earplug volume slider.
- **Clear task** — cancels the active landing task.

### Student (Noctor)
Gets the earplug volume UI on the Windows key or User10 action. Receives map tasks and landing notifications when they complete a landing.

## Features

- **Landing detection** — polls the student's helicopter every 0.5s and triggers task success when within 100m of the target, below 1.5m altitude (or 3–20m for rooftop landings), at near-zero velocity.
- **Task manager** — server-side debounced task creation/deletion using `BIS_fnc_taskCreate`. Rapid instructor inputs are collapsed to the latest request.
- **Indestructible objects** — all mission editor objects are set `allowDamage false` on server init. Terrain objects (trees, rocks, walls) are recreated on destruction via a `Killed` event handler.
- **Time locked** — server locks time to 12:00 with `setTimeMultiplier 0`.
- **Auto task clear** — if all players disconnect the active task is deleted so joining players don't see a stale objective.
- **Localisation** — all UI strings are driven by `stringtable.xml`.

## File Structure

```
FlightAcademy.Altis/
├── description.ext              # Mission config, difficulty, CfgFunctions
├── mission.sqm                  # Editor layout (spawn points, markers, objects)
├── initServer.sqf               # Server init — locations, terrain respawn, task cleanup
├── initPlayerLocal.sqf          # Client init — role detection, keybinds, stamina
├── onPlayerRespawn.sqf          # Respawn handler
├── onPlayerKilled.sqf           # Kill handler
├── stringtable.xml              # Localisation strings
├── Textures/                    # Load screen and UI textures
├── FlightInstructorUI/
│   ├── dialog.hpp               # Dialog class definitions
│   └── notify.hpp               # Notification display class
└── functions/
    ├── FTD_fnc_enterHeli.sqf        # Auto-seat player in nearby helicopter
    ├── FTD_fnc_landingDetection.sqf # Landing success polling loop
    ├── FTD_fnc_locations.sqf        # Populates FI_locations with named LZs
    ├── FTD_fnc_notify.sqf           # Displays on-screen notification
    ├── FTD_fnc_openEarplugUI.sqf    # Volume slider UI
    ├── FTD_fnc_openInstructorUI.sqf # Full instructor map overlay
    ├── FTD_fnc_openMapPick.sqf      # Map click-to-pick mode
    ├── FTD_fnc_openSpawnConfirm.sqf # Spawn confirmation dialog
    ├── FTD_fnc_openTpPlayerSelect.sqf # Player teleport selection dialog
    ├── FTD_fnc_quickStart.sqf       # Quick-starts a time trial
    ├── FTD_fnc_setLandingLocation.sqf # Sets active task and starts detection
    ├── FTD_fnc_speedTimerHUD.sqf    # Time trial HUD timer
    ├── FTD_fnc_spawnVehicle.sqf     # Spawns and positions a helicopter
    ├── FTD_fnc_tpPlayer.sqf         # Teleports a player to a position
    └── serverFunctions/
        ├── FTD_fnc_reassignZeus.sqf # Reassigns Zeus curator to instructors
        ├── FTD_fnc_respawnCar.sqf   # Respawns the ground vehicle
        └── FTD_fnc_taskManager.sqf  # Server-side task create/succeed/delete
```

## Author

Luminaex
