// =====================================================================
//  oHeist -> Create
//  Runs one bank job: timer, loot for this run, objective, success and
//  failure, and the results card. Place one in each heist room. Because
//  it is not persistent, restarting or quitting the level throws away the
//  loot, which is only added to the bank in finish_heist().
// =====================================================================

game_state_init();
global.level_complete = false;

state        = "active";   // "active", "won" or "failed"
time_limit   = 150 * 60;   // 2:30, in frames
time_left    = time_limit;
loot         = 0;
vault_looted = false;

// Results card
card_title = "";
card_line  = "";
card_news  = "";
card_timer = 0;

// --- Escalating security ----------------------------------------------
// Bear buys more wolves after every successful job. Job 01 played for the
// first time has none of this. Guards in the room already exist here,
// because this object comes after them in the room's creation order.
security_level = min(global.heists_completed, 3);
if (security_level >= 1) instance_create_depth(1550, 1952, 110, oWolfCop);
if (security_level >= 2) instance_create_depth(1600, 3232, 110, oWolfCop);
if (security_level >= 3) instance_create_depth(450, 2592, 110, oWolfCop);

var _level = security_level;
with (oWolfCop) {
    sight_range += 30 * _level;
    chase_speed += 0.2 * _level;
}

// Floating world-space text such as "+$50".
popups = [];

/// @desc Adds floating text at a world position.
add_popup = function(_text, _x, _y, _col) {
    array_push(popups, { text: _text, x: _x, y: _y, col: _col, life: 60 });
};

/// @desc Adds money to this run's loot.
add_loot = function(_amount, _x, _y) {
    if (state != "active") return;
    loot += _amount;
    flag_set("tip_cash");
    add_popup("+$" + string(_amount), _x, _y - 30, make_colour_rgb(242, 208, 107));
};

/// @desc The vault has been robbed: open the exit and send in backup.
on_vault_looted = function() {
    if (vault_looted) return;
    vault_looted = true;

    // Guards the antechamber, between the vault stairs and the sewer hatch.
    var _backup = instance_create_depth(350, 2592, 110, oWolfCop);
    _backup.alert_level = 2;
    _backup.alert_timer = 120;

    // Bear turns up to gloat. The conversation pauses the heist clock.
    var _bear = instance_create_depth(1480, 3264, 115, oBearNPC);
    _bear.start_conversation();
};

/// @desc Successful escape. The only place stolen money reaches the bank.
finish_heist = function() {
    if (state != "active" || !vault_looted) return;
    state = "won";

    global.bank_balance     += loot;
    global.heists_completed += 1;
    global.best_haul         = max(global.best_haul, loot);
    global.jobs_unlocked     = max(global.jobs_unlocked, 2);
    save_game();

    card_title = "CLEAN GETAWAY!";
    card_line  = "The sewer smells awful. The money smells great.";
    card_news  = (global.heists_completed == 1)
               ? "THE DAILY BLEAT: GOAT ROBS BEAR'S BANK. \"MORE WOLVES!\" VOWS OWNER."
               : "THE DAILY BLEAT: STILL NO LEADS ON GOAT. BEAR BUYS EVEN MORE WOLVES.";
    global.level_complete = true;
};

/// @desc Caught or out of time. This run's loot is lost.
fail_heist = function(_title, _line) {
    if (state != "active") return;
    state = "failed";

    card_title = _title;
    card_line  = _line;
    global.level_complete = true;
};

return_to_farm = function() {
    global.level_complete = false;
    global.spawn_x = -1;
    global.spawn_y = -1;
    room_goto(rm_farm);
};

/// @desc The current objective, based on how far the player has got.
get_objective = function(_player) {
    if (vault_looted)                return "ALARM! Run up the stairs to the sewer hatch!";
    if (instance_exists(oSkylight))  return "Break in: stand on the glass, point the mouse DOWN, tap SHIFT";
    if (_player.y > 2700)            return "Smash the vault door and grab the loot!";
    return "Follow the stairs down to the vault";
};
