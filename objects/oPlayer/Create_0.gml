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

// Camera follow state (driven in the Step event)
cam_x = 0;
cam_y = y - 300;
