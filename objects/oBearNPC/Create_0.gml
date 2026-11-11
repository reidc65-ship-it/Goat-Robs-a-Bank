// =====================================================================
//  oBearNPC -> Create
//  Mr. Bear, the bank's owner. oHeist brings Bear in when the vault is
//  robbed, so the villain gets to gloat before storming off. If placed in a
//  room by hand, walk close and press E instead.
// =====================================================================

game_state_init();

// This object can be run directly from the Room Editor, before the
// persistent pause controller has had a chance to create the globals.
if (!variable_global_exists("game_paused"))     global.game_paused = false;
if (!variable_global_exists("dialogue_active")) global.dialogue_active = false;

can_talk   = false;
talk_range = 180;
leaving    = false;   // storms off after the conversation

// --- Speakers ---------------------------------------------------------
// Each side owns its portrait, name and bubble palette. Add or edit
// entries here to change the look of the conversation.
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
        name:          "BEAR",
        portrait:      sPortraitBear,
        bubble_fill:   make_colour_rgb(246, 217, 217),
        bubble_border: make_colour_rgb(197, 140, 140),
        tag_fill:      make_colour_rgb(220, 163, 163),
        tag_border:    make_colour_rgb(184, 122, 122),
        text_col:      make_colour_rgb(43, 31, 28)
    }
};

// --- Conversation -----------------------------------------------------
// `side` selects the speaker from the struct above. Edit the text freely.
dialogue_repeat = [
    { side: "right", text: "YOU AGAIN?! I bought more wolves! Do you know what wolves COST?" },
    { side: "left",  text: "Roughly? I've seen your vault." },
    { side: "right", text: "GUARDS!" }
];
dialogue = [
    { side: "right", text: "Halt, goat. That's an awful lot of cash for a bakery." },
    { side: "left",  text: "It was a very successful bake sale." },
    { side: "right", text: "A bake sale. Inside the bank vault." },
    { side: "left",  text: "The customers were... highly motivated." },
    { side: "right", text: "Goat... when I catch you, Goat..." },
    { side: "left",  text: "You'll have to catch me first!" }
];

start_conversation = function() {
    var _d = instance_create_depth(0, 0, -20000, oDialogue);
    _d.lines       = flag_get("bear_met") ? dialogue_repeat : dialogue;
    _d.speakers    = speakers;
    _d.on_complete = on_talk_done;
    flag_set("bear_met");
    _d.start_dialogue();
};

on_talk_done = function() {
    leaving = true;
};
