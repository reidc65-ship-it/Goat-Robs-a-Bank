// =====================================================================
//  oUpgradeMenu -> Create
//  Upgrade shop accessed from Elder goat in barn.
//  Goat and farm tabs, progressive unlocks. The upgrade lists and saving
//  live in scrGameState.
// =====================================================================

game_state_init();

// --- Menu State -------------------------------------------------------
is_open       = false;
sel           = 0;
tab           = 0;     // 0 = goat upgrades, 1 = farm upgrades
confirm_timer = 0;     // how long `confirm_text` stays on screen
confirm_text  = "";
confirm_good  = true;

// --- Layout -----------------------------------------------------------
slot_w   = 220;
slot_h   = 280;
slot_gap = 28;
start_x  = 120;
start_y  = 180;

// --- Helpers ----------------------------------------------------------
/// @desc GUI rect for slot _i
slot_rect = function(_i) {
    var _gw = display_get_gui_width();
    var _count = array_length(current_list());

    // Five slots do not fit at the fixed left margin, so centre the row.
    var _x0 = (_count > 4) ? max(24, (_gw - (_count * slot_w + (_count - 1) * slot_gap)) * 0.5)
                           : start_x;
    var _x1 = _x0 + _i * (slot_w + slot_gap);
    return { x1: _x1, y1: start_y, x2: _x1 + slot_w, y2: start_y + slot_h };
};

open_menu = function() {
    is_open = true;
    sel = 0;
    tab = 0;
    confirm_timer = 0;
    global.game_paused = true;
};

close_menu = function() {
    is_open = false;
    global.game_paused = false;
};

/// @desc The upgrades on the current tab.
current_list = function() {
    return (tab == 0) ? global.upgrades : global.farm_upgrades;
};

/// @desc Shows a short message under the slots.
show_confirm = function(_text, _good) {
    confirm_text  = _text;
    confirm_good  = _good;
    confirm_timer = 120;
};

/// @desc Try to purchase selected upgrade
try_buy = function() {
    var _list = current_list();
    var _up = _list[sel];

    if (_up.tier >= 2) { // Already owned
        show_confirm("You already own that.", false);
        return;
    }
    if (_up.tier == 0) { // Locked
        show_confirm("Buy the previous upgrade first.", false);
        return;
    }
    if (global.bank_balance < _up.cost) { // Can't afford
        show_confirm("Not enough money. Rob something.", false);
        return;
    }

    global.bank_balance -= _up.cost;
    _up.tier = 2; // Owned

    // Unlock next upgrade if exists
    if (sel < array_length(_list) - 1) {
        var _next = _list[sel + 1];
        if (_next.tier == 0) _next.tier = 1; // Available
    }

    show_confirm(_up.name + " PURCHASED!", true);
    flag_set("tip_spend");

    // Save
    save_game();
};

/// @desc UI text with shadow + fake bold
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

/// @desc Green card in the space freed by the old goat upgrades. Points
///       players toward the farm tab and shows what is waiting there.
draw_farm_promo = function(_x1, _y1, _x2, _y2) {
    var _green = make_colour_rgb(120, 220, 100);
    var _gold  = make_colour_rgb(242, 208, 107);
    var _cx    = (_x1 + _x2) * 0.5;

    // Shadow, body and border, matching the upgrade slots.
    draw_set_alpha(0.35);
    draw_roundrect_colour_ext(_x1 + 6, _y1 + 8, _x2 + 6, _y2 + 8, 18, 18,
                              c_black, c_black, false);
    draw_set_alpha(1);
    draw_roundrect_colour_ext(_x1, _y1, _x2, _y2, 18, 18,
                              make_colour_rgb(34, 62, 30),
                              make_colour_rgb(18, 34, 16), false);
    draw_set_colour(_green);
    draw_roundrect_ext(_x1, _y1, _x2, _y2, 18, 18, true);

    // Sprout icon, the same primitive drawing used for farm slots.
    draw_set_colour(make_colour_rgb(96, 205, 80));
    draw_rectangle(_cx - 3, _y1 + 40, _cx + 3, _y1 + 76, false);
    draw_circle(_cx - 18, _y1 + 36, 18, false);
    draw_circle(_cx + 18, _y1 + 36, 18, false);

    var _farm = global.farm_upgrades;
    var _count = array_length(_farm);

    draw_ui_text(_cx, _y1 + 108, "FAMILY FARM", 2.0, _green, fa_center, 1);
    draw_ui_text(_cx, _y1 + 140, string(_count) + " UPGRADES", 1.4, c_white, fa_center, 0.9);

    var _row_y = _y1 + 176;
    draw_ui_text(_cx, _row_y, _farm[0].name + "  $" + string(_farm[0].cost),
                 1.2, c_white, fa_center, 0.85);
    draw_ui_text(_cx, _row_y + 22, _farm[1].name + "  $" + string(_farm[1].cost),
                 1.2, c_white, fa_center, 0.85);
    if (_count > 2) {
        draw_ui_text(_cx, _row_y + 44, "AND " + string(_count - 2) + " MORE",
                     1.2, make_colour_rgb(150, 235, 130), fa_center, 0.9);
    }

    draw_ui_text(_cx, _y2 - 26, "PRESS TAB TO VISIT", 1.3, _gold, fa_center, 1);
};
