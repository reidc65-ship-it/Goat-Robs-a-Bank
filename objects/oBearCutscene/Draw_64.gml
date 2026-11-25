// =====================================================================
//  oBearCutscene -> Draw GUI
//  The eight panels from Caleb Reid's Bear's Office storyboard.
// =====================================================================

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

ui_scale   = min(_gw / 1366, _gh / 768);
ui_origin_x = (_gw - 1366 * ui_scale) * 0.5;
ui_origin_y = (_gh - 768 * ui_scale) * 0.5;

var _p = clamp(beat_time / durations[beat], 0, 1);
var _e = ease(_p);
var _line = dialogue[beat];
var _speaker = _line[0];
var _text = _line[1];

draw_set_font(-1);
draw_set_alpha(1);
draw_set_colour(c_black);
draw_rectangle(0, 0, _gw, _gh, false);

draw_office();

// ---------------------------------------------------------------------
//  Panels 1-8: poses, props and character movement.
// ---------------------------------------------------------------------
var _bx = 760;
var _by = 585;
var _bear_scale = 1.0;
var _shake = 0;
var _wx = 1050;
var _wy = 540;
var _wscale = 2.7;
var _wrot = 0;
var _walpha = 1;
var _show_wolf = true;
var _desk_x = 760;
var _desk_y = 470;
var _show_desk = false;

switch (beat) {
    case 0: // Bear at his desk; the wolf bursts through the door.
        _wx = lerp(1360, 1060, _e);
        _show_desk = true;
        break;

    case 1: // Most of the dialogue happens here.
        _show_desk = true;
        break;

    case 2: // Bear is furious.
        _show_desk = true;
        _shake = sin(current_time / 28) * 3;
        break;

    case 3: // The desk goes out the window.
        _show_desk = true;
        _desk_x = lerp(760, 110, _e);
        _desk_y = lerp(470, 210, _e);
        _shake = sin(current_time / 22) * 4;
        break;

    case 4: // Bear grabs the wolf.
        _bx = 860;
        _bear_scale = 1.05;
        _wx = lerp(1060, 950, _e);
        _wy = 545;
        _wrot = -12 * _e;
        break;

    case 5: // Wolf is thrown out of the office.
        _bx = 860;
        _bear_scale = 1.05;
        _wx = lerp(950, 1450, _e);
        _wy = lerp(545, 205, _e);
        _wrot = -38 * _e;
        _walpha = 1 - 0.7 * _e;
        break;

    case 6: // The security photo on the floor.
        _bx = 700;
        break;

    case 7: // The photo is crushed.
        _bx = 700;
        _bear_scale = 1.05;
        break;
}

if (beat <= 3) {
    // Bear sits behind the desk for the first four panels.
    draw_bear(_bx + _shake, _by, bear_frames[beat], _bear_scale, 1);
    if (_show_wolf) draw_wolf(_wx, _wy, _wscale, _wrot, _walpha);
    draw_desk(_desk_x, _desk_y);
} else {
    draw_bear(_bx + _shake, _by, bear_frames[beat], _bear_scale, 1);
    if (_show_wolf) draw_wolf(_wx, _wy, _wscale, _wrot, _walpha);
}

// Door burst streaks on the entrance panel.
if (beat == 0 && _p < 0.55) {
    draw_set_colour(make_colour_rgb(242, 208, 107));
    draw_set_alpha(0.45 * (1 - _p / 0.55));
    draw_rectangle(ui_x(1070), ui_y(250 + _p * 90), ui_x(1320), ui_y(258 + _p * 90), false);
    draw_rectangle(ui_x(1070), ui_y(430 - _p * 70), ui_x(1320), ui_y(438 - _p * 70), false);
    draw_set_alpha(1);
}

// The thrown desk hits the glass near the end of panel 4.
if (beat == 3 && _p > 0.68) {
    gui_text(ui_x(292), ui_y(330), "CRASH!", ui_s(2.2),
             make_colour_rgb(242, 208, 107), fa_center, 1);
    draw_set_colour(c_white);
    draw_set_alpha(0.65);
    draw_line(ui_x(190), ui_y(300), ui_x(256), ui_y(344));
    draw_line(ui_x(330), ui_y(320), ui_x(398), ui_y(276));
    draw_line(ui_x(250), ui_y(266), ui_x(286), ui_y(216));
    draw_set_alpha(1);
}

// Red rage wash while Bear is losing his temper.
if (beat == 2 || beat == 3 || beat == 4) {
    draw_set_colour(make_colour_rgb(150, 24, 30));
    draw_set_alpha(0.08 + 0.05 * sin(current_time / 90));
    draw_rectangle(ui_x(0), ui_y(0), ui_x(1366), ui_y(768), false);
    draw_set_alpha(1);
}

// Security photo: dropped, then crushed in Bear's hand.
if (beat == 6) {
    var _photo_y = 678 - sin(current_time / 140) * 5;
    draw_photo(558, _photo_y, 1.0, false);
} else if (beat == 7) {
    var _photo_scale = lerp(1.0, 0.42, _e);
    draw_photo(760, 500 + _e * 30, _photo_scale, true);
    if (_p > 0.45) {
        gui_text(ui_x(760), ui_y(620), "CRUNCH.", ui_s(1.5),
                 make_colour_rgb(231, 225, 208), fa_center, 1);
    }
}

// ---------------------------------------------------------------------
//  Storyboard caption, title and progress.
// ---------------------------------------------------------------------
var _accent = make_colour_rgb(201, 162, 39);
var _bx_box, _bw;

if (_speaker == "WOLF") {
    _bx_box = 820;
    _bw = 470;
    _accent = make_colour_rgb(154, 178, 205);
} else if (_speaker == "CAMERA") {
    _bx_box = 360;
    _bw = 560;
    _accent = make_colour_rgb(231, 225, 208);
} else {
    _bx_box = 730;
    _bw = 560;
}

draw_bubble(_bx_box, 82, _bw, 154, _speaker, _text, _accent);

gui_text(ui_x(683), ui_y(42), "BEAR'S OFFICE", ui_s(1.7),
         make_colour_rgb(242, 208, 107), fa_center, 1);

var _titles = [
    "PANEL 1 - THE DESK", "PANEL 2 - THE REPORT", "PANEL 3 - FURIOUS",
    "PANEL 4 - OUT THE WINDOW", "PANEL 5 - GRABBED",
    "PANEL 6 - THROWN OUT", "PANEL 7 - THE PHOTO", "PANEL 8 - THE VOW"
];
gui_text(ui_x(683), ui_y(718), _titles[beat], ui_s(0.9),
         make_colour_rgb(231, 225, 208), fa_center, 0.78);

var _total = 0;
var _i = 0;
for (_i = 0; _i < array_length(durations); _i++) _total += durations[_i];
var _elapsed = 0;
for (_i = 0; _i < beat; _i++) _elapsed += durations[_i];
_elapsed += beat_time;

var _bar_x1 = 470;
var _bar_x2 = 896;
var _bar_y1 = 736;
var _bar_y2 = 744;
draw_roundrect_colour_ext(ui_x(_bar_x1), ui_y(_bar_y1), ui_x(_bar_x2), ui_y(_bar_y2),
                          ui_s(4), ui_s(4),
                          make_colour_rgb(28, 24, 22),
                          make_colour_rgb(28, 24, 22), false);
draw_roundrect_colour_ext(ui_x(_bar_x1), ui_y(_bar_y1),
                          ui_x(_bar_x1 + (_bar_x2 - _bar_x1) * clamp(_elapsed / _total, 0, 1)),
                          ui_y(_bar_y2), ui_s(4), ui_s(4),
                          make_colour_rgb(201, 162, 39),
                          make_colour_rgb(242, 208, 107), false);

if (beat_time > 90) {
    gui_text(ui_x(683), ui_y(760), "ENTER / SPACE / CLICK TO SKIP",
             ui_s(0.8), c_white, fa_center, 0.55);
}

draw_set_colour(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
