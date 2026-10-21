// =====================================================================
//  oDialogue -> Draw GUI
// =====================================================================

if (array_length(lines) <= 0) exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

draw_set_font(-1);
draw_set_alpha(1);

// --- Paper backdrop ---------------------------------------------------
draw_rectangle_colour(0, 0, _gw, _gh,
                      col_bg_top, col_bg_top,
                      col_bg_bottom, col_bg_bottom, false);

// Thin gold frame
draw_set_colour(col_gold);
draw_set_alpha(0.55);
draw_rectangle(0, 0, _gw - 1, _gh - 1, true);
draw_set_alpha(0.18);
draw_rectangle(6, 6, _gw - 7, _gh - 7, true);
draw_set_alpha(1);

// --- Portraits --------------------------------------------------------
var _active_left = (active_side == "left");
var _goat_spk    = speakers[$ "left"];
var _bear_spk    = speakers[$ "right"];

var _gx = left_portrait_x + portrait_size * 0.5;
var _gy = portrait_y + portrait_size * 0.5;
var _ga = _active_left ? 1 : 0.68;

draw_sprite_ext(_goat_spk.portrait, 0, _gx + 12, _gy + 16,
                1, 1, 0, c_black, 0.08 * _ga);
draw_sprite_ext(_goat_spk.portrait, 0, _gx, _gy,
                1, 1, 0, c_white, _ga);

var _bx = right_portrait_x + portrait_size * 0.5;
var _by = portrait_y + portrait_size * 0.5;
var _ba = _active_left ? 0.68 : 1;

draw_sprite_ext(_bear_spk.portrait, 0, _bx + 12, _by + 16,
                1, 1, 0, c_black, 0.08 * _ba);
draw_sprite_ext(_bear_spk.portrait, 0, _bx, _by,
                1, 1, 0, c_white, _ba);

// --- Speech bubbles ---------------------------------------------------
if (_active_left) {
    draw_bubble("left",  current_text, true,  visible_chars);
    draw_bubble("right", bubble_right, false, -1);
} else {
    draw_bubble("left",  bubble_left,  false, -1);
    draw_bubble("right", current_text, true,  visible_chars);
}

// --- Footer hint ------------------------------------------------------
draw_ui_text(_gw * 0.5, 730,
             "E / ENTER / SPACE   CONTINUE          ESC   END",
             1.1, col_ink_soft, fa_center, 0.7);

draw_set_alpha(1);
