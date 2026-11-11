// =====================================================================
//  oHeist -> Draw GUI
//  Results card, shown after an escape or a failed heist.
// =====================================================================

if (state == "active") exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _won = (state == "won");

var _gold_light = make_colour_rgb(242, 208, 107);
var _title_col  = _won ? _gold_light : make_colour_rgb(235, 90, 80);

draw_set_font(-1);

// --- Dim the frozen level ---------------------------------------------
draw_set_colour(c_black);
draw_set_alpha(0.72);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);

// --- Panel ------------------------------------------------------------
var _px1 = _gw * 0.5 - 380;
var _px2 = _gw * 0.5 + 380;
var _py1 = 130;
var _py2 = 630;

draw_roundrect_colour_ext(_px1, _py1, _px2, _py2, 24, 24,
                          make_colour_rgb(22, 29, 41),
                          make_colour_rgb(10, 14, 22), false);
draw_set_colour(make_colour_rgb(201, 162, 39));
draw_roundrect_ext(_px1, _py1, _px2, _py2, 24, 24, true);

// --- Text -------------------------------------------------------------
var _cx = _gw * 0.5;

gui_text(_cx, 200, card_title, 3.6, _title_col, fa_center, 1);
gui_text(_cx, 256, card_line, 1.25, c_white, fa_center, 0.75);

if (_won) {
    gui_text(_cx, 340, "STOLEN  $" + string(loot), 2.6, _gold_light, fa_center, 1);
    gui_text(_cx, 400, "TIME LEFT  " + frames_to_clock(time_left), 1.5, c_white, fa_center, 0.85);
} else {
    gui_text(_cx, 340, "LOST  $" + string(loot), 2.6, _title_col, fa_center, 1);
    gui_text(_cx, 400, "Nothing from this job reaches the bank.", 1.5, c_white, fa_center, 0.85);
}

gui_text(_cx, 460, "BANK BALANCE  $" + string(global.bank_balance), 1.9, _gold_light, fa_center, 1);

if (card_news != "") {
    gui_text(_cx, 515, card_news, 1.15, c_white, fa_center, 0.8);
}

if (card_timer > 45) {
    var _pulse = 0.55 + 0.45 * sin(current_time / 260);
    gui_text(_cx, 570, "PRESS ENTER TO RETURN TO THE FARM", 1.5, c_white, fa_center, _pulse);
}

draw_set_colour(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
