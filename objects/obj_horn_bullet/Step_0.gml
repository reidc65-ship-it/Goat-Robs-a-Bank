// obj_horn_bullet -> Step Event
switch (state) {
    case "out":
        image_angle += 20; // Spin while flying outward
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