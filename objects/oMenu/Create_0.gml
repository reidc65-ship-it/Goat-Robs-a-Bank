// =====================================================================
//  oMenu -> Create
//  Splash + level select. Everything is drawn with sprites and
//  primitives, so there are no extra UI graphics to maintain.
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

if (!variable_global_exists("bank_balance")) global.bank_balance = 0;

menu_screen = "levels"; // "levels" only - splash removed, farm is entry point

// --- Level list -------------------------------------------------------
// The doc calls for around five heist jobs. Only the first is built; the
// rest are greyed-out slots so the progression is visible on the menu.
levels = [
    { name: "JOB 01  -  THE FIRST HEIST", target_room: Room1, locked: false },
    { name: "JOB 02  -  VAULT WING",      target_room: noone, locked: true  },
    { name: "JOB 03  -  THE GETAWAY",     target_room: noone, locked: true  },
    { name: "JOB 04  -  CITY BANK",       target_room: noone, locked: true  },
    { name: "JOB 05  -  THE LAST SCORE",  target_room: noone, locked: true  }
];

sel          = 0;
denied_timer = 0;     // shake feedback when a locked level is chosen
denied_index = -1;    // which button is shaking

// --- Fade transition --------------------------------------------------
fade         = 0;     // 0 = clear, 1 = black
fade_dir     = 0;     // 0 idle, 1 fading out, -1 fading in
next_screen  = "";    // screen to reveal after fading out
pending_room = noone; // room to enter after fading out

// --- Layout -----------------------------------------------------------
btn_w   = 620;
btn_h   = 66;
btn_gap = 14;
btn_y0  = 300;

// Last mouse position, so keyboard navigation is not overridden by a
// stationary cursor sitting on top of a button.
mx_prev = -1;
my_prev = -1;

/// @desc Returns the GUI-space rectangle for level button _i.
button_rect = function(_i) {
    var _gw = display_get_gui_width();
    var _x1 = (_gw - btn_w) * 0.5;
    var _y1 = btn_y0 + _i * (btn_h + btn_gap);
    return { x1: _x1, y1: _y1, x2: _x1 + btn_w, y2: _y1 + btn_h };
};

/// @desc Fades to black, then switches to _screen or _room.
begin_fade = function(_screen, _room) {
    next_screen  = _screen;
    pending_room = _room;
    fade_dir     = 1;
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
