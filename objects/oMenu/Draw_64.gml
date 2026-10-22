// =====================================================================
//  oMenu -> Draw GUI
// =====================================================================

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

draw_set_font(-1);
draw_set_alpha(1);

if (menu_screen == "splash") {
    draw_sprite_stretched(sMenuSplash, 0, 0, 0, _gw, _gh);
    draw_sprite_ext(sLogo, 0, _gw * 0.5, 271, 1, 1, 0, c_white, 1);

    // Pulsing prompt
    var _pulse = 0.55 + 0.45 * sin(current_time / 260);
    draw_ui_text(_gw * 0.5, 575, "PRESS ANY KEY", 2.6, c_white, fa_center, _pulse);
    draw_ui_text(_gw * 0.5, 680, "CLICK OR PRESS ANY KEY TO CONTINUE",
                 1.2, c_white, fa_center, 0.55);

    if (global.bank_balance > 0) {
        draw_ui_text(_gw * 0.5, 630, "BANKED  $" + string(global.bank_balance),
                     1.4, make_colour_rgb(242, 208, 107), fa_center, 0.9);
    }
} else {
    draw_sprite_stretched(sMenuLevels, 0, 0, 0, _gw, _gh);
    draw_sprite_ext(sLogo, 0, _gw * 0.5, 105, 0.5, 0.5, 0, c_white, 1);

    draw_ui_text(_gw * 0.5, 206, "SELECT A JOB", 3.4,
                 make_colour_rgb(242, 208, 107), fa_center, 1);

    draw_ui_text(_gw * 0.5, 170, "BANKED  $" + string(global.bank_balance),
                 1.15, make_colour_rgb(201, 162, 39), fa_center, 0.9);

    // Divider
    draw_set_colour(make_colour_rgb(201, 162, 39));
    draw_set_alpha(0.55);
    draw_rectangle(_gw * 0.5 - 240, 254, _gw * 0.5 + 240, 256, false);
    draw_set_alpha(1);

    var _count = array_length(levels);

    for (var i = 0; i < _count; i++) {
        var _lv     = levels[i];
        var _r      = button_rect(i);
        var _hover  = (i == sel);
        var _locked = _lv.locked;
        var _cy     = (_r.y1 + _r.y2) * 0.5;

        // Shake feedback when a locked level is chosen
        var _shake = 0;
        if (i == denied_index && denied_timer > 0) {
            _shake = sin(denied_timer * 2.2) * 10 * (denied_timer / 24);
        }

        var _x1 = _r.x1 + _shake;
        var _x2 = _r.x2 + _shake;

        var _c1     = make_colour_rgb(30, 38, 51);
        var _c2     = make_colour_rgb(20, 26, 36);
        var _border = make_colour_rgb(201, 162, 39);

        if (_locked) {
            _c1     = make_colour_rgb(35, 41, 52);
            _c2     = make_colour_rgb(24, 29, 38);
            _border = make_colour_rgb(74, 84, 100);
        } else if (_hover) {
            _c1     = make_colour_rgb(58, 48, 20);
            _c2     = make_colour_rgb(38, 31, 12);
            _border = make_colour_rgb(242, 208, 107);
        }

        // Drop shadow
        draw_set_alpha(0.35);
        draw_set_colour(c_black);
        draw_roundrect_colour_ext(_x1 + 5, _r.y1 + 6, _x2 + 5, _r.y2 + 6,
                                  14, 14, c_black, c_black, false);
        draw_set_alpha(1);

        // Body + border
        draw_roundrect_colour_ext(_x1, _r.y1, _x2, _r.y2, 14, 14, _c1, _c2, false);
        draw_set_colour(_border);
        draw_roundrect_ext(_x1, _r.y1, _x2, _r.y2, 14, 14, true);

        draw_set_alpha(0.3);
        draw_roundrect_ext(_x1 + 5, _r.y1 + 5, _x2 - 5, _r.y2 - 5, 10, 10, true);
        draw_set_alpha(1);

        // Selection arrow
        if (_hover && !_locked) {
            draw_set_colour(make_colour_rgb(242, 208, 107));
            draw_triangle(_x1 + 18, _cy - 10, _x1 + 18, _cy + 10,
                          _x1 + 30, _cy, false);
        }

        var _name_col = _locked ? make_colour_rgb(120, 130, 145) : c_white;
        var _tag_col  = _locked ? make_colour_rgb(120, 130, 145)
                                : make_colour_rgb(242, 208, 107);

        draw_ui_text(_x1 + 40, _cy, _lv.name, 2, _name_col, fa_left, 1);
        draw_ui_text(_x2 - 40, _cy, _locked ? "LOCKED" : "PLAY", 1.5,
                     _tag_col, fa_right, 1);
    }

    draw_ui_text(_gw * 0.5, 740,
                 "W / S OR ARROWS TO SELECT     ENTER TO START     ESC TO BACK",
                 1.2, c_white, fa_center, 0.65);
}

// Fade overlay
if (fade > 0) {
    draw_set_alpha(fade);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);
}
