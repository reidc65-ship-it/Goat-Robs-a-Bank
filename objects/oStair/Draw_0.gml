// oStair -> Draw
// The sprite's origin is the low end of the walking surface. Its top edge
// lands at (x + 700, y - 640), matching the existing collision-free slope.

draw_set_colour(c_white);
draw_set_alpha(1);
draw_sprite_ext(sStair, 0, x, y, dir, 1, 0, c_white, 1);

draw_set_colour(c_white);
draw_set_alpha(1);
