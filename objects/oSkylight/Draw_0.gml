// oSkylight -> Draw
// The roof hatch art is 192x64. The instance keeps its inherited 64x64
// sDoor mask (scaled x3 in the Room Editor), so draw the art 1:1 centred
// on the instance instead of using draw_self().

draw_set_colour(c_white);
draw_set_alpha(1);
draw_sprite(sSkylight, 0, x, y);

// Hit flash, matching oDoor.
if (flash > 0) {
    draw_sprite_ext(sSkylight, 0, x, y, 1, 1, 0, c_white, flash / 6);
}
