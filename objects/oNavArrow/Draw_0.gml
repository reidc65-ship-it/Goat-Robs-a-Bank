// =====================================================================
//  oNavArrow -> Draw
// =====================================================================

if (until_skylight && !instance_exists(oSkylight)) exit;

// In a heist, the route reverses once the vault has been robbed.
var _dir   = arrow_dir;
var _label = arrow_label;
if (instance_exists(oHeist)) {
    var _heist = instance_find(oHeist, 0);
    if (_heist.vault_looted) {
        _dir   = after_dir;
        _label = after_label;
    }
}
if (_dir == "") exit;

// Frames in sNavArrow: 0 = left, 1 = right, 2 = down.
var _frame = 2;
if (_dir == "left")  _frame = 0;
if (_dir == "right") _frame = 1;

var _bob = sin(current_time / 180) * 8;
var _ax  = x;
var _ay  = y;

if (_dir == "left")       _ax -= _bob;
else if (_dir == "right") _ax += _bob;
else                      _ay += _bob;

draw_set_colour(c_white);
draw_set_alpha(1);
draw_sprite(sprite_index, _frame, _ax, _ay);

if (_label != "") {
    gui_text(x, y - 46, _label, 1.3, make_colour_rgb(255, 225, 130), fa_center, 1);
}

draw_set_colour(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
