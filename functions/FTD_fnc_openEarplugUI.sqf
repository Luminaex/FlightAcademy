// FTD_fnc_openEarplugUI.sqf
// Opens the settings dialog — Volume (0-100) and View Distance (m).
// Uses createDialog so the mouse is free.

if (dialog) exitWith {};

createDialog "FTD_SettingsDialog";

private _dlg = findDisplay 9001;
if (isNull _dlg) exitWith { diag_log "[FTD][Settings] Failed to create dialog"; };

// Load saved values
private _savedVol = profileNamespace getVariable ["FTD_setting_volume", 1.0];
private _savedVD  = profileNamespace getVariable ["FTD_setting_viewdist", 3000];

// Populate edit boxes with current values
(_dlg displayCtrl 111) ctrlSetText (str (round (_savedVol * 100)));
(_dlg displayCtrl 113) ctrlSetText (str (round _savedVD));

// Apply function called by the Apply button
FTD_fnc_settingsApply = {
    private _dlg = findDisplay 9001;
    if (isNull _dlg) exitWith {};

    // Volume — clamp 0-100
    private _volRaw = parseNumber (ctrlText (_dlg displayCtrl 111));
    private _vol = ((0 max _volRaw) min 100) / 100;
    _vol fadeSound _vol;
    missionNamespace setVariable ["FI_earplugVolume", _vol];
    profileNamespace setVariable ["FTD_setting_volume", _vol];

    // View distance — clamp 500-10000
    private _vdRaw = parseNumber (ctrlText (_dlg displayCtrl 113));
    private _vd = round ((500 max _vdRaw) min 10000);
    setViewDistance _vd;
    setObjectViewDistance [_vd / 2, 50];
    profileNamespace setVariable ["FTD_setting_viewdist", _vd];

    saveProfileNamespace;
    closeDialog 1;
};
