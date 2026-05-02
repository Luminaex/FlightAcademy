// FTD_fnc_SAR_notifySuccess.sqf
// Displays a rescue success notification on the local client.
// Usage: [] call FTD_fnc_SAR_notifySuccess;  (via remoteExec on all clients)

["SAR Complete", "Person rescued successfully. Good work.", "landing_success"] call FTD_fnc_notify;
