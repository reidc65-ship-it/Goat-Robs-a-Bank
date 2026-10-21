// =====================================================================
//  oUpgradeMenu -> Create
//  Upgrade shop accessed from Elder goat in barn.
//  5 slots, progressive unlocks. Persists across runs.
// =====================================================================

if (!variable_global_exists("game_paused"))     global.game_paused = false;
if (!variable_global_exists("dialogue_active")) global.dialogue_active = false;

// --- Upgrade Data -----------------------------------------------------
// Each upgrade: id, name, desc, cost, sprite, unlocked, tier (0=locked, 1=available, 2=owned)
global.upgrades = global.upgrades ?? [
    { id: "dash",        name: "DASH STRIKE",      desc: "Tap SHIFT to dash through enemies.",       cost: 0,   sprite: sUpgradeDash,       tier: 2 }, // Starter - owned
    { id: "horn",        name: "HORN THROW",       desc: "Press X to hurl your horn at range.",      cost: 500, sprite: sUpgradeHorn,       tier: 1 }, // Available
    { id: "doublejump",  name: "DOUBLE JUMP",      desc: "Jump again in mid-air to reach new heights.", cost: 1200, sprite: sUpgradeDoubleJump, tier: 0 }, // Locked
    { id: "charge",      name: "CHARGE ATTACK",    desc: "Hold X to charge a devastating horn blast.", cost: 2500, sprite: sUpgradeCharge,     tier: 0 }, // Locked
    { id: "spirit",      name: "SPIRIT FORM",      desc: "Become intangible for 3 seconds. Cooldown: 20s.", cost: 5000, sprite: sUpgradeSpirit,    tier: 0 }  // Locked
];

// --- Menu State -------------------------------------------------------
is_open       = false;
sel           = 0;
max_sel       = 4;
confirm_timer = 0;

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
    confirm_timer = 0;
    global.game_paused = true;
};

close_menu = function() {
    is_open = false;
    global.game_paused = false;
};

/// @desc Try to purchase selected upgrade
try_buy = function() {
    var _up = global.upgrades[sel];
    if (_up.tier >= 2) return; // Already owned
    if (_up.tier == 0) return; // Locked
    if (global.bank_balance < _up.cost) return; // Can't afford

    global.bank_balance -= _up.cost;
    _up.tier = 2; // Owned

    // Unlock next upgrade if exists
    if (sel < max_sel) {
        var _next = global.upgrades[sel + 1];
        if (_next.tier == 0) _next.tier = 1; // Available
    }

    // Save
    save_upgrades();
};

save_upgrades = function() {
    ini_open("goat_upgrades.ini");
    for (var i = 0; i <= max_sel; i++) {
        ini_write_real("upgrades", global.upgrades[i].id, global.upgrades[i].tier);
    }
    ini_close();
};

load_upgrades = function() {
    ini_open("goat_upgrades.ini");
    for (var i = 0; i <= max_sel; i++) {
        var _tier = ini_read_real("upgrades", global.upgrades[i].id, global.upgrades[i].tier);
        global.upgrades[i].tier = _tier;
    }
    ini_close();
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

// --- Load on create ---------------------------------------------------
load_upgrades();