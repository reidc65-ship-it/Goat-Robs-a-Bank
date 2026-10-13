// Get player input (WASD)
key_left = keyboard_check(ord("A"));
key_right = keyboard_check(ord("D"));
key_jump = keyboard_check_pressed(ord("W"));
key_dash = keyboard_check_pressed(vk_shift);

// --- Dash Cooldown Management ---
if (dash_cooldown_timer > 0) {
    dash_cooldown_timer--;
}

// --- Trigger Dash ---
if (key_dash && !is_dashing && dash_cooldown_timer <= 0) {
    var _move = key_right - key_left;
    
    // Dash in movement direction if holding A/D, otherwise dash toward mouse
    if (_move != 0) {
        dash_dir = (_move > 0) ? 0 : 180;
    } else {
        dash_dir = point_direction(x, y, mouse_x, mouse_y);
    }
    
    is_dashing = true;
    dash_timer = dash_duration;
}

// --- Movement Logic ---
if (is_dashing) {
    // Override hsp and vsp for dash movement while ignoring gravity
    hsp = lengthdir_x(dashsp, dash_dir);
    vsp = lengthdir_y(dashsp, dash_dir);
    
    dash_timer--;
    if (dash_timer <= 0) {
        is_dashing = false;
        dash_cooldown_timer = dash_cooldown;
    }
} else {
    // Normal platformer movement
    var move = key_right - key_left;
    hsp = move * walksp;
    vsp = vsp + grv;

    // Jump check (W key)
    if (place_meeting(x, y + 1, oWall)) && (key_jump) {
        vsp = -7;
    }
}

// --- Horizontal Collision ---
if (place_meeting(x + hsp, y, oWall)) {
    while (!place_meeting(x + sign(hsp), y, oWall)) {
        x = x + sign(hsp);
    }
    hsp = 0;
}
x = x + hsp;

// --- Vertical Collision ---
if (place_meeting(x, y + vsp, oWall)) {
    while (!place_meeting(x, y + sign(vsp), oWall)) {
        y = y + sign(vsp);
    }
    vsp = 0;
}
y = y + vsp;

// --- Shooting Logic ---
if (mouse_check_button_pressed(mb_left)) {
    if (!instance_exists(obj_horn_bullet)) {
        var _horn = instance_create_layer(x, y, "Instances", obj_horn_bullet);
        var _dir = point_direction(x, y, mouse_x, mouse_y);
        
        with (_horn) {
            direction = _dir;
            image_angle = _dir;
            target_player = other.id;
        }
    }
}