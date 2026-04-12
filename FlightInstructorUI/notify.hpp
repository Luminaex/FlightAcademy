// Notification system RSC control classes — used by FTD_fnc_notify via ctrlCreate

class FTD_TimerText {
    access = 0;
    type = 0;           // CT_STATIC
    idc = -1;
    style = 514;        // ST_CENTER (2) | ST_VCENTER (512) — both axes centred
    colorBackground[] = {0,0,0,0};
    colorText[] = {1,1,1,1};
    font = "RobotoCondensedBold";
    sizeEx = 0.040;
    text = "";
    fixedWidth = 0;
    x = 0; y = 0; w = 0.2; h = 0.06;
};

class FTD_NotifyText {
    access = 0;
    type = 0;       // CT_STATIC
    idc = -1;
    style = 0;      // ST_LEFT
    colorBackground[] = {0,0,0,0};
    colorText[] = {1,1,1,1};
    font = "RobotoCondensed";
    sizeEx = 0.020;
    text = "";
    fixedWidth = 0;
    x = 0; y = 0; w = 0.3; h = 0.04;
};

class FTD_NotifyMap {
    access = 0;
    type = 101;     // CT_MAP
    idc = -1;
    style = 0;

    scale = 0.08;
    scaleMin = 0.001;
    scaleMax = 0.5;
    scaleDefault = 0.08;

    maxSatelliteAlpha = 1;
    alphaFadeStartScale = 1.0;
    alphaFadeEndScale = 0.5;
    text = "";
    showCountourLines = 1;

    font = "RobotoCondensed"; fontLabel = "RobotoCondensed"; fontGrid  = "RobotoCondensed";
    fontUnits = "RobotoCondensed"; fontNames = "RobotoCondensed";
    fontInfo  = "RobotoCondensed"; fontLevel = "RobotoCondensed";

    sizeEx = 0.018; sizeExLabel = 0.018; sizeExGrid  = 0.015;
    sizeExUnits = 0.018; sizeExNames = 0.018; sizeExInfo = 0.015; sizeExLevel = 0.015;

    ptsPerSquareSea = 3; ptsPerSquareTxt = 8; ptsPerSquareCLn = 6;
    ptsPerSquareExp = 5; ptsPerSquareCost = 5; ptsPerSquareFor = 4;
    ptsPerSquareForEdge = 4; ptsPerSquareRoad = 5; ptsPerSquareObj = 5;
    widthRailWay = 2;

    colorBackground[]          = {0.12,0.12,0.12,1.0};
    colorOutside[]             = {0.08,0.08,0.08,1.0};
    colorLand[]                = {0.15,0.15,0.15,1.0};
    colorInactive[]            = {0.10,0.10,0.10,0.7};
    colorSea[]                 = {0.10,0.14,0.18,1.0};
    colorCountlinesWater[]     = {0.59,0.71,0.78,1.0};
    colorMainCountlinesWater[] = {0.50,0.62,0.70,1.0};
    colorForest[]              = {0.67,0.73,0.50,1.0};
    colorForestBorder[]        = {0.55,0.62,0.40,1.0};
    colorRocks[]               = {0.70,0.67,0.55,1.0};
    colorRocksBorder[]         = {0.60,0.57,0.45,1.0};
    colorCountlines[]          = {0.67,0.56,0.36,1.0};
    colorMainCountlines[]      = {0.60,0.48,0.28,1.0};
    colorLevels[]              = {0.67,0.56,0.36,0.5};
    colorTracks[]              = {0.78,0.72,0.58,1.0};
    colorTracksFill[]          = {0.90,0.86,0.74,1.0};
    colorRoads[]               = {0.80,0.78,0.72,1.0};
    colorRoadsFill[]           = {0.95,0.93,0.88,1.0};
    colorMainRoads[]           = {0.85,0.60,0.35,1.0};
    colorMainRoadsFill[]       = {0.95,0.78,0.55,1.0};
    colorPowerLines[]          = {0.30,0.30,0.30,1.0};
    colorRailWay[]             = {0.40,0.10,0.10,1.0};
    colorText[]                = {0.00,0.00,0.00,1.0};
    colorGrid[]                = {0.00,0.00,0.00,1.0};
    colorGridMap[]             = {0.00,0.00,0.00,0.2};
    colorNames[]               = {0.00,0.00,0.00,1.0};
    colorNameLocal[]           = {0.00,0.00,0.00,1.0};
    colorNameLocalShops[]      = {0.30,0.00,0.00,1.0};
    colorNameMilitary[]        = {0.00,0.00,0.30,1.0};
    colorNameCity[]            = {0.00,0.00,0.00,1.0};
    colorNameVillage[]         = {0.00,0.00,0.00,0.8};
    colorNameCap[]             = {0.00,0.00,0.00,1.0};

    showCountourInterval = 0;

    class CustomMark  { icon = ""; size = 24; color[] = {1,1,1,1}; coefMin = 0; coefMax = 1; importance = 1; };
    class ActiveMarker { color[] = {1,1,1,1}; size = 24; };
    class LineMarker  { lineWidthThin = 2; lineWidthThick = 4; lineDistanceMin = 5; lineLengthMin = 10; };

    // Landmark icon subclasses — required to suppress RPT spam
    class Tree        { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class SmallTree   { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class Bush        { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class Cross       { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class Rock        { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class Bunker      { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class Fortress    { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class Fountain    { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class ViewTower   { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class Lighthouse  { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class Quay        { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class BusStop     { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class Transmitter { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class Stack       { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class Watertower  { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class Church      { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class Chapel      { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class Fuelstation { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class Hospital    { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class Ruin        { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class Tourism     { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class PowerSolar  { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class PowerWave   { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class PowerWind   { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class Shipwreck   { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class Waypoint          { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class WaypointCompleted { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };
    class Command     { icon = ""; color[] = {1,1,1,1}; size = 1; coefMin = 0; coefMax = 1; importance = 1; };

    x = 0; y = 0; w = 0.3; h = 0.2;
};
