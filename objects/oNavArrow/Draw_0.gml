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

var _bob = sin(current_time / 180) * 8;
var _ax  = x;
var _ay  = y;

// Unit vector for the pointing direction.
var _ux = 0;
var _uy = 1;
if (_dir == "left")  { _ux = -1; _uy = 0; }
if (_dir == "right") { _ux =  1; _uy = 0; }

_ax += _ux * _bob;
_ay += _uy * _bob;

// Perpendicular, for the width of the arrow.
var _px = -_uy;
var _py =  _ux;

// Black outline first, then the yellow arrow on top.
for (var i = 0; i < 2; i++) {
    var _o = (i == 0) ? 4 : 0;
    draw_set_colour((i == 0) ? c_black : make_colour_rgb(255, 214, 64));

    // Head
    draw_triangle(_ax + _ux * (26 + _o) ,                 _ay + _uy * (26 + _o),
                  _ax + _px * (24 + _o) - _ux * _o,       _ay + _py * (24 + _o) - _uy * _o,
                  _ax - _px * (24 + _o) - _ux * _o,       _ay - _py * (24 + _o) - _uy * _o, false);

    // Stem
    var _sw = 9 + _o;
    var _sl = 26 + _o;
    draw_triangle(_ax + _px * _sw, _ay + _py * _sw,
                  _ax - _px * _sw, _ay - _py * _sw,
                  _ax - _ux * _sl + _px * _sw, _ay - _uy * _sl + _py * _sw, false);
    draw_triangle(_ax - _px * _sw, _ay - _py * _sw,
                  _ax - _ux * _sl + _px * _sw, _ay - _uy * _sl + _py * _sw,
                  _ax - _ux * _sl - _px * _sw, _ay - _uy * _sl - _py * _sw, false);
}

if (_label != "") {
    draw_set_font(-1);
    gui_text(x, y - 46, _label, 1.3, make_colour_rgb(255, 225, 130), fa_center, 1);
}

draw_set_colour(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
