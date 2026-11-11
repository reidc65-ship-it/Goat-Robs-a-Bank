// =====================================================================
//  oGoatScout -> Draw
// =====================================================================

// Soft shadow for the photo-sticker cutout.
draw_sprite_ext(sprite_index, 0, x + 6, y + 8,
                image_xscale, image_yscale, image_angle, c_black, 0.22);
draw_self();

// Red cap
draw_set_colour(make_colour_rgb(200, 50, 50));
draw_roundrect_ext(x - 13, bbox_top - 6, x + 13, bbox_top + 6, 6, 6, false);
draw_rectangle(x - 18, bbox_top + 2, x + 18, bbox_top + 6, false);

// Name, shown until the talk prompt replaces it.
if (!can_talk) {
    draw_set_font(-1);
    gui_text(x, bbox_top - 18, "SCOUT - JOB BOARD", 1.1, c_white, fa_center, 0.95);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// Floating "talk" prompt, only while the player is close and free.
if (can_talk && !global.dialogue_active && !global.game_paused
    && !(variable_global_exists("level_complete") && global.level_complete)) {
    var _bob = sin(current_time / 300) * 3;
    var _px  = x;
    var _py  = bbox_top - 34 + _bob;
    var _w   = 240;
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
    draw_text_transformed(_px + 2, _py + 2, "SCOUT  -  E  JOBS", 1.3, 1.3, 0);

    draw_set_alpha(1);
    draw_set_colour(make_colour_rgb(242, 208, 107));
    draw_text_transformed(_px, _py, "SCOUT  -  E  JOBS", 1.3, 1.3, 0);
    draw_text_transformed(_px + 1, _py, "SCOUT  -  E  JOBS", 1.3, 1.3, 0);

    draw_set_alpha(1);
}