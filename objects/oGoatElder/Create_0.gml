// =====================================================================
//  oGoatElder -> Create
//  Elder goat in the barn. Offers upgrades for heist gear.
//  Walk close and press E to open upgrade menu.
// =====================================================================

if (!variable_global_exists("game_paused"))     global.game_paused = false;
if (!variable_global_exists("dialogue_active")) global.dialogue_active = false;

can_talk   = false;
talk_range = 120;

// --- Speakers ---------------------------------------------------------
speakers = {
    left: {
        name:          "GOAT",
        portrait:      sPortraitGoat,
        bubble_fill:   make_colour_rgb(247, 238, 223),
        bubble_border: make_colour_rgb(201, 183, 154),
        tag_fill:      make_colour_rgb(232, 217, 193),
        tag_border:    make_colour_rgb(185, 165, 138),
        text_col:      make_colour_rgb(43, 33, 24)
    },
    right: {
        name:          "ELDER",
        portrait:      sPortraitGoat,
        bubble_fill:   make_colour_rgb(223, 247, 223),
        bubble_border: make_colour_rgb(154, 201, 154),
        tag_fill:      make_colour_rgb(193, 232, 193),
        tag_border:    make_colour_rgb(138, 185, 138),
        text_col:      make_colour_rgb(24, 43, 24)
    }
};

// --- Conversation (Upgrade Menu Intro) -------------------------------
dialogue = [
    { side: "right", text: "Welcome back, young one. The barn's been waiting." },
    { side: "left",  text: "You're the one who handles upgrades, right?" },
    { side: "right", text: "Aye. Horns, hooves, hide — I can strengthen them all." },
    { side: "right", text: "But quality costs. Bring me what you've stolen." },
    { side: "left",  text: "Then let's see what you've got." }
];

start_conversation = function() {
    var _d = instance_create_depth(0, 0, -20000, oDialogue);
    _d.lines      = dialogue;
    _d.speakers   = speakers;
    _d.on_complete = open_upgrade_menu;
    _d.start_dialogue();
};

/// @desc Called after dialogue ends to open upgrade menu
open_upgrade_menu = function() {
    // TODO: Open upgrade menu UI here
    // For now, just show a simple message
    show_debug_message("OPEN UPGRADE MENU - bank_balance: " + string(global.bank_balance));
};