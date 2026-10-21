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

// --- Coyote time + jump buffering ---
var _grounded = place_meeting(x, y + 1, oWall) || place_meeting(x, y + 1, oStair);
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

// --- Stair State Variables ---
// Track if we're currently on a stair landing (flat top piece)
var _on_stair_landing = false;
var _stair_landing_inst = noone;

// Check if standing on a stair landing (flat piece with is_landing = true)
var _landing_check = instance_place(x, y + 1, oStair);
if (_landing_check != noone && _landing_check.is_landing) {
    _on_stair_landing = true;
    _stair_landing_inst = _landing_check;
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
    if (vsp > max_fall) vsp = max_fall;

    // Jump (allowed slightly after walking off a ledge, or if pressed just
    // before landing)
    if (coyote_timer > 0 && jump_buffer_timer > 0) {
        vsp = -7;
        coyote_timer = 0;
        jump_buffer_timer = 0;
    }

    // Variable jump height: releasing W early cuts the jump short
    if (key_jump_released && vsp < -3) {
        vsp = -3;
    }
}

// --- Dashing smashes doors open ---
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
}

// =====================================================================
//  STAIR COLLISION SYSTEM (Katana ZERO style)
// =====================================================================

// --- Horizontal Stair Collision (Auto-climb) ---
// Check for stairs in our horizontal path BEFORE regular wall collision
var _stair_climbed = false;
if (hsp != 0 && !is_dashing) {
    var _stair_ahead = instance_place(x + hsp, y, oStair);
    if (_stair_ahead != noone && !_stair_ahead.is_landing) {
        // We're walking into a stair piece - determine stair direction
        var _stair_dir = _stair_ahead.stair_direction; // 1 = right/up, -1 = left/up
        var _move_dir = sign(hsp); // 1 = right, -1 = left
        
        // Only auto-climb if moving in the direction the stair goes up
        if (_move_dir == _stair_dir) {
            // Auto-climb: move horizontally AND vertically up
            var _step_h = _stair_ahead.stair_step_height; // pixels per step (default 16)
            
            // Move horizontally into the stair
            while (!place_meeting(x + sign(hsp), y, oWall) && 
                   !place_meeting(x + sign(hsp), y, oStair)) {
                x = x + sign(hsp);
            }
            
            // Move up by step height (climb the stair)
            var _climb_amount = min(_step_h, abs(hsp)); // climb proportional to horizontal move
            for (var i = 0; i < _climb_amount; i++) {
                if (!place_meeting(x, y - 1, oWall) && !place_meeting(x, y - 1, oStair)) {
                    y -= 1;
                } else {
                    break;
                }
            }
            
            // Clear horizontal speed since we climbed
            hsp = 0;
            _stair_climbed = true;
        }
    }
}

// --- Horizontal Collision (Walls) ---
// Skip if we already climbed a stair this frame
if (!_stair_climbed && place_meeting(x + hsp, y, oWall)) {
    while (!place_meeting(x + sign(hsp), y, oWall)) {
        x = x + sign(hsp);
    }
    hsp = 0;
}
x = x + hsp;

// --- Vertical Stair Collision (Landing drop-through) ---
// If standing on a stair landing and holding DOWN, drop through
var _drop_through = false;
if (_on_stair_landing && key_down && vsp >= 0) {
    _drop_through = true;
    // Move down slightly to clear the landing
    y += 4;
}

// --- Vertical Collision ---
// Check collision with walls AND stairs (unless dropping through landing)
var _check_wall = place_meeting(x, y + vsp, oWall);
var _check_stair = (!_drop_through) ? place_meeting(x, y + vsp, oStair) : false;

if (_check_wall || _check_stair) {
    while (!place_meeting(x, y + sign(vsp), oWall) && 
           (!_drop_through || !place_meeting(x, y + sign(vsp), oStair))) {
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