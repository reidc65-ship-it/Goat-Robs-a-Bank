// =====================================================================
//  oFarmUpgrades -> Draw
// =====================================================================

// --- Before Greener Grass: the family is broke --------------------------
if (!upgrade_owned("grass")) {
    // Bleach the pasture to a dry brown.
    draw_set_alpha(0.55);
    draw_set_colour(make_colour_rgb(158, 124, 62));
    draw_rectangle(0, 520, farm_x2, ground_y, false);
    draw_rectangle(1840, 520, room_width, ground_y, false);
    draw_set_alpha(1);

    // Dead grass along the ground, covering the green tufts in the art.
    draw_set_colour(make_colour_rgb(128, 98, 48));
    draw_rectangle(0, ground_y - 12, farm_x2, ground_y + 2, false);
    draw_rectangle(1840, ground_y - 12, room_width, ground_y + 2, false);
    draw_set_colour(make_colour_rgb(176, 140, 76));
    for (var i = 0; i < 40; i++) {
        var _tx = 12 + i * 27;
        draw_triangle(_tx - 4, ground_y - 8, _tx + 4, ground_y - 8, _tx + 6, ground_y - 18, false);
    }
}

// --- Greener Grass ----------------------------------------------------
if (upgrade_owned("grass")) {
    // Brighten the pasture behind the fence.
    draw_set_alpha(0.3);
    draw_set_colour(make_colour_rgb(120, 230, 90));
    draw_rectangle(0, 520, farm_x2, ground_y, false);
    draw_set_alpha(1);

    // A thick band of lawn along the ground.
    draw_set_colour(make_colour_rgb(70, 170, 60));
    draw_rectangle(0, ground_y - 6, farm_x2, ground_y + 10, false);

    for (var i = 0; i < 40; i++) {
        var _gx = 12 + i * 27;

        // Grass tufts
        draw_set_colour(make_colour_rgb(96, 205, 80));
        draw_triangle(_gx - 6, ground_y - 2, _gx + 6, ground_y - 2, _gx, ground_y - 16, false);

        // Every few tufts, a flower.
        if (i mod 3 == 0) {
            var _fy = ground_y - 20 - (i mod 2) * 5;
            draw_set_colour((i mod 2 == 0) ? make_colour_rgb(250, 235, 90)
                                           : make_colour_rgb(245, 130, 170));
            draw_circle(_gx, _fy, 5, false);
            draw_set_colour(c_white);
            draw_circle(_gx, _fy, 2, false);
        }
    }
}

// --- Sprinkler --------------------------------------------------------
if (upgrade_owned("sprinkler")) {
    // Base and pipe
    draw_set_colour(make_colour_rgb(70, 74, 86));
    draw_rectangle(sprinkler_x - 12, ground_y - 8, sprinkler_x + 12, ground_y, false);
    draw_rectangle(sprinkler_x - 3, ground_y - 42, sprinkler_x + 3, ground_y - 8, false);
    draw_set_colour(make_colour_rgb(201, 162, 39));
    draw_circle(sprinkler_x, ground_y - 44, 6, false);

    // Water droplets following looping arcs out to both sides.
    draw_set_colour(make_colour_rgb(150, 215, 250));
    for (var d = 0; d < 16; d++) {
        var _side = (d mod 2 == 0) ? 1 : -1;
        var _t    = ((current_time / 900) + d / 16) mod 1;
        var _dx   = _side * _t * 120;
        var _dy   = -36 * sin(_t * pi) + _t * 40;
        draw_circle(sprinkler_x + _dx, ground_y - 44 + _dy, 3, false);
    }
}

draw_set_colour(c_white);
draw_set_alpha(1);
