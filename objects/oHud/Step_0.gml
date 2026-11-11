// =====================================================================
//  oHud -> Step
//  Picks the one tutorial tip to show. Tips only ever draw text: they
//  never pause the game or stop the heist clock, and each one is saved as
//  done once the player has done what it asks. Add new flag ids to
//  game_state_defaults() in scrGameState.
// =====================================================================

room_fade = max(room_fade - 0.05, 0);

if (game_is_frozen() || !instance_exists(oPlayer)) exit;

var _p = instance_find(oPlayer, 0);
if (start_x < 0) start_x = _p.x;

// These count as done even with tips off, so that switching tips on later
// doesn't ask for things the player has already done.
if (abs(_p.x - start_x) > 100) flag_set("tip_move");

var _id    = "";
var _text  = "";
var _timed = false;   // for tips with no clear action: clear after a while

if (room == rm_farm) {
    if (!flag_get("tip_move")) {
        _id = "tip_move"; _text = "Walk with A / D or the LEFT / RIGHT arrow keys";
    } else if (!flag_get("tip_jump")) {
        _id = "tip_jump"; _text = "Press W or the UP arrow to jump";
    } else if (!flag_get("tip_barn")) {
        _id = "tip_barn"; _text = "Follow the yellow arrow right and walk into the barn door";
    } else if (global.heists_completed > 0 && !flag_get("family_met")) {
        _id = "family_met"; _text = "Mama Goat wants a word: stand close and press E";
    }
} else if (room == rm_barn) {
    flag_set("tip_barn");

    if (!flag_get("elder_met")) {
        _id = "elder_met"; _text = "The ELDER sells upgrades: stand close and press E";
    } else if (!flag_get("scout_met")) {
        _id = "scout_met"; _text = "The SCOUT runs the job board: stand close and press E";
    } else if (global.bank_balance > 0 && !flag_get("tip_spend")) {
        _id = "tip_spend"; _text = "Got cash? The ELDER sells goat gear. Press TAB in the shop for farm upgrades";
    }
} else if (instance_exists(oHeist)) {
    var _heist = instance_find(oHeist, 0);

    var _chased = false;
    with (oWolfCop) {
        if (state == "chase" || state == "attack") _chased = true;
    }

    if (_heist.vault_looted && !flag_get("tip_escape")) {
        _id = "tip_escape"; _text = "Got it! Follow the arrows up one flight to the sewer hatch"; _timed = true;
    } else if (_p.y > 2700 && !_heist.vault_looted && !flag_get("tip_vault")) {
        _id = "tip_vault"; _text = "Dash into the big vault door with SHIFT to smash it"; _timed = true;
    } else if (_chased && !flag_get("tip_guards")) {
        _id = "tip_guards"; _text = "Guards hurt! Dash into them with SHIFT, or run"; _timed = true;
    } else if (!flag_get("tip_dash")) {
        _id = "tip_dash"; _text = "SHIFT dashes. Hold A / D to aim it, or point the mouse";
    } else if (!flag_get("tip_cash")) {
        _id = "tip_cash"; _text = "Grab the money! You only keep it if you escape";
    }
}

if (_id != tip_id) {
    tip_id  = _id;
    tip_age = 0;
} else {
    tip_age++;
}

if (_timed && tip_age > 420) flag_set(_id);

tip_text = global.tips_enabled ? _text : "";

// H switches tips off (they can go back on in Settings or the pause menu).
if (tip_text != "" && keyboard_check_pressed(ord("H"))) {
    global.tips_enabled = false;
    tip_text = "";
    save_game();
}
