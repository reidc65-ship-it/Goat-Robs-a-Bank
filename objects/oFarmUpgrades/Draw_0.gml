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

// --- New Fence --------------------------------------------------------
if (upgrade_owned("fence")) {
    var _post = make_colour_rgb(150, 104, 58);
    var _rail = make_colour_rgb(186, 136, 78);

    // Near pasture, up to the barn wall. The fence is behind the player.
    for (var _fx = 60; _fx <= 1020; _fx += 120) {
        draw_set_colour(_post);
        draw_rectangle(_fx - 6, ground_y - 86, _fx + 6, ground_y - 4, false);
        draw_set_colour(_rail);
        draw_rectangle(_fx, ground_y - 68, _fx + 120, ground_y - 54, false);
        draw_rectangle(_fx, ground_y - 38, _fx + 120, ground_y - 24, false);
    }
}

// --- Chicken Coop -----------------------------------------------------
if (upgrade_owned("coop")) {
    var _cx = 200;

    draw_set_colour(make_colour_rgb(150, 68, 52));
    draw_rectangle(_cx - 54, ground_y - 64, _cx + 54, ground_y - 4, false);
    draw_set_colour(make_colour_rgb(96, 42, 34));
    draw_triangle(_cx - 68, ground_y - 62, _cx + 68, ground_y - 62,
                  _cx, ground_y - 104, false);
    draw_set_colour(c_black);
    draw_ellipse(_cx - 14, ground_y - 46, _cx + 14, ground_y - 4, false);

    // Two very satisfied chickens.
    draw_set_colour(c_white);
    draw_circle(_cx + 80, ground_y - 14, 10, false);
    draw_circle(_cx + 62, ground_y - 12, 9, false);
    draw_set_colour(make_colour_rgb(220, 70, 50));
    draw_triangle(_cx + 90, ground_y - 16, _cx + 102, ground_y - 12,
                  _cx + 90, ground_y - 8, false);
}

// --- Fresh Paint ------------------------------------------------------
if (upgrade_owned("paint")) {
    draw_set_colour(make_colour_rgb(246, 236, 210));
    draw_rectangle(1180, 420, 1400, 486, false);
    draw_set_colour(make_colour_rgb(150, 104, 58));
    draw_rectangle(1184, 424, 1396, 482, true);
    draw_set_colour(make_colour_rgb(90, 58, 36));
    draw_set_font(-1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text_transformed(1290, 453, "GOAT FARM", 2.2, 2.2, 0);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

draw_set_colour(c_white);
draw_set_alpha(1);
