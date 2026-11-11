// =====================================================================
//  oHeistExit -> Draw
// =====================================================================

var _open = false;
if (instance_exists(oHeist)) {
    var _heist = instance_find(oHeist, 0);
    _open = _heist.vault_looted;
}

var _x1 = x - 56;
var _x2 = x + 56;
var _y1 = y - 48;
var _y2 = y + 48;

// Pipe mouth
draw_set_colour(make_colour_rgb(66, 70, 82));
draw_rectangle(_x1 - 8, _y1 - 8, _x2 + 8, _y2, false);
draw_set_colour(make_colour_rgb(8, 10, 14));
draw_rectangle(_x1, _y1, _x2, _y2, false);

draw_set_font(-1);

if (_open) {
    // Pulsing arrow, pointing into the open pipe.
    var _pulse = 0.6 + 0.4 * sin(current_time / 140);
    draw_set_alpha(_pulse);
    draw_set_colour(make_colour_rgb(110, 230, 120));
    draw_triangle(x + 30, y - 26, x + 30, y + 26, x - 26, y, false);
    draw_set_alpha(1);

    gui_text(x, _y1 - 28, "ESCAPE!", 1.6, make_colour_rgb(110, 230, 120), fa_center, 1);
} else {
    // Locked grate.
    draw_set_colour(make_colour_rgb(96, 100, 112));
    for (var i = 0; i < 6; i++) {
        var _bx = _x1 + 8 + i * 19;
        draw_rectangle(_bx, _y1, _bx + 5, _y2, false);
    }
    draw_rectangle(_x1, y - 3, _x2, y + 3, false);

    gui_text(x, _y1 - 28, "SEWER HATCH", 1.2, make_colour_rgb(198, 192, 170), fa_center, 0.9);
}

draw_set_colour(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
