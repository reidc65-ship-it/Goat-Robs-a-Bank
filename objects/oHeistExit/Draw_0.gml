// =====================================================================
//  oHeistExit -> Draw
// =====================================================================

var _open = false;
if (instance_exists(oHeist)) {
    var _heist = instance_find(oHeist, 0);
    _open = _heist.vault_looted;
}

draw_set_colour(c_white);
draw_set_alpha(1);

// Frame 0 is the locked grate, frame 1 is the open hatch.
draw_sprite(sprite_index, _open ? 1 : 0, x, y - 4);

draw_set_font(-1);

if (_open) {
    // Pulsing arrow pointing into the open pipe.
    var _pulse = 0.6 + 0.4 * sin(current_time / 140);
    draw_set_alpha(_pulse);
    draw_sprite(sExitArrow, 0, x + 2, y);
    draw_set_alpha(1);

    gui_text(x, y - 76, "ESCAPE!", 1.6, make_colour_rgb(110, 230, 120), fa_center, 1);
} else {
    gui_text(x, y - 76, "SEWER HATCH", 1.2, make_colour_rgb(198, 192, 170), fa_center, 0.9);
}

draw_set_colour(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
