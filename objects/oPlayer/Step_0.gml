// Freeze the goat while a menu or a conversation owns the screen. Without
// this the player keeps moving (and can still shoot) behind the overlay.
if (game_is_frozen()) exit;

// Damage invincibility counts down while the game is running.
if (invincible_timer > 0) invincible_timer--;
if (hint_timer > 0) hint_timer--;

// --- Spirit Form ---
if (spirit_timer > 0) spirit_timer--;
if (spirit_cooldown_timer > 0) spirit_cooldown_timer--;
if (keyboard_check_pressed(ord("Q")) && spirit_cooldown_timer <= 0 && upgrade_owned("spirit")) {
    spirit_timer = spirit_duration;
    spirit_cooldown_timer = spirit_cooldown;
}
image_alpha = (spirit_timer > 0) ? 0.45 : 1;

// Get player input (WASD or the arrow keys)
key_left = keyboard_check(ord("A")) || keyboard_check(vk_left);
key_right = keyboard_check(ord("D")) || keyboard_check(vk_right);
key_up = keyboard_check(ord("W")) || keyboard_check(vk_up);
key_down = keyboard_check(ord("S")) || keyboard_check(vk_down);
key_jump_pressed = keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up);
key_jump_released = !key_up && (keyboard_check_released(ord("W")) || keyboard_check_released(vk_up));
key_dash = keyboard_check_pressed(vk_shift);

// --- Dash Cooldown Management ---
if (dash_cooldown_timer > 0) {
    dash_cooldown_timer--;
}

// --- Trigger Dash ---
if (key_dash && !is_dashing && dash_cooldown_timer <= 0) {
    var _move = key_right - key_left;

    // The dash is a flat left / right burst. It never follows the mouse
    // and never changes height, so mid-air dashes stay predictable.
    if (_move != 0) facing = sign(_move);
    dash_dir = (facing < 0) ? 180 : 0;

    is_dashing = true;
    dash_timer = dash_duration;
    dash_hits = [];
    dash_exit_timer = 0;
    flag_set("tip_dash");
}

// --- Stair Attachment ---
// Find a sloped stair surface under the goat's feet. A jump deliberately
// leaves the stairs so they can be used as shortcuts.
on_stair = noone;
if (vsp >= -1) {
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
    air_jumps = upgrade_owned("doublejump") ? 1 : 0;
} else if (coyote_timer > 0) {
    coyote_timer--;
}

if (key_jump_pressed) {
    flag_set("tip_jump");
    jump_buffer_timer = jump_buffer_time;
} else if (jump_buffer_timer > 0) {
    jump_buffer_timer--;
}

// --- Movement Logic ---
if (is_dashing) {
    // Flat burst: keep the current height and ignore gravity.
    hsp = lengthdir_x(dashsp, dash_dir);
    vsp = 0;

    dash_timer--;
    if (dash_timer <= 0) {
        is_dashing = false;
        dash_cooldown_timer = dash_cooldown;

        // Carry the horizontal speed for a few frames so the dash eases
        // out instead of stopping dead.
        dash_exit_timer = dash_exit_time;
        dash_exit_hsp   = hsp;
    }
} else {
    // Normal platformer movement. On a stair, downhill movement is faster
    // and uphill movement is heavier, which gives the stairs their
    // Katana ZERO-style momentum.
    var move = key_right - key_left;
    var _speed = walksp;

    if (move != 0) facing = sign(move);

    if (on_stair != noone) {
        var _downhill = (on_stair.dir == 1 && move < 0)
                     || (on_stair.dir == -1 && move > 0);
        _speed = walksp * (_downhill ? 1.65 : 0.85);
    }

    hsp = move * _speed;

    // Dash tail: blend the leftover dash speed back into normal control.
    if (dash_exit_timer > 0) {
        var _tail    = dash_exit_timer / dash_exit_time; // 1 -> 0
        var _control = 1 - _tail;
        hsp = dash_exit_hsp * _tail * _tail + move * _speed * _control;
        dash_exit_timer--;
    }

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
    } else if (key_jump_pressed && air_jumps > 0) {
        // Double Jump upgrade
        vsp = -7;
        air_jumps--;
        jump_buffer_timer = 0;
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
    if (_wolf != noone && variable_instance_exists(_wolf, "take_damage")
        && !array_contains(dash_hits, _wolf)) {
        // A dash overlaps a guard for several frames, but only hits once.
        array_push(dash_hits, _wolf);
        _wolf.take_damage(2, sign(hsp));
    }

    // The bank skylight is a breakable floor. With flat dashes the goat
    // can't dive through it any more, so dashing across the glass smashes
    // it instead.
    var _glass = instance_position(x, y + 34, oSkylight);
    if (_glass != noone) {
        _glass.hp -= 2;
        _glass.flash = 6;
        if (_glass.hp <= 0) {
            effect_create_above(ef_explosion, _glass.x, _glass.y, 1, c_orange);
            instance_destroy(_glass);

            // Drop through the new hole instead of gliding over it.
            is_dashing = false;
            dash_exit_timer = 0;
            dash_cooldown_timer = dash_cooldown;
        }
    }

    // The Scout's training scarecrow only yields to a dash. Check the
    // current spot and the next one so a fast dash can't tunnel past it.
    var _scare = instance_place(x + hsp, y, oScarecrow);
    if (_scare == noone) _scare = instance_place(x, y, oScarecrow);
    if (_scare != noone && variable_instance_exists(_scare, "take_damage")
        && !array_contains(dash_hits, _scare)) {
        array_push(dash_hits, _scare);
        _scare.take_damage(1, sign(hsp), true);
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
    if (upgrade_owned("horn")) {
        throw_horn(false);
    } else {
        show_hint("Buy HORN THROW from the Elder!");
    }
}

// Charge Attack: hold right click, release at full charge.
if (upgrade_owned("charge")) {
    if (mouse_check_button_released(mb_right) && charge_timer >= charge_max) {
        throw_horn(true);
    }
    if (mouse_check_button(mb_right)) {
        charge_timer = min(charge_timer + 1, charge_max);
    } else {
        charge_timer = 0;
    }
}

// --- Animation ---------------------------------------------------------
// Throw and hurt are one-shots: they keep control for `anim_lock` frames,
// then hand back to whatever the movement state is doing.
if (anim_lock > 0) {
    anim_lock--;
    if (anim_lock <= 0) anim_state = "";
} else {
    var _on_ground = (on_stair != noone) || place_meeting(x, y + 1, oWall);

    if (!_on_ground) {
        // Launch / apex / fall each have their own painted frame.
        if (anim_state != "jump") animation_set("jump", 0);
        image_speed = 0;
        if (vsp < -3)      image_index = 1;
        else if (vsp < 2)  image_index = 2;
        else               image_index = 3;
    } else if (is_dashing) {
        animation_set("run", 0);
    } else if (abs(hsp) > 0.5) {
        animation_set("walk", 0);
    } else {
        animation_set("idle", 0);
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
