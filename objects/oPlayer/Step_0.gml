// Freeze the goat while a menu or a conversation owns the screen. Without
// this the player keeps moving (and can still shoot) behind the overlay.
if (global.game_paused || global.dialogue_active) exit;

// Damage invincibility counts down while the game is running.
if (invincible_timer > 0) invincible_timer--;

// Get player input (WASD)
key_left = keyboard_check(ord("A"));
key_right = keyboard_check(ord("D"));
key_up = keyboard_check(ord("W"));
key_down = keyboard_check(ord("S"));
key_jump_pressed = keyboard_check_pressed(ord("W"));
key_jump_released = keyboard_check_released(ord("W"));
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

// --- Stair Attachment ---
// Find a sloped stair surface under the goat's feet. A vertical dash or
// jump deliberately leaves the stairs so they can be used as shortcuts.
on_stair = noone;
var _dash_vertical = is_dashing && abs(lengthdir_y(dashsp, dash_dir)) > 4;
if (!_dash_vertical && vsp >= -1) {
    var _found_stair = find_stair(x, y + 32);
    if (_found_stair != noone) {
        on_stair = _found_stair;
        y = stair_surface - 32;
        vsp = 0;
        coyote_timer = coyote_time;
    }
}

// --- Coyote time + jump buffering ---
var _grounded = place_meeting(x, y + 1, oWall) || (on_stair != noone);
if (_grounded) {
    coyote_timer = coyote_time;
} else if (coyote_timer > 0) {
    coyote_timer--;
}

if (key_jump_pressed) {
    jump_buffer_timer = jump_buffer_time;
} else if (jump_buffer_timer > 0) {
    jump_buffer_timer--;
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
    // Normal platformer movement. On a stair, downhill movement is faster
    // and uphill movement is heavier, which gives the stairs their
    // Katana ZERO-style momentum.
    var move = key_right - key_left;
    var _speed = walksp;

    if (on_stair != noone) {
        var _downhill = (on_stair.dir == 1 && move < 0)
                     || (on_stair.dir == -1 && move > 0);
        _speed = walksp * (_downhill ? 1.65 : 0.85);
    }

    hsp = move * _speed;

    if (on_stair != noone) {
        vsp = 0;
    } else {
        vsp = vsp + grv;
        if (vsp > max_fall) vsp = max_fall;
    }

    // Jump (allowed slightly after walking off a ledge, or if pressed just
    // before landing, and from a stair surface)
    if (coyote_timer > 0 && jump_buffer_timer > 0) {
        vsp = -7;
        coyote_timer = 0;
        jump_buffer_timer = 0;
        on_stair = noone;
    }

    // Variable jump height: releasing W early cuts the jump short
    if (key_jump_released && vsp < -3) {
        vsp = -3;
    }
}

// --- Dashing smashes doors open and bowls over guards ---
if (is_dashing) {
    var _door = instance_place(x + sign(hsp), y + sign(vsp), oDoor);
    if (_door != noone) {
        _door.hp -= 2;
        _door.flash = 6;
        if (_door.hp <= 0) {
            effect_create_above(ef_explosion, _door.x, _door.y, 1, c_orange);
            instance_destroy(_door);
        }
    }

    var _wolf = instance_place(x + hsp, y, oWolfCop);
    if (_wolf != noone && variable_instance_exists(_wolf, "take_damage")) {
        _wolf.take_damage(2, sign(hsp));
    }
}

// =====================================================================
//  SIMPLE PLATFORMER COLLISION (Wall only)
// =====================================================================

// --- Horizontal Collision (Walls) ---
// While following a stair, skip wall collision. The landing slabs share
// the stair endpoints, and the goat's shoulder overlaps their side face
// by a few pixels for one frame when stepping on or off a flight. The
// flights themselves are in open shafts, so there are no real walls to
// catch on while `on_stair` is set.
if (on_stair == noone && place_meeting(x + hsp, y, oWall)) {
    while (!place_meeting(x + sign(hsp), y, oWall)) {
        x = x + sign(hsp);
    }
    hsp = 0;
}
x = x + hsp;

// --- Stay on the stairs after the horizontal move ---
// Re-find the surface at the new x. If we walked off either end, drop
// back into normal gravity next frame. When walking UP a flight and
// crossing the top edge, snap to the landing's top surface; otherwise the
// goat's last sloped-foot position would be a few pixels below the slab
// and the solid landing would catch them.
if (on_stair != noone) {
    var _old_stair = on_stair;
    var _stair_now = find_stair(x, y + 32);
    if (_stair_now != noone) {
        on_stair = _stair_now;
        y = stair_surface - 32;
        vsp = 0;
    } else {
        var _top_x = _old_stair.x + _old_stair.dir * _old_stair.w;
        var _top_y = _old_stair.y - _old_stair.h;
        var _crossed_top = ((_old_stair.dir == -1 && x <= _top_x)
                         || (_old_stair.dir == 1  && x >= _top_x));
        if (_crossed_top) y = _top_y - 32;
        on_stair = noone;
    }
}

// --- Vertical Collision (Walls) ---
if (vsp != 0 && place_meeting(x, y + vsp, oWall)) {
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

// --- Camera ---
// Follow the goat through the tower. The legacy view_xview/view_yview
// variables are read-only in GameMaker Studio 2, so the view has to be
// moved through its camera instead.
if (view_visible[0] && view_camera[0] != -1) {
    var _cam = view_camera[0];
    var _vw  = camera_get_view_width(_cam);
    var _vh  = camera_get_view_height(_cam);

    // Centre the goat horizontally, sit it a little above the middle so
    // there is always more screen below to read the next drop.
    var _tx = clamp(x - _vw * 0.5,  0, room_width  - _vw);
    var _ty = clamp(y - _vh * 0.40, 0, room_height - _vh);

    // Smooth, snappy follow. The clamps keep the camera inside the room.
    cam_x = clamp(lerp(cam_x, _tx, 0.25), 0, room_width  - _vw);
    cam_y = clamp(lerp(cam_y, _ty, 0.25), 0, room_height - _vh);

    camera_set_view_pos(_cam, cam_x, cam_y);
}
