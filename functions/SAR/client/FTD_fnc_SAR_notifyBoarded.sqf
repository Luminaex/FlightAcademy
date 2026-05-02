// FTD_fnc_SAR_notifyBoarded.sqf
// Notifies all clients that the person is aboard — proceed to the hospital.
// Usage: [] call FTD_fnc_SAR_notifyBoarded;  (via remoteExec on all clients)

private _hospPos = getMarkerPos "Hos_2";
["Person Aboard", "Person loaded. Fly to the hospital to complete the rescue.", "info", _hospPos] call FTD_fnc_notify;
