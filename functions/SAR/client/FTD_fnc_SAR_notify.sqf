// FTD_fnc_SAR_notify.sqf
// Displays the SAR mission start notification on the local client.
// Usage: [_pos] call FTD_fnc_SAR_notify;  (via remoteExec on all clients)

["SAR Mission", "Lost person reported. Locate them in the search zone, drag them into your aircraft, and fly them to the hospital.", "info"] call FTD_fnc_notify;
