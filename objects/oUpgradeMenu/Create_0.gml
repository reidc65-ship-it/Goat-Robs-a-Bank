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
    var _x1 = start_x + _i * (slot_w + slot_gap);
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
