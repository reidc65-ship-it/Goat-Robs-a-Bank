// oStair -> Draw
// Marble-and-gold bank staircase with a red runner and a brass handrail.
// The player walks along the smooth diagonal surface, so the step detail
// is drawn around that line instead of above it.

var _lx = x;
var _ly = y;
var _hx = x + dir * w;
var _hy = y - h;

var _stone_dark  = make_colour_rgb(24, 26, 36);
var _stone_mid   = make_colour_rgb(52, 56, 70);
var _stone_light = make_colour_rgb(104, 110, 128);
var _gold        = make_colour_rgb(201, 162, 39);
var _gold_light  = make_colour_rgb(242, 208, 107);
var _carpet      = make_colour_rgb(108, 28, 42);
var _carpet_dark = make_colour_rgb(68, 16, 27);

// --- Solid triangular underside of the staircase --------------------
draw_set_alpha(1);
draw_set_colour(_stone_dark);
if (dir == 1) {
    draw_triangle(_lx, _ly, _hx, _hy, _hx, _ly + 34, false);
    draw_triangle(_lx, _ly, _hx, _ly + 34, _lx, _ly + 34, false);
} else {
    draw_triangle(_lx, _ly, _hx, _hy, _hx, _ly + 34, false);
    draw_triangle(_lx, _ly, _hx, _ly + 34, _lx, _ly + 34, false);
}

// Side stringer along the underside.
draw_set_colour(_stone_mid);
draw_line_width(_lx, _ly + 34, _hx, _hy + 34, 6);

// --- Step treads ------------------------------------------------------
// Small steps are laid along the walk line. Keeping them centred on the
// smooth line lets the goat glide down the flight at speed.
var _steps = 48;
var _run = w / _steps;

// Red carpet runner.
draw_set_colour(_carpet);
draw_line_width(_lx, _ly + 7, _hx, _hy + 7, 16);
draw_set_colour(_carpet_dark);
draw_line_width(_lx, _ly + 12, _hx, _hy + 12, 3);

for (var i = 0; i < _steps; i++) {
    var _t = (i + 0.5) / _steps;
    var _sx = _lx + dir * _t * w;
    var _sy = _ly - _t * h;
    var _half = _run * 0.5;

    // Marble tread edge.
    draw_set_colour(_stone_light);
    draw_rectangle(min(_sx - _half, _sx + _half), _sy - 3,
                   max(_sx - _half, _sx + _half), _sy + 1, false);

    // Gold nosing.
    draw_set_colour(_gold);
    draw_rectangle(min(_sx - _half, _sx + _half), _sy - 4,
                   max(_sx - _half, _sx + _half), _sy - 2, false);

    // Short riser shadow below the tread.
    draw_set_colour(_stone_mid);
    draw_rectangle(_sx + dir * _half - 2, _sy,
                   _sx + dir * _half + 2, _sy + 12, false);

    // Red runner inlay on each step.
    draw_set_colour(_carpet);
    draw_rectangle(min(_sx - _half + 4, _sx + _half - 4), _sy + 2,
                   max(_sx - _half + 4, _sx + _half - 4), _sy + 8, false);
}

// Highlight the actual walking edge.
draw_set_colour(_gold_light);
draw_line_width(_lx, _ly, _hx, _hy, 2);

// --- Brass handrail ---------------------------------------------------
// The rail follows the slope at head height. Posts are spaced along it.
var _rail = 56;
draw_set_colour(_gold);
draw_line_width(_lx, _ly - _rail, _hx, _hy - _rail, 4);

for (var p = 1; p <= 5; p++) {
    var _pt = p / 6;
    var _px = _lx + dir * _pt * w;
    var _py = _ly - _pt * h;
    draw_set_colour(_gold);
    draw_line_width(_px, _py - 3, _px, _py - _rail, 3);
    draw_set_colour(_gold_light);
    draw_rectangle(_px - 3, _py - _rail - 3, _px + 3, _py - _rail + 3, false);
}

// End caps.
draw_set_colour(_gold_light);
draw_circle(_lx, _ly - _rail, 4, false);
draw_circle(_hx, _hy - _rail, 4, false);

draw_set_colour(c_white);
draw_set_alpha(1);
