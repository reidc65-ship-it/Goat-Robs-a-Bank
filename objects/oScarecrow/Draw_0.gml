// =====================================================================
//  oScarecrow -> Draw
// =====================================================================

var _angle = sin(current_time / 900) * 1.5;   // lazy sway in the wind
if (state == "dying") {
    _angle = min(90, state_timer * 5);        // keels over from the base
} else if (wobble > 0) {
    _angle += sin(current_time / 30) * wobble * 0.6;
}

// Ground shadow.
draw_set_alpha(0.22 * image_alpha);
draw_set_colour(c_black);
draw_ellipse(x - 20, y - 4, x + 20, y + 4, false);
draw_set_alpha(1);

draw_sprite_ext(sprite_index, 0, x, y, image_xscale, image_yscale,
                _angle, image_blend, image_alpha);

if (state == "dying") {
    draw_set_colour(c_white);
    exit;
}

draw_set_font(-1);

// Two pips show how many dashes are left.
var _pip_w = 14;
var _pip_h = 7;
var _pip_gap = 4;
var _bar_w = max_hp * _pip_w + (max_hp - 1) * _pip_gap;
var _bx = x - _bar_w * 0.5;
var _by = bbox_top - 34;

for (var _i = 0; _i < max_hp; _i++) {
    var _x0 = _bx + _i * (_pip_w + _pip_gap);
    draw_set_colour(make_colour_rgb(26, 18, 14));
    draw_rectangle(_x0 - 1, _by - 1, _x0 + _pip_w + 1, _by + _pip_h + 1, false);
    draw_set_colour((_i < hp) ? make_colour_rgb(224, 182, 86)
                              : make_colour_rgb(70, 56, 44));
    draw_rectangle(_x0, _by, _x0 + _pip_w, _by + _pip_h, false);
}

gui_text(x, bbox_top - 16, "TRAINING SCARECROW", 1.0, c_white, fa_center, 0.9);

// Dash prompt when the goat is close enough to read it.
if (instance_exists(oPlayer)) {
    var _p = instance_find(oPlayer, 0);
    if (point_distance(x, y, _p.x, _p.y) < 280) {
        var _bob = sin(current_time / 260) * 3;
        gui_text(x, bbox_top - 50 + _bob, "HOLD A / D  +  SHIFT", 1.15,
                 make_colour_rgb(242, 208, 107), fa_center, 1);
    }
}

draw_set_colour(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
