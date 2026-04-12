// fn_locations.sqf
// Format: [[position], "Name", isRooftop]
FI_locations = [
    [[3731.7,12976.3,19.596],  localize "STR_FI_Loc_HospitalKavala",           true],
    [[4549.57,12445.6,0],      localize "STR_FI_Loc_HillsideCopperHill",        false],
    [[9719.65,15880.2,0],      localize "STR_FI_Loc_SpeedAgiosHospital",        false],
    [[3383.06,12125.2,0],      localize "STR_FI_Loc_SitPrisonHill",             false],
    [[4207,12241,0],           localize "STR_FI_Loc_SitMainRoad",               false],
    [[3780.69,13796.9,0],      localize "STR_FI_Loc_SitAggelochori",            false],
    [[4265.01,11852.5,0],      localize "STR_FI_Loc_SitNeri",                   false],
    [[4476.33,11664.1,0],      localize "STR_FI_Loc_SitNeriHill",               false],
    [[3693.94,11577.9,0],      localize "STR_FI_Loc_SteepNeri",                 false],
    [[3838.17,12408.2,0],      localize "STR_FI_Loc_TightKavala",               false],
    [[3826.49,13798.9,0],      localize "STR_FI_Loc_TightAggelochori",          false],
    [[4316.5,11935.5,0],       localize "STR_FI_Loc_TightNeri",                 false],
    [[3583.79,14464.9,0],      localize "STR_FI_Loc_TightNorthAggelochori",     false],
    [[13997.2,18630.7,0],      localize "STR_FI_Loc_TightAthira",               false]
];

FI_gasStations = [
    [[4001.47,12591.9,0],   localize "STR_FI_Gas_Kavala",       true],
    [[3757.6,13481.9,0],    localize "STR_FI_Gas_Aggelochori",  true],
    [[5021.5,14433.2,0],    localize "STR_FI_Gas_Kore",         true],
    [[11831.6,14156,0],     localize "STR_FI_Gas_Neochori",     true],
    [[6199.11,15081.5,0],   localize "STR_FI_Gas_Zaros",        true],
    [[6798.07,15561.4,0],   localize "STR_FI_Gas_Kalochori",    true],
    [[9023.64,15729.1,0],   localize "STR_FI_Gas_Dorida",       true],
    [[12026.7,15830,0],     localize "STR_FI_Gas_Charkia",      true],
    [[16750.9,12513.2,0],   localize "STR_FI_Gas_Lakka",        true],
    [[8481.78,18260.5,0],   localize "STR_FI_Gas_Pyrgos",       true],
    [[14173.3,16541.8,0],   localize "STR_FI_Gas_Rodopoli",     true],
    [[17417.1,13936.6,0],   localize "STR_FI_Gas_Katalaki",     true],
    [[16873.5,15473.2,0],   localize "STR_FI_Gas_Paros",        true],
    [[15297.5,17565.9,0],   localize "STR_FI_Gas_Telos",        true],
    [[14221.4,18302.3,0],   localize "STR_FI_Gas_Athira",       true],
    [[15781.2,17453.1,0],   localize "STR_FI_Gas_Oreokastro",   true],
    [[19963.2,11451,0],     localize "STR_FI_Gas_Selakano",     true],
    [[21230.6,7116.69,0],   localize "STR_FI_Gas_Molos",        true],
    [[20784.9,16666.1,0],   localize "STR_FI_Gas_Feres",        true],
    [[23379.5,19799,0],     localize "STR_FI_Gas_Abdera",       true],
    [[25701.3,21372.7,0],   localize "STR_FI_Gas_Pygros",       true],
    [[9205.82,12112.3,0],   localize "STR_FI_Gas_Sofia",        true]
];

FI_locations = FI_locations + FI_gasStations;
