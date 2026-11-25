// =====================================================================
//  oGoatScout -> Draw
// =====================================================================

// Soft shadow for the photo-sticker cutout.
draw_sprite_ext(sprite_index, 0, x + 6, y + 8,
                image_xscale, image_yscale, image_angle, c_black, 0.22);
draw_self();

// Red cap. The sprite origin is centred so it spans bbox_top - 6 .. +6.
draw_sprite(sScoutCap, 0, x, bbox_top);

// Name, shown until the talk prompt replaces it.
if (!can_talk) {
    var _locked = !flag_get("scarecrow_defeated");
    draw_set_font(-1);
    gui_text(x, bbox_top - 18,
             _locked ? "SCOUT - BOARD LOCKED" : "SCOUT - JOB BOARD",
             1.1, _locked ? make_colour_rgb(242, 208, 107) : c_white,
             fa_center, 0.95);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// Floating "talk" prompt, only while the player is close and free.
if (can_talk && !global.dialogue_active && !global.game_paused
    && !(variable_global_exists("level_complete") && global.level_complete)) {
    var _bob = sin(current_time / 300) * 3;
    var _px  = x;
    var _py  = bbox_top - 34 + _bob;

    // Shadow behind the bubble art.
    draw_set_alpha(0.35);
    draw_sprite_ext(sPromptBubble_L, 0, _px + 4, _py + 6, 1, 1, 0, c_black, 1);
    draw_set_alpha(1);
    draw_sprite(sPromptBubble_L, 0, _px, _py);

    // Prompt text chosen in this order:
    //   defeated -> jobs, pending -> lesson, otherwise -> talk.
    var _prompt = flag_get("scarecrow_defeated") ? "SCOUT  -  E  JOBS"
                 : (flag_get("scarecrow_pending") ? "SCOUT  -  E  LESSON"
                                                  : "SCOUT  -  E  TALK");
    draw_set_font(-1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_set_alpha(0.7);
    draw_set_colour(c_black);
    draw_text_transformed(_px + 2, _py + 2, _prompt, 1.3, 1.3, 0);

    draw_set_alpha(1);
    draw_set_colour(make_colour_rgb(242, 208, 107));
    draw_text_transformed(_px, _py, _prompt, 1.3, 1.3, 0);
    draw_text_transformed(_px + 1, _py, _prompt, 1.3, 1.3, 0);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
