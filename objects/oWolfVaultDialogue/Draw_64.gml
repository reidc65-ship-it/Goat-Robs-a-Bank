// =====================================================================
//  oWolfVaultDialogue -> Draw GUI
//  A single wolf head and a conversation box. No animated speaker pair.
// =====================================================================

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

ui_scale    = min(_gw / 1366, _gh / 768);
ui_origin_x = (_gw - 1366 * ui_scale) * 0.5;
ui_origin_y = (_gh - 768 * ui_scale) * 0.5;

draw_set_font(-1);
draw_set_alpha(1);

// Paper backdrop.
draw_rectangle_colour(ui_x(0), ui_y(0), ui_x(1366), ui_y(768),
                      col_paper_top, col_paper_top,
                      col_paper_bottom, col_paper_bottom, false);

draw_set_colour(col_gold);
draw_set_alpha(0.55);
draw_rectangle(ui_x(0), ui_y(0), ui_x(_gw / ui_scale), ui_y(_gh / ui_scale), true);
draw_set_alpha(0.18);
draw_rectangle(ui_x(8), ui_y(8), ui_x(_gw / ui_scale - 8), ui_y(_gh / ui_scale - 8), true);
draw_set_alpha(1);

// Wolf head portrait, from the story image supplied for this scene.
draw_sprite_ext(sWolfHeadStory, 0, ui_x(portrait_x + 14), ui_y(portrait_y + 16),
                ui_s(portrait_scale), ui_s(portrait_scale), 0, c_black, 0.10);
draw_sprite_ext(sWolfHeadStory, 0, ui_x(portrait_x), ui_y(portrait_y),
                ui_s(portrait_scale), ui_s(portrait_scale), 0, c_white, 1);

// Speech bubble shadow and body.
draw_set_colour(c_black);
draw_set_alpha(0.10);
draw_roundrect_ext(ui_x(bubble_x1 + 6), ui_y(bubble_y1 + 10),
                   ui_x(bubble_x2 + 6), ui_y(bubble_y2 + 10), ui_s(22), ui_s(22), false);

draw_set_alpha(1);
draw_set_colour(col_gold);
draw_roundrect_ext(ui_x(bubble_x1), ui_y(bubble_y1),
                   ui_x(bubble_x2), ui_y(bubble_y2), ui_s(22), ui_s(22), false);
draw_set_colour(col_paper_top);
draw_roundrect_ext(ui_x(bubble_x1 + 4), ui_y(bubble_y1 + 4),
                   ui_x(bubble_x2 - 4), ui_y(bubble_y2 - 4), ui_s(18), ui_s(18), false);

// Name tag.
var _tx1 = bubble_x1;
var _tx2 = bubble_x1 + 260;
var _ty1 = bubble_y1 - 36;
var _ty2 = _ty1 + 46;

draw_set_colour(col_gold);
draw_roundrect_ext(ui_x(_tx1), ui_y(_ty1), ui_x(_tx2), ui_y(_ty2), ui_s(16), ui_s(16), false);
draw_set_colour(col_paper_bottom);
draw_roundrect_ext(ui_x(_tx1 + 3), ui_y(_ty1 + 3), ui_x(_tx2 - 3), ui_y(_ty2 - 3), ui_s(13), ui_s(13), false);
draw_ui_text(ui_x((_tx1 + _tx2) * 0.5), ui_y((_ty1 + _ty2) * 0.5 + 1),
             "WOLF GUARD", ui_s(1.45), col_ink, fa_center, 1);

// Typewriter body text.
var _pad = 34;
var _max_w = (bubble_x2 - bubble_x1) - _pad * 2;
var _wrapped = wrap_text(current_text, _max_w, body_scale);
var _chars = floor(visible_chars);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_colour(col_ink);

for (var _i = 0; _i < array_length(_wrapped); _i++) {
    var _line = _wrapped[_i];
    var _n = clamp(_chars, 0, string_length(_line));
    if (_n > 0) {
        draw_text_transformed(ui_x(bubble_x1 + _pad),
                              ui_y(bubble_y1 + 52 + _i * body_line_h),
                              string_copy(_line, 1, _n),
                              ui_s(body_scale), ui_s(body_scale), 0);
    }
    _chars -= string_length(_line) + 1;
}

// Continue marker.
if (visible_chars >= string_length(current_text)) {
    var _blink = (sin(current_time / 180) + 1) * 0.5;
    draw_set_colour(col_gold);
    draw_set_alpha(0.35 + 0.65 * _blink);
    draw_triangle(ui_x(bubble_x2 - 38), ui_y(bubble_y2 - 28),
                  ui_x(bubble_x2 - 20), ui_y(bubble_y2 - 28),
                  ui_x(bubble_x2 - 29), ui_y(bubble_y2 - 16), false);
    draw_set_alpha(1);
}

gui_text(_gw * 0.5, ui_y(738),
         "E / ENTER / SPACE / CLICK   CONTINUE          ESC   SKIP",
         ui_s(1.1), col_ink, fa_center, 0.7);

draw_set_colour(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
