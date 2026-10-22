hsp = 0;
vsp = 0;
grv = 0.3;
walksp = 4;

// Dash variables
dashsp = 14;            // Speed while dashing
dash_duration = 10;     // How long the dash lasts (in frames)
dash_timer = 0;         // Remaining dash time
dash_cooldown = 30;     // Time between dashes (30 frames = 0.5 sec)
dash_cooldown_timer = 0;// Remaining cooldown time
is_dashing = false;     // State flag
dash_dir = 0;           // Dash direction

// Platforming feel: forgiving edges and remembered jump presses.
coyote_time = 6;        // frames you can still jump after leaving a ledge
coyote_timer = 0;
jump_buffer_time = 6;   // frames a jump press is remembered before landing
jump_buffer_timer = 0;
max_fall = 16;          // terminal velocity

// Stair traversal (Katana ZERO style). Stairs are non-solid objects; the
// player finds the nearest walkable surface and follows it.
on_stair = noone;
stair_surface = 0;

/// @desc Find the lowest nearby stair surface under the player's feet.
/// At a switchback landing two flights meet, so choosing the lowest
/// surface makes the goat continue downhill instead of catching the
/// uphill flight behind them.
find_stair = function(_px, _py) {
    var _best = noone;
    var _best_y = -999999;
    var _count = instance_number(oStair);

    for (var _i = 0; _i < _count; _i++) {
        var _s = instance_find(oStair, _i);
        if (instance_exists(_s)) {
            var _high_x = _s.x + _s.dir * _s.w;
            var _min_x = min(_s.x, _high_x);
            var _max_x = max(_s.x, _high_x);

            // Use the exact flight span. Extra padding here would pull the
            // goat below a landing at the low end of a flight.
            if (_px >= _min_x && _px <= _max_x) {
                var _t = clamp((_px - _s.x) / (_s.dir * _s.w), 0, 1);
                var _sy = _s.y - _t * _s.h;

                // Wide vertical tolerance catches a fast fall onto the flight.
                if (_py >= _sy - 40 && _py <= _sy + 40) {
                    if (_sy > _best_y) {
                        _best_y = _sy;
                        _best = _s;
                    }
                }
            }
        }
    }

    stair_surface = _best_y;
    return _best;
};

// Health
max_hp = 3;
hp = max_hp;
invincible_timer = 0;

// --- Ensure global systems exist (pause menu, dialogue, balance) ---
if (!variable_global_exists("game_paused"))     global.game_paused = false;
if (!variable_global_exists("dialogue_active")) global.dialogue_active = false;
if (!variable_global_exists("bank_balance"))    global.bank_balance = 0;

// Create persistent pause menu controller if missing
if (!instance_exists(oPauseMenu)) {
    instance_create_depth(0, 0, -10000, oPauseMenu);
}

// --- Scene transitions can request a specific spawn point ------------
// The barn/farm door triggers set these just before room_goto().
if (!variable_global_exists("spawn_x")) {
    global.spawn_x = -1;
    global.spawn_y = -1;
}
if (global.spawn_x >= 0) {
    if (room == rm_farm || room == rm_barn) {
        x = global.spawn_x;
        y = global.spawn_y;
    }
    global.spawn_x = -1;
    global.spawn_y = -1;
}

// Camera follow state (driven in the Step event). Start on the player,
// clamped to the room, so arriving through a door doesn't pan from x=0.
cam_x = clamp(x - 683, 0, max(0, room_width  - 1366));
cam_y = clamp(y - 300, 0, max(0, room_height - 768));

/// @desc Take damage and handle knockback/invincibility
take_damage = function(_amt, _knockback_dir) {
    if (invincible_timer > 0 || hp <= 0) return;
    
    hp -= _amt;
    invincible_timer = 60; // 1 second invincibility
    
    // Knockback
    x += _knockback_dir * 8;
    vsp = -4; // Pop up slightly
    
    // Visual feedback
    image_blend = c_red;
    alarm[0] = 10;
    
    if (hp <= 0) {
        // Death - restart room
        room_restart();
    }
};
