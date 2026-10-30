// =====================================================================
//  scrGameState
//  Shared progress data: bank balance, upgrades, completed heists and
//  the save file. Also a few small helpers used by the HUD and pickups.
// =====================================================================

/// @desc Creates the shared globals and loads the save. Safe to call from
///       any object: only the first call does anything. Rooms launched
///       directly from the Room Editor still get a valid state this way.
function game_state_init() {
    if (variable_global_exists("game_state_ready")) return;
    global.game_state_ready = true;

    if (!variable_global_exists("game_paused"))     global.game_paused = false;
    if (!variable_global_exists("dialogue_active")) global.dialogue_active = false;

    // True while the heist results card owns the screen.
    global.level_complete = false;

    // Set by the Scout so the menu room opens on the job board, not the title.
    global.menu_open_board = false;

    // Contextual tips can be switched off. A setting, so New Game keeps it.
    global.tips_enabled = true;

    game_state_defaults();
    load_game();
}

/// @desc Sets all progress back to a brand new game.
function game_state_defaults() {
    // Tutorial tips seen and story beats reached. Add new ids here to have
    // them saved automatically.
    global.flags = {
        tip_move: false, tip_jump: false, tip_barn: false, tip_spend: false,
        tip_dash: false, tip_cash: false, tip_guards: false, tip_vault: false, tip_escape: false,
        elder_met: false, scout_met: false, family_met: false, bear_met: false
    };

    // --- Progress ---------------------------------------------------------
    global.bank_balance     = 0;
    global.heists_completed = 0;
    global.best_haul        = 0;
    global.jobs_unlocked    = 1;  // how many entries on the job board are open

    // --- Upgrades ---------------------------------------------------------
    // tier: 0 = locked, 1 = available, 2 = owned. Buying one unlocks the next.
    global.upgrades = [
        { id: "dash",       name: "DASH STRIKE",   desc: "Tap SHIFT to dash through enemies.",            cost: 0,    sprite: sUpgradeDash,       tier: 2 }, // Starter - owned
        { id: "horn",       name: "HORN THROW",    desc: "Left click to hurl your horn at range.",        cost: 500,  sprite: sUpgradeHorn,       tier: 1 },
        { id: "doublejump", name: "DOUBLE JUMP",   desc: "Press W in mid-air to jump again.",             cost: 1200, sprite: sUpgradeDoubleJump, tier: 0 },
        { id: "charge",     name: "CHARGE ATTACK", desc: "Hold right click, then release a horn blast.",  cost: 2500, sprite: sUpgradeCharge,     tier: 0 },
        { id: "spirit",     name: "SPIRIT FORM",   desc: "Press Q: guards can't see or hurt you for 3s. Cooldown: 20s.", cost: 5000, sprite: sUpgradeSpirit, tier: 0 }
    ];

    // Farm improvements are drawn by oFarmUpgrades. sprite -1 = drawn icon.
    global.farm_upgrades = [
        { id: "grass",     name: "GREENER GRASS", desc: "Lush grass and flowers for the family farm.", cost: 300, sprite: -1, tier: 1 },
        { id: "sprinkler", name: "SPRINKLER",     desc: "A real sprinkler. The chickens are stunned.", cost: 700, sprite: -1, tier: 0 }
    ];
}

/// @desc New Game: wipes progress and saves over the old file. The menu asks
///       for confirmation before calling this.
function game_new() {
    game_state_defaults();
    save_game();
}

/// @desc True if there is anything worth continuing, or losing to New Game.
function game_has_progress() {
    return global.bank_balance > 0 || global.heists_completed > 0
        || spent_on_goat() > 0 || spent_on_farm() > 0;
}

/// @desc Total money spent on the goat's own gear.
function spent_on_goat() {
    var _total = 0;
    for (var i = 0; i < array_length(global.upgrades); i++) {
        if (global.upgrades[i].tier >= 2) _total += global.upgrades[i].cost;
    }
    return _total;
}

/// @desc Total money spent on the family farm.
function spent_on_farm() {
    var _total = 0;
    for (var i = 0; i < array_length(global.farm_upgrades); i++) {
        if (global.farm_upgrades[i].tier >= 2) _total += global.farm_upgrades[i].cost;
    }
    return _total;
}

/// @desc True once a tutorial tip or story beat has happened.
function flag_get(_id) {
    return global.flags[$ _id] == true;
}

/// @desc Marks a tutorial tip or story beat as done, and saves it.
function flag_set(_id) {
    if (flag_get(_id)) return;
    global.flags[$ _id] = true;
    save_game();
}

/// @desc Writes all progress. Upgrades keep their original [upgrades]
///       section, so saves from before this system still load.
function save_game() {
    ini_open("goat_upgrades.ini");

    ini_write_real("progress", "bank_balance",     global.bank_balance);
    ini_write_real("progress", "heists_completed", global.heists_completed);
    ini_write_real("progress", "best_haul",        global.best_haul);
    ini_write_real("progress", "jobs_unlocked",    global.jobs_unlocked);
    ini_write_real("settings", "tips_enabled",     global.tips_enabled);

    for (var i = 0; i < array_length(global.upgrades); i++) {
        ini_write_real("upgrades", global.upgrades[i].id, global.upgrades[i].tier);
    }
    for (var i = 0; i < array_length(global.farm_upgrades); i++) {
        ini_write_real("farm", global.farm_upgrades[i].id, global.farm_upgrades[i].tier);
    }

    var _flag_ids = variable_struct_get_names(global.flags);
    for (var i = 0; i < array_length(_flag_ids); i++) {
        ini_write_real("flags", _flag_ids[i], global.flags[$ _flag_ids[i]]);
    }

    ini_close();
}

/// @desc Reads the save. Anything missing keeps its default value.
function load_game() {
    ini_open("goat_upgrades.ini");

    global.bank_balance     = max(0, ini_read_real("progress", "bank_balance",     global.bank_balance));
    global.heists_completed = max(0, ini_read_real("progress", "heists_completed", global.heists_completed));
    global.best_haul        = max(0, ini_read_real("progress", "best_haul",        global.best_haul));
    global.jobs_unlocked    = max(1, ini_read_real("progress", "jobs_unlocked",    global.jobs_unlocked));
    global.tips_enabled     = (ini_read_real("settings", "tips_enabled", global.tips_enabled) > 0);

    for (var i = 0; i < array_length(global.upgrades); i++) {
        var _up = global.upgrades[i];
        _up.tier = clamp(ini_read_real("upgrades", _up.id, _up.tier), 0, 2);
    }
    for (var i = 0; i < array_length(global.farm_upgrades); i++) {
        var _farm = global.farm_upgrades[i];
        _farm.tier = clamp(ini_read_real("farm", _farm.id, _farm.tier), 0, 2);
    }

    var _flag_ids = variable_struct_get_names(global.flags);
    for (var i = 0; i < array_length(_flag_ids); i++) {
        global.flags[$ _flag_ids[i]] = (ini_read_real("flags", _flag_ids[i], 0) > 0);
    }

    ini_close();
}

/// @desc True if the goat or farm upgrade with this id has been bought.
function upgrade_owned(_id) {
    for (var i = 0; i < array_length(global.upgrades); i++) {
        if (global.upgrades[i].id == _id) return (global.upgrades[i].tier >= 2);
    }
    for (var i = 0; i < array_length(global.farm_upgrades); i++) {
        if (global.farm_upgrades[i].id == _id) return (global.farm_upgrades[i].tier >= 2);
    }
    return false;
}

/// @desc True while a menu, conversation or results card owns the screen.
function game_is_frozen() {
    return global.game_paused || global.dialogue_active || global.level_complete;
}

/// @desc Formats a frame count as M:SS.
function frames_to_clock(_frames) {
    var _total = ceil(max(_frames, 0) / 60);
    var _mins  = floor(_total / 60);
    var _secs  = _total mod 60;
    return string(_mins) + ":" + ((_secs < 10) ? "0" : "") + string(_secs);
}

/// @desc UI text with a hard shadow and a fake-bold pass, using the
///       built-in font (no font assets required).
function gui_text(_x, _y, _str, _scale, _col, _halign, _alpha) {
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
}
