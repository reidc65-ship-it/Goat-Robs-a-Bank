// obj_horn_bullet -> Step Event

// Hold still while a menu, conversation or results card is up. `speed` is
// a built-in that keeps moving the instance unless it is cleared.
if (game_is_frozen()) {
    if (!is_frozen) {
        is_frozen = true;
        saved_speed = speed;
        speed = 0;
    }
    exit;
}
if (is_frozen) {
    is_frozen = false;
    speed = saved_speed;
}

switch (state) {
    case "out":
        image_angle += 20; // Spin while flying outward

        travelled += speed;
        if (travelled >= max_range
            || x < 0 || x > room_width || y < 0 || y > room_height) {
            speed = 0;
            state = "return";
        }
        break;

    case "return":
        image_angle -= 25; // Spin in reverse on the way back

        if (instance_exists(target_player)) {
            // Move directly toward the player's current position
            move_towards_point(target_player.x, target_player.y, return_speed);

            // Destroy the horn when it reaches the player
            if (point_distance(x, y, target_player.x, target_player.y) <= return_speed) {
                instance_destroy();
            }
        } else {
            instance_destroy();
        }
        break;
}
