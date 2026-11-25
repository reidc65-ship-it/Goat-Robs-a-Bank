// oSkylight -> Draw
// The sSkylight sprite (192x64) is attached to the object, while sDoor is
// kept as the explicit collision mask. The instance is scaled x3 for that
// mask, so draw the visual 1:1 centred on the instance.

draw_set_colour(c_white);
draw_set_alpha(1);
draw_sprite(sprite_index, image_index, x, y);

// Hit flash, matching oDoor.
if (flash > 0) {
    draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, 0, c_white, flash / 6);
}
