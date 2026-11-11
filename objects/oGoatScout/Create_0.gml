// =====================================================================
//  oGoatScout -> Create
//  Scout goat by the barn door. Opens the level select / heist board.
//  Walk close and press E to pick the next job.
// =====================================================================

game_state_init();

can_talk   = false;
talk_range = 120;

// Same goat art as the player for now. The tint and the cap (see Draw)
// keep the characters easy to tell apart.
image_blend = make_colour_rgb(255, 222, 170);

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
        name:          "SCOUT",
        portrait:      sPortraitGoat,
        tint:          image_blend,
        bubble_fill:   make_colour_rgb(223, 238, 247),
        bubble_border: make_colour_rgb(154, 183, 201),
        tag_fill:      make_colour_rgb(193, 217, 232),
        tag_border:    make_colour_rgb(138, 165, 185),
        text_col:      make_colour_rgb(24, 33, 43)
    }
};

// --- Conversation (Level Select Intro) -------------------------------
dialogue = [
    { side: "right", text: "Heist board's ready. Five jobs posted, one unlocked." },
    { side: "left",  text: "Only one? What about the others?" },
    { side: "right", text: "Need to prove yourself first. Bank don't rob itself." },
    { side: "right", text: "Grab the vault loot, get out alive, keep the cash. Simple." },
    { side: "left",  text: "Show me the board." }
];

start_conversation = function() {
    // The introduction only plays once. After that, straight to the board.
    if (flag_get("scout_met")) {
        open_level_select();
        return;
    }
    flag_set("scout_met");

    var _d = instance_create_depth(0, 0, -20000, oDialogue);
    _d.lines      = dialogue;
    _d.speakers   = speakers;
    _d.on_complete = open_level_select;
    _d.start_dialogue();
};

/// @desc Called after dialogue ends to open level select (rm_menu)
open_level_select = function() {
    // Backing out of the board returns to the barn, next to the Scout.
    global.menu_return_room = rm_barn;
    global.menu_return_x    = 880;
    global.menu_return_y    = 608;
    global.menu_open_board  = true;
    room_goto(rm_menu);
};