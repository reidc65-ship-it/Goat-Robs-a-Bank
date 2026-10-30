// =====================================================================
//  oMenu -> Create
//  Title screen, How to Play, settings and the job board. Everything is
//  drawn with sprites and primitives, so there are no extra UI graphics
//  to maintain. The title waits for the player: nothing here moves on to
//  the farm without a menu choice.
// =====================================================================

// Persistent pause/settings controller shared by every level. It is
// dormant while the title screen is active.
if (!instance_exists(oPauseMenu)) {
    instance_create_depth(0, 0, -10000, oPauseMenu);
}

// When launched from the GameMaker IDE on macOS, the runner window can
// start minimised or off-screen, making it look like the game never
// opened. Restore and center it once the title screen starts.
window_restore();
window_center();
window_set_caption("GHOAT");

game_state_init();

if (!variable_global_exists("spawn_x"))          global.spawn_x = -1;
if (!variable_global_exists("spawn_y"))          global.spawn_y = -1;
if (!variable_global_exists("menu_return_room")) global.menu_return_room = rm_barn;
if (!variable_global_exists("menu_return_x"))    global.menu_return_x = 880;
if (!variable_global_exists("menu_return_y"))    global.menu_return_y = 608;

// The Scout opens this room on the job board. Otherwise it's the title.
menu_screen = global.menu_open_board ? "levels" : "title";
global.menu_open_board = false;

// --- Level list -------------------------------------------------------
// The doc calls for around five heist jobs. Only the first is built; the
// rest are greyed-out slots so the progression is visible on the menu.
// A job without a room stays locked even once global.jobs_unlocked reaches
// it, and shows as COMING SOON instead of LOCKED.
levels = [
    { name: "JOB 01  -  THE FIRST HEIST", target_room: Room1, locked: false },
    { name: "JOB 02  -  VAULT WING",      target_room: noone, locked: true  },
    { name: "JOB 03  -  THE GETAWAY",     target_room: noone, locked: true  },
    { name: "JOB 04  -  CITY BANK",       target_room: noone, locked: true  },
    { name: "JOB 05  -  THE LAST SCORE",  target_room: noone, locked: true  }
];

// --- How to Play ------------------------------------------------------
// Keep these matching the real controls in oPlayer and the NPC objects.
howto_rows = [
    { head: "MOVE",   text: "A / D or the LEFT / RIGHT arrow keys walk. W or the UP arrow jumps. Hold to jump higher." },
    { head: "DASH",   text: "SHIFT dashes the way you are moving. Standing still? It dashes toward the mouse." },
    { head: "FIGHT",  text: "A dash hurts guards and smashes doors. Buy HORN THROW, then LEFT CLICK to throw it." },
    { head: "TALK",   text: "Walk up to a character and press E. E, ENTER or SPACE continues. ESC skips." },
    { head: "MONEY",  text: "Grab the bills and gold bars. You only keep the money if you escape!" },
    { head: "GUARDS", text: "Wolves chase you when they see you. Lose all your hearts and you lose the loot." },
    { head: "VAULT",  text: "Follow the yellow arrows down the stairs. Smash the vault door and grab the sack." },
    { head: "ESCAPE", text: "Run to the sewer hatch before the timer hits zero. Out of time? The loot is gone." },
    { head: "SPEND",  text: "Talk to the ELDER in the barn. Buy goat gear, or press TAB to fix up the farm." }
];

// --- Simple button lists ----------------------------------------------
settings_rows = ["volume", "fullscreen", "fps", "tips", "back"];
confirm_items = ["NO, GO BACK", "YES, START OVER"];

/// @desc The title menu depends on whether there is a game to continue.
build_title_items = function() {
    if (game_has_progress()) {
        title_items = [
            { label: "CONTINUE",    action: "continue" },
            { label: "NEW GAME",    action: "new" },
            { label: "HOW TO PLAY", action: "howto" },
            { label: "SETTINGS",    action: "settings" },
            { label: "QUIT",        action: "quit" }
        ];
    } else {
        title_items = [
            { label: "START GAME",  action: "continue" },
            { label: "HOW TO PLAY", action: "howto" },
            { label: "SETTINGS",    action: "settings" },
            { label: "QUIT",        action: "quit" }
        ];
    }
};
build_title_items();

sel          = 0;
denied_timer = 0;     // shake feedback when a locked level is chosen
denied_index = -1;    // which button is shaking

// --- Fade transition --------------------------------------------------
fade         = 0;     // 0 = clear, 1 = black
fade_dir     = 0;     // 0 idle, 1 fading out, -1 fading in
next_screen  = "";    // screen to reveal after fading out
pending_room = noone; // room to enter after fading out

// Last mouse position, so keyboard navigation is not overridden by a
// stationary cursor sitting on top of a button.
mx_prev = -1;
my_prev = -1;

/// @desc How many selectable buttons the current screen has.
item_count = function() {
    switch (menu_screen) {
        case "title":    return array_length(title_items);
        case "settings": return array_length(settings_rows);
        case "confirm":  return array_length(confirm_items);
        case "levels":   return array_length(levels);
    }
    return 1; // How to Play has a single Back button.
};

/// @desc Returns the GUI-space rectangle for button _i on this screen.
button_rect = function(_i) {
    var _gw = display_get_gui_width();
    var _w  = 620;
    var _h  = 66;
    var _gap = 14;
    var _y0 = 300;
    var _x1 = (_gw - _w) * 0.5;

    switch (menu_screen) {
        case "title":
            // The left side of the splash art; the vault door fills the right.
            _x1 = 70;
            _w  = 520;
            _h  = 62;
            _y0 = 300;
            break;
        case "settings":
            _y0 = 210;
            break;
        case "confirm":
            _y0 = 390;
            break;
        case "howto":
            _w  = 260;
            _h  = 54;
            _y0 = 686;
            _x1 = (_gw - _w) * 0.5;
            break;
    }

    var _y1 = _y0 + _i * (_h + _gap);
    return { x1: _x1, y1: _y1, x2: _x1 + _w, y2: _y1 + _h };
};

/// @desc Fades to black, then switches to _screen or _room.
begin_fade = function(_screen, _room) {
    next_screen  = _screen;
    pending_room = _room;
    fade_dir     = 1;
};

/// @desc Runs the selected button on the title screen.
activate_title = function() {
    switch (title_items[sel].action) {
        case "continue": begin_fade("farm", noone);     break;
        case "new":      begin_fade("confirm", noone);  break;
        case "howto":    begin_fade("howto", noone);    break;
        case "settings": begin_fade("settings", noone); break;
        case "quit":     game_end();                    break;
    }
};

/// @desc Left / right on a settings row. _dir is -1 or 1.
adjust_setting = function(_dir) {
    var _pause = instance_find(oPauseMenu, 0);

    switch (settings_rows[sel]) {
        case "volume":
            _pause.set_volume(global.settings.master_volume + _dir * 0.05);
            break;
        case "fullscreen":
            global.settings.fullscreen = (_dir > 0);
            window_set_fullscreen(global.settings.fullscreen);
            break;
        case "fps":
            global.settings.show_fps = (_dir > 0);
            break;
        case "tips":
            global.tips_enabled = (_dir > 0);
            break;
    }
};

/// @desc Enter or click on a settings row.
toggle_setting = function() {
    switch (settings_rows[sel]) {
        case "fullscreen": adjust_setting(global.settings.fullscreen ? -1 : 1); break;
        case "fps":        adjust_setting(global.settings.show_fps ? -1 : 1);   break;
        case "tips":       adjust_setting(global.tips_enabled ? -1 : 1);        break;
        case "back":       leave_settings(); break;
    }
};

leave_settings = function() {
    var _pause = instance_find(oPauseMenu, 0);
    _pause.save_settings();
    save_game();
    begin_fade("title", noone);
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

/// @desc Draws one menu button, with `_label` on the left and `_tag` on the right.
draw_menu_button = function(_i, _label, _tag, _locked) {
    var _r      = button_rect(_i);
    var _hover  = (_i == sel);
    var _cy     = (_r.y1 + _r.y2) * 0.5;

    // Shake feedback when a locked level is chosen
    var _shake = 0;
    if (_i == denied_index && denied_timer > 0) {
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
    }
    if (_hover && !_locked) {
        _c1     = make_colour_rgb(94, 76, 24);
        _c2     = make_colour_rgb(62, 50, 16);
        _border = make_colour_rgb(255, 225, 130);
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

    // Selection arrow (also on locked jobs, so the cursor is never lost)
    if (_hover) {
        draw_set_colour(_locked ? make_colour_rgb(120, 130, 145) : make_colour_rgb(255, 225, 130));
        draw_triangle(_x1 + 18, _cy - 10, _x1 + 18, _cy + 10,
                      _x1 + 30, _cy, false);
    }

    var _name_col = _locked ? make_colour_rgb(120, 130, 145) : c_white;
    var _tag_col  = _locked ? make_colour_rgb(120, 130, 145)
                            : make_colour_rgb(242, 208, 107);

    draw_ui_text(_x1 + 44, _cy, _label, 2, _name_col, fa_left, 1);
    if (_tag != "") {
        draw_ui_text(_x2 - 32, _cy, _tag, 1.5, _tag_col, fa_right, 1);
    }
};

/// @desc Draws the game's title centred on _cx.
draw_game_title = function(_cx, _y, _scale) {
    var _gold       = make_colour_rgb(201, 162, 39);
    var _gold_light = make_colour_rgb(255, 225, 130);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_set_colour(c_black);
    draw_text_transformed(_cx + _scale, _y + _scale, "GHOAT", _scale, _scale, 0);
    draw_set_colour(_gold);
    draw_text_transformed(_cx, _y, "GHOAT", _scale, _scale, 0);
    draw_set_colour(_gold_light);
    draw_text_transformed(_cx - 1, _y - 2, "GHOAT", _scale, _scale, 0);
    draw_set_alpha(1);

    draw_ui_text(_cx, _y + _scale * 13, "GREATEST HEIST OF ALL TIME",
                 max(1.2, _scale * 0.26), c_white, fa_center, 0.95);
};
