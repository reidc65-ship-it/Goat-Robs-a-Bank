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

// --- Conversation (Dash Lesson) --------------------------------------
// The Scout will not hand out a job until the goat has used the starter
// dash on a training scarecrow outside the barn.
intro_dialogue = [
    { side: "right", text: "Whoa, slow down. Board's locked until you prove you can fight." },
    { side: "left",  text: "Fight? I'm a goat in a vest." },
    { side: "right", text: "A goat with a dash. I staked a training scarecrow outside the barn door." },
    { side: "right", text: "Hold A or D, then tap SHIFT to dash through it. Two good hits and it's firewood." },
    { side: "left",  text: "And then the board opens?" },
    { side: "right", text: "Then the board opens. Go on, make some straw fly." }
];

reminder_dialogue = [
    { side: "right", text: "That scarecrow is still standing. It's right outside the barn door." },
    { side: "right", text: "Hold A or D, tap SHIFT, and dash through it. Twice." },
    { side: "left",  text: "Working on it." }
];

unlocked_dialogue = [
    { side: "left",  text: "Scarecrow's down." },
    { side: "right", text: "Look at that. Straw everywhere. Board's unlocked - pick your first job." }
];

start_conversation = function() {
    var _d;

    // Board already earned: straight through.
    if (flag_get("scarecrow_defeated")) {
        if (!flag_get("board_opened")) {
            flag_set("board_opened");
            _d = instance_create_depth(0, 0, -20000, oDialogue);
            _d.lines       = unlocked_dialogue;
            _d.speakers    = speakers;
            _d.on_complete = open_level_select;
            _d.start_dialogue();
            return;
        }
        open_level_select();
        return;
    }

    // Tutorial already started but the scarecrow is still up.
    if (flag_get("scarecrow_pending")) {
        _d = instance_create_depth(0, 0, -20000, oDialogue);
        _d.lines       = reminder_dialogue;
        _d.speakers    = speakers;
        _d.on_complete = undefined;
        _d.start_dialogue();
        return;
    }

    // First meeting: explain the dash lesson and put the dummy outside.
    flag_set("scout_met");
    flag_set("scarecrow_pending");

    _d = instance_create_depth(0, 0, -20000, oDialogue);
    _d.lines       = intro_dialogue;
    _d.speakers    = speakers;
    _d.on_complete = announce_scarecrow;
    _d.start_dialogue();
};

/// @desc Called when the intro conversation ends. The scarecrow itself is
///       placed in rm_farm and only appears while the lesson is active.
announce_scarecrow = function() {
    if (!instance_exists(oPlayer)) return;

    var _p = instance_find(oPlayer, 0);
    _p.show_hint("Training scarecrow is outside the barn. DASH through it with SHIFT!", 420);
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