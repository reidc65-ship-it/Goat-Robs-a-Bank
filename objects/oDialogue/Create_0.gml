// =====================================================================
//  oDialogue -> Create
//  Visual-novel conversation overlay. oBearNPC fills in `lines` and
//  `speakers`, then calls start_dialogue().
// =====================================================================

// --- Data (assigned by the NPC) ---------------------------------------
lines    = [];
speakers = {};

// --- Runtime ----------------------------------------------------------
line_index    = 0;
active_side   = "left";
current_text  = "";
visible_chars = 0;
char_speed    = 0.8;      // characters per frame
bubble_left   = "";
bubble_right  = "";
start_timer   = 0;
close_timer   = 0;
is_closing    = false;
on_complete   = undefined; // optional callback when dialogue ends

// --- Layout (1366 x 768 GUI) -----------------------------------------
portrait_size    = 520;
portrait_y       = 50;
left_portrait_x  = 120;
right_portrait_x = 746;

bubble_y1 = 510;
bubble_y2 = 700;
bubble_w  = 560;

left_bubble_x1  = 90;
right_bubble_x1 = 716;

tag_w = 240;
tag_h = 46;

body_scale  = 1.7;
body_line_h = 32;

// --- Palette ----------------------------------------------------------
col_bg_top    = make_colour_rgb(253, 250, 244);
col_bg_bottom = make_colour_rgb(244, 236, 223);
col_gold      = make_colour_rgb(201, 162, 39);
col_ink_soft  = make_colour_rgb(90, 76, 60);

// =====================================================================
//  Helpers
// =====================================================================

/// @desc Greedy word-wrap for the built-in font.
wrap_text = function(_text, _max_width, _scale) {
    var _words = string_split(_text, " ");
    var _lines = [];
    var _cur   = "";

    for (var _i = 0; _i < array_length(_words); _i++) {
        var _word = _words[_i];
        var _test = (_cur == "") ? _word : _cur + " " + _word;

        if (string_width(_test) * _scale > _max_width && _cur != "") {
            array_push(_lines, _cur);
            _cur = _word;
        } else {
            _cur = _test;
        }
    }

    if (_cur != "") array_push(_lines, _cur);
    return _lines;
};

/// @desc Text with a soft shadow and a fake-bold pass (built-in font).
draw_ui_text = function(_x, _y, _str, _scale, _col, _halign, _alpha) {
    draw_set_halign(_halign);
    draw_set_valign(fa_middle);

    draw_set_colour(c_black);
    draw_set_alpha(_alpha * 0.55);
    draw_text_transformed(_x + 2, _y + 2, _str, _scale, _scale, 0);

    draw_set_colour(_col);
    draw_set_alpha(_alpha);
    draw_text_transformed(_x, _y, _str, _scale, _scale, 0);
    draw_text_transformed(_x + max(1, _scale * 0.45), _y, _str, _scale, _scale, 0);

    draw_set_alpha(1);
};

/// @desc Draw one speech bubble. `_visible` < 0 means show all text.
draw_bubble = function(_side, _text, _is_active, _visible) {
    var _x1 = (_side == "left") ? left_bubble_x1 : right_bubble_x1;
    var _x2 = _x1 + bubble_w;
    var _y1 = bubble_y1;
    var _y2 = bubble_y2;
    var _spk = speakers[$ _side];
    var _alpha = _is_active ? 1 : 0.5;

    // Soft shadow
    draw_set_colour(c_black);
    draw_set_alpha(0.10 * _alpha);
    draw_roundrect_ext(_x1 + 6, _y1 + 10, _x2 + 6, _y2 + 10,
                       22, 22, false);

    // Body
    draw_set_alpha(_alpha);
    draw_set_colour(_spk.bubble_border);
    draw_roundrect_ext(_x1, _y1, _x2, _y2, 22, 22, false);

    draw_set_colour(_spk.bubble_fill);
    draw_roundrect_ext(_x1 + 4, _y1 + 4, _x2 - 4, _y2 - 4,
                       18, 18, false);

    // Name tag (top-left of each bubble)
    var _tx1 = _x1;
    var _tx2 = _x1 + tag_w;
    var _ty1 = _y1 - 34;
    var _ty2 = _ty1 + tag_h;

    draw_set_colour(_spk.tag_border);
    draw_roundrect_ext(_tx1, _ty1, _tx2, _ty2, 16, 16, false);
    draw_set_colour(_spk.tag_fill);
    draw_roundrect_ext(_tx1 + 3, _ty1 + 3, _tx2 - 3, _ty2 - 3,
                       13, 13, false);

    draw_ui_text((_tx1 + _tx2) * 0.5, (_ty1 + _ty2) * 0.5 + 1,
                 _spk.name, 1.5, _spk.text_col, fa_center, _alpha);

    // Body text
    var _pad    = 34;
    var _max_w  = bubble_w - _pad * 2;
    var _text_x = _x1 + _pad;
    var _text_y = _y1 + 42;

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(_alpha);
    draw_set_colour(_spk.text_col);

    if (_text == "") {
        draw_text_transformed(_text_x, _text_y, "...",
                              body_scale, body_scale, 0);
    } else {
        var _wrapped = wrap_text(_text, _max_w, body_scale);
        var _chars   = (_visible < 0) ? 999999 : floor(_visible);

        for (var _i = 0; _i < array_length(_wrapped); _i++) {
            var _line = _wrapped[_i];
            var _n    = clamp(_chars, 0, string_length(_line));

            if (_n > 0) {
                draw_text_transformed(_text_x, _text_y + _i * body_line_h,
                                      string_copy(_line, 1, _n),
                                      body_scale, body_scale, 0);
            }

            _chars -= string_length(_line) + 1;
        }
    }

    // Blinking continue marker on the active bubble
    if (_is_active && _visible >= 0) {
        if (_visible >= string_length(current_text)) {
            var _blink = (sin(current_time / 180) + 1) * 0.5;
            draw_set_alpha(0.35 + 0.65 * _blink);
            draw_set_colour(col_gold);
            draw_triangle(_x2 - 34, _y2 - 24,
                          _x2 - 18, _y2 - 24,
                          _x2 - 26, _y2 - 14, false);
        }
    }

    draw_set_alpha(1);
};

/// @desc Show line _i and reset the typewriter.
show_line = function(_i) {
    var _line = lines[_i];

    line_index    = _i;
    active_side   = _line.side;
    current_text  = _line.text;
    visible_chars = 0;

    // Keep the full text so this bubble stays readable when the other
    // character starts speaking.
    if (active_side == "left") {
        bubble_left = current_text;
    } else {
        bubble_right = current_text;
    }
};

// =====================================================================
//  Conversation flow
// =====================================================================

start_dialogue = function() {
    if (array_length(lines) <= 0) {
        instance_destroy();
        exit;
    }

    if (!variable_global_exists("game_paused")) global.game_paused = false;

    global.dialogue_active = true;
    global.game_paused     = true;

    is_closing    = false;
    close_timer   = 0;
    start_timer   = 1;
    bubble_left   = "";
    bubble_right  = "";
    visible_chars = 0;

    show_line(0);
};

end_dialogue = function() {
    if (is_closing) exit;

    // Hold the pause for one extra frame so the closing key / click
    // cannot also fire a shot on the frame the overlay disappears.
    is_closing  = true;
    close_timer = 1;
};

/// @desc Called when dialogue fully closes. Runs on_complete callback.
finish_dialogue = function() {
    global.dialogue_active = false;
    global.game_paused     = false;

    if (is_callable(on_complete)) {
        on_complete();
    }

    instance_destroy();
};

advance_line = function() {
    var _len = string_length(current_text);

    // First press completes the typewriter, second press advances.
    if (visible_chars < _len) {
        visible_chars = _len;
        exit;
    }

    if (line_index < array_length(lines) - 1) {
        show_line(line_index + 1);
    } else {
        end_dialogue();
    }
};
