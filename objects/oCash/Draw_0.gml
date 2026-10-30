// =====================================================================
//  oCash -> Draw
//  Placeholder art drawn with primitives, so there are no extra sprites
//  to maintain. Shared by oGoldBar and oVaultLoot.
// =====================================================================

var _gold       = make_colour_rgb(201, 162, 39);
var _gold_light = make_colour_rgb(242, 208, 107);
var _gold_dark  = make_colour_rgb(126, 98, 22);

var _bob = sin((current_time + x * 7) / 260) * 3;
var _yy  = y + _bob;

switch (kind) {
    case "cash":
        // A banknote.
        draw_set_colour(make_colour_rgb(24, 88, 44));
        draw_rectangle(x - 19, _yy - 11, x + 19, _yy + 11, false);
        draw_set_colour(make_colour_rgb(92, 196, 110));
        draw_rectangle(x - 17, _yy - 9, x + 17, _yy + 9, false);
        draw_set_colour(make_colour_rgb(24, 88, 44));
        draw_circle(x, _yy, 6, false);
        break;

    case "gold":
        // A gold bar.
        draw_set_colour(_gold_dark);
        draw_rectangle(x - 22, _yy - 11, x + 22, _yy + 11, false);
        draw_set_colour(_gold);
        draw_rectangle(x - 19, _yy - 8, x + 19, _yy + 8, false);
        draw_set_colour(_gold_light);
        draw_rectangle(x - 15, _yy - 6, x + 15, _yy - 2, false);
        break;

    case "vault":
        // A bulging money sack, with a glow so it reads as the objective.
        draw_set_alpha(0.25 + 0.15 * sin(current_time / 200));
        draw_set_colour(_gold_light);
        draw_circle(x, _yy, 52, false);
        draw_set_alpha(1);

        draw_set_colour(_gold_dark);
        draw_circle(x, _yy + 6, 30, false);
        draw_rectangle(x - 9, _yy - 34, x + 9, _yy - 16, false);
        draw_set_colour(_gold);
        draw_circle(x, _yy + 6, 26, false);
        draw_set_colour(_gold_light);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_font(-1);
        draw_text_transformed(x, _yy + 6, "$", 2.4, 2.4, 0);
        break;
}

// Reset draw state for the next object.
draw_set_colour(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
