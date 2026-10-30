// =====================================================================
//  oWolfCop -> Step
//  State machine: idle -> patrol -> chase -> attack -> stunned -> dead
// =====================================================================

// Freeze with the rest of the game while a menu / conversation is open.
if (game_is_frozen()) exit;

// --- Timers -----------------------------------------------------------
if (state_timer < 1000000) state_timer++; // prevent overflow

if (attack_cooldown > 0) attack_cooldown--;
if (stun_timer > 0) stun_timer--;
if (alert_timer > 0) alert_timer--;

// --- Alert level decay ------------------------------------------------
if (alert_level > 0 && alert_timer <= 0) {
    alert_level = max(alert_level - 1, 0);
    alert_timer = 60;
}

// --- State Machine ----------------------------------------------------
switch (state) {
    case "idle":
        // Brief pause before starting patrol
        if (state_timer > 30) {
            set_state("patrol");
        }
        break;

    case "patrol":
        do_patrol();
        check_sight();
        break;

    case "chase":
        do_chase();
        check_sight();
        break;

    case "attack":
        do_attack();
        break;

    case "stunned":
        if (stun_timer <= 0) {
            if (chase_target != noone && instance_exists(chase_target)) {
                set_state("chase");
            } else {
                return_to_patrol();
            }
        }
        break;

    case "dead":
        // Fade the body out, then remove it so the room stays clean.
        image_alpha = max(image_alpha - 0.02, 0);
        if (state_timer > 40) instance_destroy();
        break;
}

// --- Facing direction -------------------------------------------------
// Recompute the direction, but never let it become 0: a zero facing used
// to set image_xscale to 0 and make the wolf disappear at patrol points.
var _new_facing = 0;
if (state == "chase" && chase_target != noone && instance_exists(chase_target)) {
    _new_facing = sign(chase_target.x - x);
} else if (state == "patrol" && array_length(patrol_points) > 0) {
    // Clamp patrol_index to valid range
    patrol_index = clamp(patrol_index, 0, array_length(patrol_points) - 1);
    var _target = patrol_points[patrol_index];
    _new_facing = sign(_target.x - x);
}

if (_new_facing != 0) facing = _new_facing;
if (facing == 0) facing = 1;

image_xscale = abs(image_xscale);
if (facing < 0) image_xscale = -image_xscale;

// --- Physics ----------------------------------------------------------
// Simple gravity, snapped to the floor so the wolf never sinks into it.
if (!place_meeting(x, y + 4, oWall)) {
    y += 4;
} else {
    while (!place_meeting(x, y + 1, oWall)) y++;
}

/// =====================================================================
///  Helper Functions (defined inline for Step event)
/// =====================================================================

/// @desc Patrol between points
do_patrol = function() {
    if (array_length(patrol_points) == 0) {
        set_state("idle");
        return;
    }

    // Ensure patrol_index is valid
    patrol_index = clamp(patrol_index, 0, array_length(patrol_points) - 1);

    var _target = patrol_points[patrol_index];
    var _dx = _target.x - x;
    var _dist = abs(_dx);

    if (_dist < 8) {
        // Reached point, wait then move to next
        if (state_timer > patrol_wait) {
            // Calculate next index
            var _next_index = patrol_index + patrol_dir;
            
            // Check bounds and reverse if needed
            if (_next_index >= array_length(patrol_points)) {
                patrol_dir = -1;
                _next_index = array_length(patrol_points) - 2;
            } else if (_next_index < 0) {
                patrol_dir = 1;
                _next_index = 1;
            }
            
            patrol_index = _next_index;
            state_timer = 0;
        }
    } else {
        // Move toward point, but stop at a wall instead of walking into it.
        var _step = patrol_speed * sign(_dx);
        if (!place_meeting(x + _step, y, oWall)) {
            x += _step;
        } else {
            // Hit wall, reverse
            patrol_dir *= -1;
            patrol_index += patrol_dir;
            patrol_index = clamp(patrol_index, 0, array_length(patrol_points) - 1);
            state_timer = 0;
        }
    }
};

/// @desc Chase the player
do_chase = function() {
    if (chase_target == noone || !instance_exists(chase_target)) {
        lose_sight_timer = lose_sight_max;
        return;
    }

    var _dx = chase_target.x - x;
    var _dist = abs(_dx);

    // Move toward player, stopping at walls. If a wall blocks the route,
    // hop up so the guard can follow over low ledges.
    var _step = chase_speed * sign(_dx);
    if (_step != 0 && !place_meeting(x + _step, y, oWall)) {
        x += _step;
    } else if (place_meeting(x, y + 1, oWall)
            && !place_meeting(x, y - 32, oWall)) {
        y -= 8; // hop up
    }

    // Attack if in range
    if (_dist < attack_range && attack_cooldown <= 0) {
        set_state("attack");
    }
};

/// @desc Check if player is visible
check_sight = function() {
    var _can_see = can_see_player();

    if (_can_see) {
        // Player spotted!
        chase_target = instance_find(oPlayer, 0);
        last_known_x = chase_target.x;
        last_known_y = chase_target.y;
        lose_sight_timer = lose_sight_max;
        alert_level = 2;
        alert_timer = 120;
        
        if (state != "chase" && state != "attack") {
            set_state("chase");
        }
    } else if (state == "chase") {
        // Lost sight of player
        lose_sight_timer--;
        if (lose_sight_timer <= 0) {
            chase_target = noone;
            return_to_patrol();
        } else {
            // Move to last known position
            var _dx = last_known_x - x;
            if (abs(_dx) > 16) {
                x += chase_speed * 0.5 * sign(_dx);
            }
        }
    } else if (state == "patrol" && alert_level > 0) {
        // Suspicious - increase patrol speed slightly
        // (handled by alert_level visual)
    }
};

/// @desc Attack the player
do_attack = function() {
    if (chase_target == noone || !instance_exists(chase_target)) {
        set_state("chase");
        return;
    }

    var _dist = point_distance(x, y, chase_target.x, chase_target.y);

    if (_dist > attack_range * 1.5) {
        // Player moved away
        set_state("chase");
        return;
    }

    if (attack_cooldown <= 0) {
        // Perform attack
        attack_cooldown = attack_cooldown_max;
        
        // Damage player if close enough
        if (_dist <= attack_range) {
            // Call player's take_damage or similar
            if (variable_instance_exists(chase_target, "take_damage")) {
                chase_target.take_damage(damage, sign(chase_target.x - x));
            } else if (variable_instance_exists(chase_target, "hp")) {
                chase_target.hp -= damage;
                // Knockback
                chase_target.x += sign(chase_target.x - x) * knockback_force;
            }
        }
        
        // Visual feedback
        image_blend = c_orange;
        alarm[1] = 10;
    }
};