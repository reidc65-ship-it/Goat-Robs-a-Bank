// =====================================================================
//  oBearCutscene -> Create
//  The Bear's Office storyboard, played once after the first successful
//  heist results card. Everything is drawn in the GUI layer so the movie
//  always fills the screen, independent of room views.
// =====================================================================

game_state_init();
global.level_complete = false;
global.dialogue_active = false;
global.game_paused = false;

// Marked at the start: even a skipped cutscene counts as seen, so the
// results card goes straight back to the farm on later heists.
if (!flag_get("bear_cutscene_seen")) {
    flag_set("bear_cutscene_seen");
}

// Eight storyboard panels, in frames. About 27 seconds in total.
durations = [180, 300, 190, 170, 190, 170, 250, 300];
bear_frames = [0, 0, 2, 2, 1, 2, 0, 2];
dialogue = [
    ["WOLF",     "BOSS! One of the banks just got cleaned out!"],
    ["WOLF",     "A goat broke into the vault and got away with the money."],
    ["BEAR",     "A... GOAT?"],
    ["BEAR",     "MY BANK? MY MONEY?!"],
    ["BEAR",     "YOU LET HIM WALK OUT OF MY BANK?"],
    ["BEAR",     "GET OUT THERE AND FIND HIM!"],
    ["CAMERA",   "A photo fell from the goat's pocket."],
    ["BEAR",     "I'll find that goat. And I'm getting my money back."]
];

beat      = 0;
beat_time = 0;

// Layout values are filled by the Draw GUI event, then used by the helpers.
ui_scale   = 1;
ui_origin_x = 0;
ui_origin_y = 0;

/// @desc Map virtual 1366x768 storyboard coordinates to the GUI surface.
ui_x = function(_v) {
    return ui_origin_x + _v * ui_scale;
};

ui_y = function(_v) {
    return ui_origin_y + _v * ui_scale;
};

ui_s = function(_v) {
    return _v * ui_scale;
};

ease = function(_t) {
    var _t2 = clamp(_t, 0, 1);
    return _t2 * _t2 * (3 - 2 * _t2);
};

/// @desc The wood-panelled office, window, door and floor.
draw_office = function() {
    // Back wall: warm brown at the top, darker near the floor.
    draw_rectangle_colour(ui_x(0), ui_y(0), ui_x(1366), ui_y(768),
                          make_colour_rgb(74, 52, 39),
                          make_colour_rgb(74, 52, 39),
                          make_colour_rgb(24, 19, 18),
                          make_colour_rgb(24, 19, 18), false);

    // Vertical panelling.
    draw_set_colour(make_colour_rgb(52, 36, 29));
    for (var _i = 0; _i < 15; _i++) {
        var _wx = _i * 96;
        draw_rectangle(ui_x(_wx), ui_y(0), ui_x(_wx + 9), ui_y(620), false);
    }
    draw_set_colour(make_colour_rgb(104, 75, 54));
    draw_rectangle(ui_x(0), ui_y(74), ui_x(1366), ui_y(84), false);
    draw_rectangle(ui_x(0), ui_y(596), ui_x(1366), ui_y(608), false);

    // Floor and a faded red rug under the desk.
    draw_set_colour(make_colour_rgb(39, 28, 24));
    draw_rectangle(ui_x(0), ui_y(608), ui_x(1366), ui_y(768), false);
    draw_set_colour(make_colour_rgb(92, 31, 38));
    draw_ellipse(ui_x(385), ui_y(626), ui_x(1080), ui_y(748), false);
    draw_set_colour(make_colour_rgb(201, 162, 39));
    draw_ellipse(ui_x(397), ui_y(638), ui_x(1068), ui_y(736), true);

    // Window onto the night city. This is where the desk is thrown.
    draw_rectangle_colour(ui_x(76), ui_y(96), ui_x(520), ui_y(396),
                          make_colour_rgb(16, 24, 46),
                          make_colour_rgb(16, 24, 46),
                          make_colour_rgb(43, 58, 86),
                          make_colour_rgb(43, 58, 86), false);
    draw_set_colour(make_colour_rgb(231, 231, 210));
    draw_circle(ui_x(170), ui_y(158), ui_s(34), false);
    draw_set_colour(make_colour_rgb(25, 32, 54));
    draw_circle(ui_x(187), ui_y(147), ui_s(31), false);

    // Skyline.
    draw_set_colour(make_colour_rgb(12, 17, 30));
    draw_rectangle(ui_x(82), ui_y(300), ui_x(142), ui_y(390), false);
    draw_rectangle(ui_x(152), ui_y(260), ui_x(210), ui_y(390), false);
    draw_rectangle(ui_x(220), ui_y(320), ui_x(288), ui_y(390), false);
    draw_rectangle(ui_x(300), ui_y(238), ui_x(362), ui_y(390), false);
    draw_rectangle(ui_x(374), ui_y(290), ui_x(442), ui_y(390), false);
    draw_rectangle(ui_x(454), ui_y(264), ui_x(514), ui_y(390), false);
    draw_set_colour(make_colour_rgb(242, 208, 107));
    draw_rectangle(ui_x(166), ui_y(284), ui_x(174), ui_y(296), false);
    draw_rectangle(ui_x(190), ui_y(284), ui_x(198), ui_y(296), false);
    draw_rectangle(ui_x(316), ui_y(266), ui_x(326), ui_y(280), false);
    draw_rectangle(ui_x(336), ui_y(266), ui_x(346), ui_y(280), false);

    // Heavy frame and crossbars.
    draw_set_colour(make_colour_rgb(28, 20, 17));
    draw_rectangle(ui_x(76), ui_y(96), ui_x(520), ui_y(396), true);
    draw_rectangle(ui_x(294), ui_y(96), ui_x(302), ui_y(396), false);
    draw_rectangle(ui_x(76), ui_y(240), ui_x(520), ui_y(248), false);
    draw_set_colour(make_colour_rgb(140, 105, 70));
    draw_rectangle(ui_x(70), ui_y(90), ui_x(526), ui_y(402), true);

    // Office door on the right.
    draw_rectangle_colour(ui_x(1064), ui_y(118), ui_x(1324), ui_y(618),
                          make_colour_rgb(92, 62, 43),
                          make_colour_rgb(92, 62, 43),
                          make_colour_rgb(48, 33, 26),
                          make_colour_rgb(48, 33, 26), false);
    draw_set_colour(make_colour_rgb(201, 162, 39));
    draw_rectangle(ui_x(1064), ui_y(118), ui_x(1324), ui_y(618), true);
    draw_set_colour(make_colour_rgb(31, 22, 19));
    draw_rectangle(ui_x(1090), ui_y(160), ui_x(1298), ui_y(270), true);
    gui_text(ui_x(1194), ui_y(215), "WOLF\nDIVISION", ui_s(1.15),
             make_colour_rgb(242, 208, 107), fa_center, 0.95);
    draw_set_colour(make_colour_rgb(201, 162, 39));
    draw_circle(ui_x(1290), ui_y(430), ui_s(11), false);

    // Desk lamp.
    draw_set_colour(make_colour_rgb(201, 162, 39));
    draw_rectangle(ui_x(1004), ui_y(272), ui_x(1012), ui_y(466), false);
    draw_triangle(ui_x(1010), ui_y(282), ui_x(1060), ui_y(326), ui_x(960), ui_y(326), false);
};

/// @desc A heavy oak desk. Its x is animated in panel 4.
draw_desk = function(_dx, _dy) {
    draw_set_colour(make_colour_rgb(40, 27, 21));
    draw_rectangle(ui_x(_dx - 190), ui_y(_dy + 12), ui_x(_dx - 160), ui_y(_dy + 116), false);
    draw_rectangle(ui_x(_dx + 160), ui_y(_dy + 12), ui_x(_dx + 190), ui_y(_dy + 116), false);

    draw_roundrect_colour_ext(ui_x(_dx - 220), ui_y(_dy - 30),
                              ui_x(_dx + 220), ui_y(_dy + 38),
                              ui_s(8), ui_s(8),
                              make_colour_rgb(132, 91, 59),
                              make_colour_rgb(74, 47, 32), false);
    draw_set_colour(make_colour_rgb(201, 162, 39));
    draw_roundrect_ext(ui_x(_dx - 220), ui_y(_dy - 30),
                       ui_x(_dx + 220), ui_y(_dy + 38), ui_s(8), ui_s(8), true);

    // Papers and a blotter on top.
    draw_set_colour(make_colour_rgb(231, 225, 208));
    draw_rectangle(ui_x(_dx - 120), ui_y(_dy - 46), ui_x(_dx - 18), ui_y(_dy - 26), false);
    draw_rectangle(ui_x(_dx + 40), ui_y(_dy - 44), ui_x(_dx + 140), ui_y(_dy - 24), false);
    draw_set_colour(make_colour_rgb(92, 31, 38));
    draw_rectangle(ui_x(_dx - 96), ui_y(_dy - 22), ui_x(_dx + 96), ui_y(_dy - 6), false);
};

/// @desc Bear pose from the photographed design sheet.
draw_bear = function(_x, _y, _frame, _scale, _alpha) {
    draw_set_colour(c_black);
    draw_set_alpha(0.18 * _alpha);
    draw_sprite_ext(sBearOffice, _frame, ui_x(_x + 12), ui_y(_y + 8),
                    ui_s(_scale), ui_s(_scale), 0, c_black, 0.18 * _alpha);
    draw_set_alpha(1);
    draw_sprite_ext(sBearOffice, _frame, ui_x(_x), ui_y(_y),
                    ui_s(_scale), ui_s(_scale), 0, c_white, _alpha);
};

/// @desc The wolf guard, drawn from the game's existing guard sprite.
draw_wolf = function(_x, _y, _scale, _rot, _alpha) {
    draw_sprite_ext(sWolfCop, 0, ui_x(_x), ui_y(_y),
                    ui_s(_scale), ui_s(_scale), _rot, c_white, _alpha);
};

/// @desc A speech/caption card in the visual-novel style.
draw_bubble = function(_bx, _by, _bw, _bh, _speaker, _text, _accent) {
    draw_roundrect_colour_ext(ui_x(_bx), ui_y(_by), ui_x(_bx + _bw), ui_y(_by + _bh),
                              ui_s(18), ui_s(18),
                              make_colour_rgb(22, 29, 41),
                              make_colour_rgb(10, 14, 22), false);
    draw_set_colour(_accent);
    draw_set_alpha(0.8);
    draw_roundrect_ext(ui_x(_bx), ui_y(_by), ui_x(_bx + _bw), ui_y(_by + _bh),
                       ui_s(18), ui_s(18), true);
    draw_set_alpha(1);

    gui_text(ui_x(_bx + 28), ui_y(_by + 30), _speaker + ":", ui_s(1.05),
             _accent, fa_left, 1);
    gui_text(ui_x(_bx + 28), ui_y(_by + 74), _text, ui_s(1.0),
             c_white, fa_left, 1);
};

/// @desc The security photo: first on the floor, then crushed in a fist.
draw_photo = function(_x, _y, _scale, _crushed) {
    var _pw = 92 * _scale;
    var _ph = 68 * _scale;

    draw_set_colour(c_white);
    draw_set_alpha(0.96);
    draw_rectangle(ui_x(_x - _pw * 0.5), ui_y(_y - _ph * 0.5),
                   ui_x(_x + _pw * 0.5), ui_y(_y + _ph * 0.5), false);
    draw_set_alpha(1);
    draw_set_colour(make_colour_rgb(31, 35, 44));
    draw_rectangle(ui_x(_x - _pw * 0.5), ui_y(_y - _ph * 0.5),
                   ui_x(_x + _pw * 0.5), ui_y(_y + _ph * 0.5), true);

    // Goat silhouette caught on the vault camera.
    draw_set_colour(make_colour_rgb(58, 52, 45));
    draw_ellipse(ui_x(_x - 10 * _scale), ui_y(_y - 4 * _scale),
                 ui_x(_x + 18 * _scale), ui_y(_y + 20 * _scale), false);
    draw_circle(ui_x(_x + 6 * _scale), ui_y(_y - 14 * _scale), ui_s(10 * _scale), false);
    draw_set_colour(make_colour_rgb(92, 31, 38));
    draw_rectangle(ui_x(_x - 30 * _scale), ui_y(_y + 20 * _scale),
                   ui_x(_x + 34 * _scale), ui_y(_y + 26 * _scale), false);

    if (_crushed) {
        draw_set_colour(make_colour_rgb(231, 225, 208));
        var _i;
        for (_i = 0; _i < 6; _i++) {
            var _cx = _x + ((_i * 17) mod 41) - 20;
            var _cy = _y + 18 + ((_i * 11) mod 13);
            draw_circle(ui_x(_cx), ui_y(_cy), ui_s(3 * _scale), false);
        }
    }
};
