// =====================================================================
//  oCash -> Draw
//  Sprite art shared by oGoldBar and oVaultLoot. The bob still uses the
//  object's x/y so the pickups move exactly as before.
// =====================================================================

var _bob = sin((current_time + x * 7) / 260) * 3;
var _yy  = y + _bob;

var _spr = sCash;
if (kind == "gold") {
    _spr = sGoldBar;
} else if (kind == "vault") {
    _spr = sVaultLoot;

    // Keep the objective glow behind the money sack.
    draw_set_alpha(0.25 + 0.15 * sin(current_time / 200));
    draw_set_colour(make_colour_rgb(242, 208, 107));
    draw_circle(x, _yy, 52, false);
    draw_set_alpha(1);
}

draw_sprite(_spr, 0, x, _yy);

// Reset draw state for the next object.
draw_set_colour(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
