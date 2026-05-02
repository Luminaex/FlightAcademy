# Flight Academy

An Arma 3 multiplayer mission set on Altis designed to help players learn and improve helicopter flying. Supports 1–7 players with up to 4 instructor slots and unlimited student slots.

## Overview

Instructors set landing targets for students via a custom map overlay. Students fly to the target location and land — the mission detects a successful landing and marks the task complete. The mission is sandbox with no AI, instant respawn, and time locked to midday.

Roles are assigned at join time via a server-side whitelist database. Instructors are identified by Steam64 UID; everyone else joins as a student.

## Roles

### Instructor
Whitelisted in the database. Has access to the full instructor panel (opened with the Windows key or User10 action) which provides:

- **Location list** — a scrollable list of named landing zones across Altis. Single-click pans the map to it with a preview marker; double-click or the Set button assigns it as the active task for all players.
- **Spawn buttons** — spawns an MH-9 Hummingbird (`M-900`) or an Orca for students to fly.
- **Time trial** — Shift+click on the map or the Time Trial button starts a timed run. A HUD timer is shown to instructors in the helicopter and the elapsed time is displayed when the student lands.
- **SAR mission** — launches a Search & Rescue scenario (see below).
- **Respawn car** — respawns the ground vehicle at its start position.
- **Volume** — opens the earplug volume slider.
- **Clear task** — cancels the active landing task.

### Student
Role assigned to anyone not on the whitelist. Receives map tasks and landing notifications when they complete a landing.

## Features

- **Landing detection** — polls the student's helicopter every 0.5s and triggers task success when within 100m of the target, below 1.5m altitude (or 3–20m for rooftop landings), at near-zero velocity.
- **SAR module** — instructor can launch a Search & Rescue mission. A civilian NPC spawns inside the `snrZone` marker. Students must locate the person, drag them into a helicopter, and fly them to the hospital (`Hos_2`). The task updates through three states: searching → carrying → transport to hospital.
- **Database integration** — extDB3-backed logging of landings, crashes, time played, and SAR rescues per player. Requires a running MySQL/MariaDB instance and extDB3 installed on the server (see Setup below).
- **Whitelist** — instructor role is controlled by a `whitelist` database table keyed on Steam64 UID.
- **Task manager** — server-side debounced task creation/deletion using `BIS_fnc_taskCreate`. Rapid instructor inputs are collapsed to the latest request.
- **Indestructible objects** — all mission editor objects are set `allowDamage false` on server init. Terrain objects (trees, rocks, walls) are recreated on destruction via a `Killed` event handler.
- **Time locked** — server locks time to 12:00 with `setTimeMultiplier 0`.
- **Auto task clear** — if all players disconnect the active task is deleted so joining players don't see a stale objective.
- **Localisation** — all UI strings are driven by `stringtable.xml`.

## Setup

### Dev mode (no database)
In `initServer.sqf` set:
```sqf
FTD_devMode = true;
```
Everyone joins as instructor, no extDB3 or database required.

### Production (database enabled)
1. Set `FTD_devMode = false` in `initServer.sqf`.
2. Install [extDB3](https://github.com/Torchlight-SQF-Projects/extDB3) on the server.
3. Create the database schema:

```sql
CREATE TABLE whitelist (
    uid VARCHAR(32) PRIMARY KEY,
    name VARCHAR(64)
);

CREATE TABLE players (
    uid VARCHAR(32) PRIMARY KEY,
    name VARCHAR(64),
    landings_completed INT DEFAULT 0,
    crashes INT DEFAULT 0,
    time_played INT DEFAULT 0
);

CREATE TABLE sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    uid VARCHAR(32),
    name VARCHAR(64),
    joined_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    duration_secs INT DEFAULT 0
);
```

4. Add instructor UIDs to the `whitelist` table.

## File Structure

```
FlightAcademy.Altis/
├── description.ext              # Mission config, difficulty, CfgFunctions
├── mission.sqm                  # Editor layout (spawn points, markers, objects)
├── initServer.sqf               # Server init — DB, whitelist, terrain respawn, task cleanup
├── initPlayerLocal.sqf          # Client init — role detection, keybinds, stamina
├── onPlayerRespawn.sqf          # Respawn handler
├── onPlayerKilled.sqf           # Kill/crash stat logging
├── stringtable.xml              # Localisation strings
├── Textures/                    # Load screen and UI textures
├── FlightInstructorUI/
│   ├── dialog.hpp               # Dialog class definitions
│   └── notify.hpp               # Notification display class
└── functions/
    ├── FTD_fnc_enterHeli.sqf            # Auto-seat player in nearby helicopter
    ├── FTD_fnc_landingDetection.sqf     # Landing success polling loop
    ├── FTD_fnc_locations.sqf            # Populates FI_locations with named LZs
    ├── FTD_fnc_notify.sqf               # Displays on-screen notification
    ├── FTD_fnc_openEarplugUI.sqf        # Volume slider UI
    ├── FTD_fnc_openInstructorUI.sqf     # Full instructor map overlay
    ├── FTD_fnc_openMapPick.sqf          # Map click-to-pick mode
    ├── FTD_fnc_openSpawnConfirm.sqf     # Spawn confirmation dialog
    ├── FTD_fnc_quickStart.sqf           # Quick-starts a time trial
    ├── FTD_fnc_setLandingLocation.sqf   # Sets active task and starts detection
    ├── FTD_fnc_speedTimerHUD.sqf        # Time trial HUD timer
    ├── FTD_fnc_spawnVehicle.sqf         # Spawns and positions a helicopter
    ├── serverFunctions/
    │   ├── FTD_fnc_db.sqf               # extDB3 wrapper (async protocol, SQL escaping)
    │   ├── FTD_fnc_dbProxy.sqf          # Thin relay for client-initiated DB calls
    │   ├── FTD_fnc_reassignZeus.sqf     # Assigns Zeus curator to instructors
    │   ├── FTD_fnc_respawnCar.sqf       # Respawns the ground vehicle
    │   ├── FTD_fnc_taskManager.sqf      # Server-side task create/succeed/delete
    │   └── FTD_fnc_whitelistCheck.sqf   # Whitelist lookup and role assignment on join
    └── SAR/
        ├── client/
        │   ├── FTD_fnc_SAR_addDragActions.sqf   # Adds carry/load/release actions to the NPC
        │   ├── FTD_fnc_SAR_applyDownedAnim.sqf  # Enforces downed animation on the NPC
        │   ├── FTD_fnc_SAR_notify.sqf            # Mission start notification
        │   ├── FTD_fnc_SAR_notifyBoarded.sqf     # Person loaded notification
        │   ├── FTD_fnc_SAR_notifySuccess.sqf     # Rescue complete notification
        │   ├── FTD_fnc_SAR_notifyUnloaded.sqf    # Person dropped notification
        │   └── FTD_fnc_SAR_openConfirm.sqf       # Instructor restart confirmation dialog
        └── server/
            ├── FTD_fnc_SAR_cleanup.sqf           # Cleans up NPC, markers, and state
            ├── FTD_fnc_SAR_detection.sqf          # State machine: searching/carrying/in-vehicle
            ├── FTD_fnc_SAR_onRescue.sqf           # Success handler, credits pilot stat
            ├── FTD_fnc_SAR_startMission.sqf       # Spawns NPC, markers, starts detection
            └── FTD_fnc_SAR_taskManager.sqf        # SAR-specific task lifecycle
```

## Author

Luminaex
