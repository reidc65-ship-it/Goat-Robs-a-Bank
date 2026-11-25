// =====================================================================
//  oScarecrow -> Step
// =====================================================================

// Menus and dialogue freeze the dummy with the rest of the world.
if (game_is_frozen()) exit;

if (state_timer < 1000000) state_timer++;

if (hit_flash > 0) {
    hit_flash--;
    if (hit_flash <= 0) image_blend = c_white;
}
if (wobble > 0) wobble--;

if (state == "dying") {
    image_alpha = max(image_alpha - 0.02, 0);
    if (state_timer > 70) instance_destroy();
}
