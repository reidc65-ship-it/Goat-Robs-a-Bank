// =====================================================================
//  oFarmUpgrades -> Create
//  Draws purchased farm improvements over the farm background. Bought
//  from the Elder's shop, on the FARM tab.
// =====================================================================

game_state_init();

// Behind the player (depth 0), in front of the background (depth 1000).
depth = 50;

ground_y = 640;   // top of inst_farm_ground
farm_x2  = 1080;  // the barn wall starts here

// The sprinkler sits between the water trough and the chickens.
sprinkler_x = 660;
