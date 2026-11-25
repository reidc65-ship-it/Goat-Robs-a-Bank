// =====================================================================
//  oFarmUpgrades -> Draw
// =====================================================================

var _grass_y = ground_y - 40;

// --- Before Greener Grass: the family is broke --------------------------
if (!upgrade_owned("grass")) {
    // Bleach the pasture to a dry brown.
    draw_set_alpha(0.55);
    draw_set_colour(make_colour_rgb(158, 124, 62));
    draw_rectangle(0, 520, farm_x2, ground_y, false);
    draw_rectangle(1840, 520, room_width, ground_y, false);
    draw_set_alpha(1);

    draw_sprite(sFarmGrassDead, 0, 0, _grass_y);
}

// --- Greener Grass ----------------------------------------------------
if (upgrade_owned("grass")) {
    // Brighten the pasture behind the fence.
    draw_set_alpha(0.3);
    draw_set_colour(make_colour_rgb(120, 230, 90));
    draw_rectangle(0, 520, farm_x2, ground_y, false);
    draw_set_alpha(1);

    draw_sprite(sFarmGrassLush, 0, 0, _grass_y);
}

// --- Sprinkler --------------------------------------------------------
if (upgrade_owned("sprinkler")) {
    draw_sprite(sSprinkler, 0, sprinkler_x - 14, ground_y - 52);

    // Keep the animated droplets coming from the sprinkler head.
    draw_set_colour(make_colour_rgb(150, 215, 250));
    for (var d = 0; d < 16; d++) {
        var _side = (d mod 2 == 0) ? 1 : -1;
        var _t    = ((current_time / 900) + d / 16) mod 1;
        var _dx   = _side * _t * 120;
        var _dy   = -36 * sin(_t * pi) + _t * 40;
        draw_circle(sprinkler_x + _dx, ground_y - 50 + _dy, 3, false);
    }
}

draw_set_colour(c_white);
draw_set_alpha(1);
