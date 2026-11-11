// =====================================================================
//  oHeist -> Draw
//  Floating pickup text, in world space.
// =====================================================================

draw_set_font(-1);

for (var i = 0; i < array_length(popups); i++) {
    var _pop = popups[i];
    gui_text(_pop.x, _pop.y, _pop.text, 1.5, _pop.col, fa_center, min(_pop.life / 20, 1));
}

draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
