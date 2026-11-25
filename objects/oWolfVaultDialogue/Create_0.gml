// =====================================================================
//  oWolfVaultDialogue -> Create
//  Story overlay shown when the vault is looted. The old Bear/Goat
//  conversation is gone: this is a single wolf guard reporting the theft.
// =====================================================================

game_state_init();

lines = [
    "Boss! One of the banks just got cleaned out!",
    "A goat broke into the vault and got away with the money."
];

line_index    = 0;
current_text  = "";
visible_chars = 0;
char_speed    = 0.8;
start_timer   = 1;
close_timer   = 0;
is_closing    = false;

portrait_x = 200;
portrait_y = 330;
portrait_scale = 1.0;

bubble_x1 = 700;
bubble_y1 = 470;
bubble_x2 = 1260;
bubble_y2 = 680;

body_scale  = 1.7;
body_line_h = 34;

// Filled by Draw GUI, then used by the same event's helpers.
ui_scale    = 1;
ui_origin_x = 0;
ui_origin_y = 0;

ui_x = function(_v) { return ui_origin_x + _v * ui_scale; };
ui_y = function(_v) { return ui_origin_y + _v * ui_scale; };
ui_s = function(_v) { return _v * ui_scale; };

col_paper_top    = make_colour_rgb(253, 250, 244);
col_paper_bottom = make_colour_rgb(236, 226, 210);
col_gold         = make_colour_rgb(201, 162, 39);
col_ink          = make_colour_rgb(48, 38, 30);

if (!variable_global_exists("game_paused"))     global.game_paused = false;
if (!variable_global_exists("dialogue_active")) global.dialogue_active = false;

global.dialogue_active = true;
global.game_paused     = true;

show_line(0);

/// @desc Greedy word-wrap for the built-in font.
wrap_text = function(_text, _max_width, _scale) {
    var _words = string_split(_text, " ");
    var _result = [];
    var _cur = "";

    for (var _i = 0; _i < array_length(_words); _i++) {
        var _word = _words[_i];
        var _test = (_cur == "") ? _word : _cur + " " + _word;
        if (string_width(_test) * _scale > _max_width && _cur != "") {
            array_push(_result, _cur);
            _cur = _word;
        } else {
            _cur = _test;
        }
    }

    if (_cur != "") array_push(_result, _cur);
    return _result;
};

/// @desc Text with a soft shadow and a fake-bold pass.
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

show_line = function(_i) {
    line_index    = _i;
    current_text  = lines[_i];
    visible_chars = 0;
};

end_dialogue = function() {
    if (is_closing) exit;
    is_closing  = true;
    close_timer = 1;
};

advance_line = function() {
    var _len = string_length(current_text);

    // First press finishes the typewriter, second moves on.
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
