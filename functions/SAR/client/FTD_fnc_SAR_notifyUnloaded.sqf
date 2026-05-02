// FTD_fnc_SAR_notifyUnloaded.sqf
// Notifies all clients that the person was unloaded before reaching the hospital.
// Usage: [] call FTD_fnc_SAR_notifyUnloaded;  (via remoteExec on all clients)

["Person Unloaded", "Person removed from vehicle before reaching the hospital. Return and reload them.", "warning"] call FTD_fnc_notify;
