// oSkylight -> Draw
// A wide glass roof hatch. It is a child of oDoor, so it is solid and can
// be broken with the horn or a dash. The backdrop draws the steel frame;
// this event draws the glass itself so it disappears when smashed.

var _w = 64 * image_xscale;
var _h = 64 * image_yscale;
var _l = x - _w * 0.5;
var _r = x + _w * 0.5;
var _t = y - _h * 0.5;
var _b = y + _h * 0.5;

draw_set_alpha(1);
draw_set_colour(make_colour_rgb(28, 32, 42));
draw_rectangle(_l, _t, _r, _b, false);

draw_set_colour(make_colour_rgb(64, 118, 140));
draw_rectangle(_l + 5, _t + 5, _r - 5, _b - 5, false);
draw_set_colour(make_colour_rgb(102, 172, 196));
draw_rectangle(_l + 8, _t + 8, _r - 8, _t + 20, false);
draw_set_colour(make_colour_rgb(178, 220, 234));
draw_line_width(_l + 12, _t + 12, _r - 18, _t + 12, 2);
draw_line_width(_l + 16, _t + 17, _r - 28, _t + 17, 1);

// Steel mullions.
draw_set_colour(make_colour_rgb(42, 46, 58));
draw_line_width(x, _t + 3, x, _b - 3, 5);
draw_line_width(_l + 3, y, _r - 3, y, 4);

// Gold frame.
draw_set_colour(make_colour_rgb(201, 162, 39));
draw_rectangle(_l + 1, _t + 1, _r - 1, _b - 1, true);
draw_set_colour(make_colour_rgb(242, 208, 107));
draw_line_width(_l + 3, _t + 3, _r - 3, _t + 3, 2);

// Hit flash, matching oDoor.
if (flash > 0) {
    draw_set_alpha(flash / 6);
    draw_set_colour(c_white);
    draw_rectangle(_l, _t, _r, _b, false);
    draw_set_alpha(1);
}

draw_set_colour(c_white);
