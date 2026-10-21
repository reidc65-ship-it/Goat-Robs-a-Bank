// =====================================================================
//  oBearNPC -> Create
//  An interactable bear resting on the bank floor. Walk close and press
//  E to start the conversation.
// =====================================================================

// This object can be run directly from the Room Editor, before the
// persistent pause controller has had a chance to create the globals.
if (!variable_global_exists("game_paused"))     global.game_paused = false;
if (!variable_global_exists("dialogue_active")) global.dialogue_active = false;

can_talk   = false;
talk_range = 180;

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
    _d.lines    = dialogue;
    _d.speakers = speakers;
    _d.start_dialogue();
};
