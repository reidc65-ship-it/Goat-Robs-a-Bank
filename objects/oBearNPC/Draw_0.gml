// =====================================================================
//  oBearNPC -> Draw
// =====================================================================

// Soft shadow for the photo-sticker cutout.
draw_sprite_ext(sprite_index, 0, x + 6, y + 8,
                image_xscale, image_yscale, image_angle, c_black, 0.22);
draw_self();

// Floating "talk" prompt, only while the player is close and free.
if (can_talk && !global.dialogue_active && !global.game_paused
    && !(variable_global_exists("level_complete") && global.level_complete)) {
    var _bob = sin(current_time / 300) * 3;
    var _px  = x;
    var _py  = bbox_top - 34 + _bob;
    var _w   = 148;
    var _h   = 38;

    // Shadow
    draw_set_alpha(0.35);
    draw_set_colour(c_black);
    draw_roundrect_ext(_px - _w * 0.5 + 4, _py - _h * 0.5 + 6,
                       _px + _w * 0.5 + 4, _py + _h * 0.5 + 6,
                       10, 10, false);

    // Body
    draw_set_alpha(1);
    draw_set_colour(make_colour_rgb(201, 162, 39));
    draw_roundrect_ext(_px - _w * 0.5, _py - _h * 0.5,
                       _px + _w * 0.5, _py + _h * 0.5,
                       10, 10, false);
    draw_set_colour(make_colour_rgb(14, 18, 28));
    draw_roundrect_ext(_px - _w * 0.5 + 2, _py - _h * 0.5 + 2,
                       _px + _w * 0.5 - 2, _py + _h * 0.5 - 2,
                       8, 8, false);

    // Pointer
    draw_set_colour(make_colour_rgb(201, 162, 39));
    draw_triangle(_px - 8, _py + _h * 0.5,
                  _px + 8, _py + _h * 0.5,
                  _px, _py + _h * 0.5 + 10, false);

    // Text
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
}
