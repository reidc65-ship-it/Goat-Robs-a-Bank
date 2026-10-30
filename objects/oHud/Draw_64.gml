// =====================================================================
//  oHud -> Draw GUI
//  Health and money. oPlayer creates this, so every room with a player
//  gets a HUD. Drawn in GUI space, so camera movement doesn't affect it.
// =====================================================================

if (global.dialogue_active || global.level_complete) exit;
if (!instance_exists(oPlayer)) exit;

// The upgrade shop shows the balance itself.
if (instance_exists(oUpgradeMenu)) {
    var _shop = instance_find(oUpgradeMenu, 0);
    if (_shop.is_open) exit;
}

var _p  = instance_find(oPlayer, 0);
var _gw = display_get_gui_width();

var _gold_light = make_colour_rgb(242, 208, 107);
var _red        = make_colour_rgb(226, 62, 62);

draw_set_font(-1);

// --- Hearts (top left, below the optional FPS counter) ----------------
for (var i = 0; i < _p.max_hp; i++) {
    var _hx = 40 + i * 42;
    var _hy = 50;

    draw_set_colour(c_black);
    draw_circle(_hx - 8, _hy - 5, 12, false);
    draw_circle(_hx + 8, _hy - 5, 12, false);
    draw_triangle(_hx - 19, _hy, _hx + 19, _hy, _hx, _hy + 21, false);

    draw_set_colour((i < _p.hp) ? _red : make_colour_rgb(62, 62, 70));
    draw_circle(_hx - 8, _hy - 5, 9, false);
    draw_circle(_hx + 8, _hy - 5, 9, false);
    draw_triangle(_hx - 16, _hy - 1, _hx + 16, _hy - 1, _hx, _hy + 17, false);
}

// --- Spirit Form status -----------------------------------------------
if (upgrade_owned("spirit")) {
    var _spirit_text = "Q  SPIRIT READY";
    var _spirit_col  = make_colour_rgb(150, 220, 255);
    if (_p.spirit_timer > 0) {
        _spirit_text = "SPIRIT FORM  " + frames_to_clock(_p.spirit_timer);
    } else if (_p.spirit_cooldown_timer > 0) {
        _spirit_text = "SPIRIT  " + frames_to_clock(_p.spirit_cooldown_timer);
        _spirit_col  = make_colour_rgb(150, 160, 175);
    }
    gui_text(24, 88, _spirit_text, 1.1, _spirit_col, fa_left, 0.9);
}

// --- Money and timer --------------------------------------------------
if (instance_exists(oHeist)) {
    var _heist = instance_find(oHeist, 0);

    gui_text(_gw - 24, 34, "LOOT  $" + string(_heist.loot), 2.1, _gold_light, fa_right, 1);
    gui_text(_gw - 24, 68, "BANK  $" + string(global.bank_balance), 1.1, c_white, fa_right, 0.7);

    // The clock turns red and pulses for the last 30 seconds.
    var _urgent = (_heist.time_left <= 30 * 60);
    var _alpha  = _urgent ? (0.7 + 0.3 * sin(current_time / 120)) : 1;
    gui_text(_gw * 0.5, 34, frames_to_clock(_heist.time_left), 2.6,
             _urgent ? _red : c_white, fa_center, _alpha);

    gui_text(_gw * 0.5, 72, _heist.get_objective(_p), 1.15, c_white, fa_center, 0.9);

    // Alert warning, if any guard is currently chasing the goat.
    var _chased = false;
    with (oWolfCop) {
        if (state == "chase" || state == "attack") _chased = true;
    }
    if (_chased) {
        gui_text(_gw * 0.5, 100, "SPOTTED!", 1.5, _red, fa_center,
                 0.7 + 0.3 * sin(current_time / 100));
    }
} else {
    gui_text(_gw - 24, 34, "BANK  $" + string(global.bank_balance), 1.8, _gold_light, fa_right, 1);
}

// --- Tutorial tip (bottom of the screen, out of the way) ---------------
if (tip_text != "") {
    var _gh = display_get_gui_height();
    var _tip_w = string_width(tip_text) * 1.35 * 0.5 + 170;

    draw_set_alpha(0.78);
    draw_set_colour(make_colour_rgb(10, 14, 22));
    draw_roundrect_ext(_gw * 0.5 - _tip_w, _gh - 62, _gw * 0.5 + _tip_w, _gh - 18, 12, 12, false);
    draw_set_alpha(1);
    draw_set_colour(make_colour_rgb(201, 162, 39));
    draw_roundrect_ext(_gw * 0.5 - _tip_w, _gh - 62, _gw * 0.5 + _tip_w, _gh - 18, 12, 12, true);

    gui_text(_gw * 0.5 - 60, _gh - 40, tip_text, 1.35, c_white, fa_center, 1);
    gui_text(_gw * 0.5 + _tip_w - 16, _gh - 40, "H  HIDE TIPS", 1, _gold_light, fa_right, 0.75);
}

// --- Fade in when a room starts ---------------------------------------
if (room_fade > 0) {
    draw_set_alpha(room_fade);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, _gw, display_get_gui_height(), false);
}

draw_set_colour(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
