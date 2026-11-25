// =====================================================================
//  oWolfVaultDialogue -> Create
//  Tiny setup object for the post-results story beat. It hands the lines
//  and speaker palettes to oDialogue, so the box looks exactly like the
//  other conversations in the game. The wolf tells Bear he was robbed.
// =====================================================================

game_state_init();

// --- Speakers ---------------------------------------------------------
// Same layout and palette style as the Bear's existing conversation. The
// supplied wolf-head picture sits on the left; Bear keeps his portrait on
// the right.
speakers = {
    left: {
        name:          "WOLF",
        portrait:      sWolfHeadStory,
        bubble_fill:   make_colour_rgb(238, 241, 246),
        bubble_border: make_colour_rgb(148, 163, 183),
        tag_fill:      make_colour_rgb(206, 216, 230),
        tag_border:    make_colour_rgb(142, 158, 180),
        text_col:      make_colour_rgb(36, 43, 54)
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
// The wolf is the one delivering the news: Bear's bank has been robbed.
dialogue = [
    { side: "left",  text: "Boss! Someone just cleaned out the bank!" },
    { side: "left",  text: "The vault is empty. You have been ROBBED." },
    { side: "right", text: "Robbed? By who?!" },
    { side: "left",  text: "A goat, Boss. A GOAT!" },
    { side: "right", text: "Find him. Bring back my money." }
];

// oDialogue owns the pause, the typewriter, the drawing and the input.
// When it closes, go straight back to the farm.
var _d = instance_create_depth(0, 0, -20000, oDialogue);
_d.lines    = dialogue;
_d.speakers = speakers;
_d.on_complete = function() {
    room_goto(rm_farm);
};
_d.start_dialogue();

// This object only set the conversation up; oDialogue does the rest.
instance_destroy();
