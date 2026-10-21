// =====================================================================
//  oPauseMenu -> Create
//  Persistent pause / settings controller. Opened with Escape in any
//  gameplay room, so it does not need to be placed in every level.
//  Settings are saved to goat_settings.ini (kept separate from the
//  runner's own settings.ini, which lives in the same save folder).
// =====================================================================

// --- Globals ----------------------------------------------------------
// The dialogue system may already have created these when a level is
// launched directly from the Room Editor, so only seed them if missing.
if (!variable_global_exists("game_paused"))     global.game_paused = false;
if (!variable_global_exists("dialogue_active")) global.dialogue_active = false;

global.settings = {
    master_volume: 1,
    fullscreen:    window_get_fullscreen(),
    show_fps:      false
};

// --- Menu state -------------------------------------------------------
is_open       = false;
sel           = 0;
row_count     = 6;
dragging_vol  = false;
unpause_timer = 0;

// --- Layout -----------------------------------------------------------
panel_w = 760;
panel_h = 652;
panel_y = 48;
row_y0  = 200;
row_h   = 60;
row_gap = 14;
row_w   = 640;

mx_prev = -1;
my_prev = -1;

// --- Helpers ----------------------------------------------------------
/// @desc GUI-space rectangle for row _i.
row_rect = function(_i) {
    var _gw = display_get_gui_width();
    var _x1 = (_gw - row_w) * 0.5;
    var _y1 = row_y0 + _i * (row_h + row_gap);
    return { x1: _x1, y1: _y1, x2: _x1 + row_w, y2: _y1 + row_h };
};

/// @desc GUI-space rectangle for the master volume slider.
volume_rect = function() {
    var _r  = row_rect(0);
    var _cy = (_r.y1 + _r.y2) * 0.5;
    return {
        x1: _r.x1 + 330,
        y1: _cy - 6,
        x2: _r.x2 - 120,
        y2: _cy + 6
    };
};

set_volume = function(_v) {
    global.settings.master_volume = clamp(_v, 0, 1);
    audio_master_gain(global.settings.master_volume);
};

apply_settings = function() {
    audio_master_gain(global.settings.master_volume);
    window_set_fullscreen(global.settings.fullscreen);
};

load_settings = function() {
    ini_open("goat_settings.ini");
    global.settings.master_volume = clamp(ini_read_real("audio", "master", 1), 0, 1);
    global.settings.fullscreen =
        (ini_read_real("video", "fullscreen", window_get_fullscreen() ? 1 : 0) > 0);
    global.settings.show_fps =
        (ini_read_real("video", "show_fps", 0) > 0);
    ini_close();
};

save_settings = function() {
    ini_open("goat_settings.ini");
    ini_write_real("audio", "master", global.settings.master_volume);
    ini_write_real("video", "fullscreen", global.settings.fullscreen);
    ini_write_real("video", "show_fps", global.settings.show_fps);
    ini_close();
};

open_menu = function() {
    is_open       = true;
    sel           = 0;
    dragging_vol  = false;
    unpause_timer = 0;

    // Don't let a parked cursor steal the selection on the first frame.
    mx_prev = device_mouse_x_to_gui(0);
    my_prev = device_mouse_y_to_gui(0);

    global.game_paused = true;
};

close_menu = function() {
    save_settings();
    is_open       = false;
    dragging_vol  = false;

    // Unpause on the next frame, so the click / Escape that closed the
    // menu can't also fire a shot or jump on the same frame.
    unpause_timer = 1;
};

toggle_fullscreen = function() {
    global.settings.fullscreen = !global.settings.fullscreen;
    window_set_fullscreen(global.settings.fullscreen);
};

quit_to_title = function() {
    save_settings();
    is_open = false;
    global.game_paused = false;
    room_goto(rm_menu);
};

restart_level = function() {
    save_settings();
    is_open = false;
    global.game_paused = false;
    room_restart();
};

/// @desc UI text with a hard shadow and a fake-bold pass, using the
///       built-in font (no font assets required).
draw_ui_text = function(_x, _y, _str, _scale, _col, _halign, _alpha) {
    draw_set_halign(_halign);
    draw_set_valign(fa_middle);

    draw_set_colour(c_black);
    draw_set_alpha(_alpha * 0.68);
    draw_text_transformed(_x + 2, _y + 2, _str, _scale, _scale, 0);

    draw_set_colour(_col);
    draw_set_alpha(_alpha);
    draw_text_transformed(_x, _y, _str, _scale, _scale, 0);
    draw_text_transformed(_x + max(1, _scale * 0.5), _y, _str, _scale, _scale, 0);

    draw_set_alpha(1);
};

// --- Load and apply saved settings ------------------------------------
load_settings();
apply_settings();
