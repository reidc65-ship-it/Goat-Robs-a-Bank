// oDoor -> Draw Event
draw_self();

// Flash white briefly when hit so the player reads the damage.
if (flash > 0) {
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_white, flash / 6);
}
