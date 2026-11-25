// =====================================================================
//  oBearNPC -> Draw
// =====================================================================

// Soft shadow for the photo-sticker cutout.
draw_sprite_ext(sprite_index, 0, x + 6, y + 8,
                image_xscale, image_yscale, image_angle, c_black, 0.22 * image_alpha);
draw_self();

// Floating "talk" prompt, only while the player is close and free.
if (can_talk && !global.dialogue_active && !global.game_paused
    && !(variable_global_exists("level_complete") && global.level_complete)) {
    var _bob = sin(current_time / 300) * 3;
    var _px  = x;
    var _py  = bbox_top - 34 + _bob;

    // Shadow behind the bubble art.
    draw_set_alpha(0.35);
    draw_sprite_ext(sPromptBubble_S, 0, _px + 4, _py + 6, 1, 1, 0, c_black, 1);
    draw_set_alpha(1);
    draw_sprite(sPromptBubble_S, 0, _px, _py);

    // Text sits in the middle of the bubble body.
    draw_set_font(-1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_set_alpha(0.7);
    draw_set_colour(c_black);
    draw_text_transformed(_px + 2, _py + 2, "E   TALK", 1.3, 1.3, 0);

    draw_set_alpha(1);
    draw_set_colour(make_colour_rgb(242, 208, 107));
    draw_text_transformed(_px, _py, "E   TALK", 1.3, 1.3, 0);
    draw_text_transformed(_px + 1, _py, "E   TALK", 1.3, 1.3, 0);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
