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

// Camera follow state (driven in the Step event)
cam_x = 0;
cam_y = y - 300;

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
