// =====================================================================
//  oWolfCop -> Create
//  Bank guard wolf. Patrols until spotting player, then pursues.
//  Sight system: cone vision + line-of-sight check.
// =====================================================================

// These globals may not exist yet if the wolf is placed in a room that is
// launched directly from the Room Editor (no oPlayer yet).
if (!variable_global_exists("game_paused"))     global.game_paused = false;
if (!variable_global_exists("dialogue_active")) global.dialogue_active = false;

// --- Stats ------------------------------------------------------------
max_hp        = 3;
hp            = max_hp;
move_speed    = 2.5;
chase_speed   = 4.5;
patrol_speed  = 1.5;

// --- Sight System -----------------------------------------------------
sight_range   = 280;      // pixels
sight_angle   = 70;       // half-angle of vision cone (degrees)
sight_fov     = sight_angle * 2;
los_check     = true;     // check line of sight (walls block)

// --- State Machine ----------------------------------------------------
// "idle" -> "patrol" -> "chase" -> "attack" -> "stunned" -> "dead"
state         = "idle";
state_timer   = 0;

// --- Patrol -----------------------------------------------------------
patrol_points = [];       // set in Room Editor via creation code or path
patrol_index  = 0;
patrol_wait   = 60;       // frames to wait at each point
patrol_dir    = 1;        // 1 = forward, -1 = reverse

// --- Chase ------------------------------------------------------------
chase_target  = noone;
last_known_x  = 0;
last_known_y  = 0;
lose_sight_timer = 0;
lose_sight_max   = 120;   // frames to keep chasing after losing sight

// --- Combat -----------------------------------------------------------
attack_range  = 48;
attack_cooldown = 0;
attack_cooldown_max = 60;
damage        = 1;
knockback_force = 8;

// --- Stun -------------------------------------------------------------
stun_timer    = 0;
stun_max      = 90;

// --- Visuals ----------------------------------------------------------
sprite_idle   = sWolfCop;
sprite_walk   = sWolfCop;
sprite_chase  = sWolfCop;
sprite_attack = sWolfCop;
sprite_stun   = sWolfCop;

image_speed   = 0.2;
facing        = 1;        // 1 = right, -1 = left

// --- Alert indicator --------------------------------------------------
alert_level   = 0;        // 0 = calm, 1 = suspicious, 2 = alerted
alert_timer   = 0;
alert_sprite  = sWolfCop; // placeholder for "!" icon

// --- Init -------------------------------------------------------------
// Try to find patrol path from room
if (variable_instance_exists(id, "patrol_path")) {
    // Path assigned in Room Editor
} else {
    // Default: create two points left/right of spawn. Kept short enough
    // that the guard does not walk straight into a room wall.
    patrol_points[0] = { x: x - 96, y: y };
    patrol_points[1] = { x: x + 96, y: y };
}

// --- Helpers ----------------------------------------------------------

/// @desc Check if player is in vision cone and has line of sight
can_see_player = function() {
    if (!instance_exists(oPlayer)) return false;
    
    var _p = instance_find(oPlayer, 0);
    var _dx = _p.x - x;
    var _dy = _p.y - y;
    var _dist = point_distance(x, y, _p.x, _p.y);
    
    // Range check
    if (_dist > sight_range) return false;
    
    // Angle check (cone in front). image_angle is never rotated for this
    // sprite, so derive the looking direction from `facing`.
    var _look_dir = (facing >= 0) ? 0 : 180;
    var _angle_to = point_direction(x, y, _p.x, _p.y);
    var _diff = angle_difference(_angle_to, _look_dir);
    if (abs(_diff) > sight_angle) return false;
    
    // Line of sight check
    if (los_check) {
        if (collision_line(x, y, _p.x, _p.y, oWall, true, true) != noone) return false;
    }
    
    return true;
};

/// @desc Switch to new state
set_state = function(_new_state) {
    state = _new_state;
    state_timer = 0;
    
    switch (_new_state) {
        case "idle":
            image_speed = 0;
            break;
        case "patrol":
            image_speed = 0.15;
            break;
        case "chase":
            image_speed = 0.25;
            break;
        case "attack":
            image_speed = 0;
            attack_cooldown = attack_cooldown_max;
            break;
        case "stunned":
            image_speed = 0;
            stun_timer = stun_max;
            break;
        case "dead":
            image_speed = 0;
            break;
    }
};

/// @desc Take damage
take_damage = function(_amt, _knockback_dir) {
    if (state == "dead") return;
    
    hp -= _amt;
    
    if (hp <= 0) {
        set_state("dead");
    } else {
        set_state("stunned");
        // Apply knockback
        x += _knockback_dir * knockback_force * 0.5;
    }
    
    // Visual feedback
    image_blend = c_red;
    alarm[0] = 5; // reset blend
};

/// @desc Return to patrol after losing player
return_to_patrol = function() {
    if (array_length(patrol_points) > 0) {
        // Find closest patrol point
        var _closest = 0;
        var _best_dist = point_distance(x, y, patrol_points[0].x, patrol_points[0].y);
        for (var i = 1; i < array_length(patrol_points); i++) {
            var _d = point_distance(x, y, patrol_points[i].x, patrol_points[i].y);
            if (_d < _best_dist) {
                _best_dist = _d;
                _closest = i;
            }
        }
        patrol_index = _closest;
    }
    set_state("patrol");
};