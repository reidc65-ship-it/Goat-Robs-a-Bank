// =====================================================================
//  oFamilyGoat -> Draw
// =====================================================================

draw_sprite_ext(sprite_index, 0, x + 6, y + 8,
                image_xscale, image_yscale, image_angle, c_black, 0.22);
draw_self();

draw_set_font(-1);
gui_text(x, bbox_top - 14, "MAMA GOAT", 1.1, c_white, fa_center, 0.95);

if (can_talk && !game_is_frozen()) {
    var _bob = sin(current_time / 300) * 3;
    gui_text(x, bbox_top - 44 + _bob, "E  TALK", 1.4, make_colour_rgb(255, 225, 130), fa_center, 1);
}

draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
