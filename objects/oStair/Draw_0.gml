// oStair -> Draw
// The sprite's origin is the low end of the walking surface. Its top edge
// lands at (x + 700, y - 640), matching the existing collision-free slope.

draw_sprite_ext(sprite_index, image_index, x, y, dir, 1, 0,
                image_blend, image_alpha);
