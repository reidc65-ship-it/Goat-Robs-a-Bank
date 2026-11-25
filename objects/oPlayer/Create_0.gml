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
dash_dir = 0;           // 0 = right, 180 = left. Never vertical.
dash_hits = [];         // Guards already hit by the current dash
dash_exit_time = 8;     // frames of carried momentum after a dash
dash_exit_timer = 0;
dash_exit_hsp = 0;

// Platforming feel: forgiving edges and remembered jump presses.
coyote_time = 6;        // frames you can still jump after leaving a ledge
coyote_timer = 0;
jump_buffer_time = 6;   // frames a jump press is remembered before landing
jump_buffer_timer = 0;
max_fall = 16;          // terminal velocity
air_jumps = 0;          // mid-air jumps left (Double Jump upgrade)

// Charge Attack upgrade: hold right click, release at full charge.
charge_timer = 0;
charge_max = 45;

// Spirit Form upgrade: Q makes the goat untouchable and unseen.
spirit_duration = 180;        // 3 seconds
spirit_cooldown = 1200;       // 20 seconds, from activation
spirit_timer = 0;
spirit_cooldown_timer = 0;

// Which way the goat is drawn. Only affects drawing, not the collision mask.
facing = 1;

// --- Character animation -------------------------------------------------
// The player has a dedicated side-view sprite per state. The original
// front-facing sPlayer is kept as the collision mask so every level that was
// tuned against the old 54x61 box still feels identical.
anim_idle  = sGoatIdle;
anim_walk  = sGoatWalk;
anim_run   = sGoatRun;
anim_jump  = sGoatJump;
anim_throw = sGoatThrow;
anim_hurt  = sGoatHurt;

sprite_index = anim_idle;
mask_index   = sPlayer;
image_speed  = 1;

anim_state = "idle";
anim_lock  = 0;      // frames a one-shot animation keeps control

/// @desc Switches to an animation state. `_hold` keeps one-shot animations
///       (throw, hurt) on screen for a fixed number of frames.
animation_set = function(_state, _hold) {
    if (anim_state == _state) return;

    anim_state = _state;
    image_index = 0;
    image_speed = 1;
    anim_lock = _hold;

    switch (_state) {
        case "idle":  sprite_index = anim_idle;  break;
        case "walk":  sprite_index = anim_walk;  break;
        case "run":   sprite_index = anim_run;   break;
        case "jump":  sprite_index = anim_jump; image_speed = 0; break;
        case "throw": sprite_index = anim_throw; break;
        case "hurt":  sprite_index = anim_hurt;  break;
    }
};

// Short message over the goat's head, e.g. when the horn isn't owned yet.
hint_text = "";
hint_timer = 0;

// Stair traversal. oStair only draws the flight; scrStairSurface sets this
// flag during Step so our movement code can follow the slope.
on_stair = noone;

// Health
max_hp = 3;
hp = max_hp;
invincible_timer = 0;

// --- Ensure global systems exist (pause menu, dialogue, progress) ---
game_state_init();

// Create persistent pause menu controller if missing
if (!instance_exists(oPauseMenu)) {
    instance_create_depth(0, 0, -10000, oPauseMenu);
}

// The HUD isn't persistent: each room's player brings its own.
if (!instance_exists(oHud)) {
    instance_create_depth(0, 0, -9000, oHud);
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
    if (invincible_timer > 0 || spirit_timer > 0 || hp <= 0) return;

    hp -= _amt;
    invincible_timer = 60; // 1 second invincibility

    // Knockback
    if (!place_meeting(x + _knockback_dir * 8, y, oWall)) {
        x += _knockback_dir * 8;
    }
    vsp = -4; // Pop up slightly
    animation_set("hurt", 16);

    // Visual feedback
    image_blend = c_red;
    alarm[0] = 10;

    if (hp <= 0) {
        // Getting caught during a heist ends it and loses the loot.
        // Anywhere else, just restart the room.
        if (instance_exists(oHeist)) {
            var _heist = instance_find(oHeist, 0);
            _heist.fail_heist("BUSTED!", "The wolves confiscated the loot. And your hat, if you had one.");
        } else {
            room_restart();
        }
    }
};

/// @desc Throws the horn, unless it is already out. Charged throws are
///       bigger, faster and hit harder.
throw_horn = function(_charged) {
    if (instance_exists(obj_horn_bullet)) return;

    // Play the throw animation before the horn leaves the muzzle.
    animation_set("throw", 18);

    // Spawn at the muzzle so the projectile reads as leaving the goat's head.
    var _sx = x + facing * 28;
    var _sy = y - 22;
    var _horn = instance_create_layer(_sx, _sy, "Instances", obj_horn_bullet);
    _horn.direction = point_direction(x, y, mouse_x, mouse_y);
    _horn.image_angle = _horn.direction;
    _horn.target_player = id;

    // Set fields on the returned id instead of using `with`: analyzer rules
    // treat locals from the calling scope as out of scope inside a with block.
    if (_charged) {
        _horn.damage = 3;
        _horn.door_damage = 2;
        _horn.speed = 16;
        _horn.image_xscale = 1.5;
        _horn.image_yscale = 1.5;
    }
};

/// @desc Shows a short message over the goat's head.
show_hint = function(_text, _duration = 120) {
    hint_text = _text;
    hint_timer = _duration;
};
