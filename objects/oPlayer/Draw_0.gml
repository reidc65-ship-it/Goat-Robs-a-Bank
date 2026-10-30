// oPlayer -> Draw Event
// Drawn by hand so the goat can flip and hop without changing its collision
// mask, which could otherwise wedge it against a wall.
var _hop = 0;
if (abs(hsp) > 0.5 && (on_stair != noone || place_meeting(x, y + 1, oWall))) {
    _hop = -abs(sin(current_time / 90)) * 3;
}
draw_sprite_ext(sprite_index, image_index, x, y + _hop,
                image_xscale * facing, image_yscale, image_angle, image_blend, image_alpha);

// Charge Attack meter
if (charge_timer > 0) {
    var _pct = charge_timer / charge_max;
    var _bx = x - 24;
    var _by = bbox_top - 14;

    draw_set_colour(c_black);
    draw_rectangle(_bx - 1, _by - 1, _bx + 49, _by + 7, false);
    draw_set_colour((_pct >= 1) ? make_colour_rgb(242, 208, 107) : c_white);
    draw_rectangle(_bx, _by, _bx + 48 * _pct, _by + 6, false);
    draw_set_colour(c_white);
}

// Short hint over the goat's head
if (hint_timer > 0) {
    draw_set_font(-1);
    gui_text(x, bbox_top - 30, hint_text, 1.2, c_white, fa_center, min(hint_timer / 20, 1));
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
