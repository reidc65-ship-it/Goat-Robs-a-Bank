// =====================================================================
//  oFamilyGoat -> Create
//  Mama Goat, on the farm. Reacts to how the player has spent the stolen
//  money. To add a reaction, add a branch to get_lines().
// =====================================================================

game_state_init();

can_talk   = false;
talk_range = 90;

// Same goat art for now; the tint keeps the characters easy to tell apart.
image_blend = make_colour_rgb(255, 205, 215);

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
        name:          "MAMA GOAT",
        portrait:      sPortraitGoat,
        tint:          image_blend,
        bubble_fill:   make_colour_rgb(250, 226, 232),
        bubble_border: make_colour_rgb(205, 160, 172),
        tag_fill:      make_colour_rgb(238, 200, 210),
        tag_border:    make_colour_rgb(190, 140, 155),
        text_col:      make_colour_rgb(50, 28, 34)
    }
};

/// @desc Picks a conversation from the player's choices so far.
get_lines = function() {
    if (upgrade_owned("sprinkler")) {
        return [
            { side: "right", text: "A sprinkler! The chickens are confused, but very hydrated." },
            { side: "right", text: "I don't know how you afford this, and I've decided not to ask." },
            { side: "left",  text: "Bake sales, Ma. Lots of bake sales." }
        ];
    }
    if (upgrade_owned("grass")) {
        return [
            { side: "right", text: "Look at this grass! It's actually green! I cried a little." },
            { side: "right", text: "The chickens have stopped filing complaints." },
            { side: "left",  text: "Nothing's too good for this family, Ma." }
        ];
    }
    if (spent_on_goat() > 0) {
        return [
            { side: "right", text: "So you bought yourself something shiny, and the grass is still dead." },
            { side: "left",  text: "It's an investment, Ma. In me." },
            { side: "right", text: "The ELDER sells farm things too, you know. Just saying." }
        ];
    }
    if (global.heists_completed > 0) {
        return [
            { side: "right", text: "Where did all this money come from?" },
            { side: "left",  text: "It was a very successful bake sale." },
            { side: "right", text: "Well, the grass is still brown. Talk to the ELDER in the barn." }
        ];
    }
    return [
        { side: "right", text: "The grass is dead, the fence is rotting, and the bank wants its money." },
        { side: "right", text: "Mr. Bear owns that bank, and half this town. He's raised our rent again." },
        { side: "left",  text: "Don't worry, Ma. I'll think of something." },
        { side: "right", text: "That's what worries me." }
    ];
};

start_conversation = function() {
    flag_set("family_met");

    var _d = instance_create_depth(0, 0, -20000, oDialogue);
    _d.lines    = get_lines();
    _d.speakers = speakers;
    _d.start_dialogue();
};
