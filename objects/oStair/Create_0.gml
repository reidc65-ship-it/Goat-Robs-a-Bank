// =====================================================================
//  oStair -> Create
//  Katana ZERO-style stair: run into it to climb, hold DOWN on landing to drop
// =====================================================================

// Stair properties
stair_step_height = 16;   // pixels per step (matches player collision precision)
landing_drop_through = true; // allow dropping through landing with DOWN key

// Auto-detect if this is a landing (flat top piece) based on horizontal scale
// Landings are wider (scaleX > 1.5), regular stairs are 1x1
is_landing = (scaleX > 1.5);

// Auto-detect stair direction based on instance name pattern
// Stairs going LEFT/UP (negative X direction): 
// 09-11, 21-23, 33-35, 45-47, 57-59, 69-71, 81-83
// All others go RIGHT/UP (positive X direction)
var _name = name;
if (string_pos("stair_09", _name) > 0 || string_pos("stair_10", _name) > 0 || string_pos("stair_11", _name) > 0 ||
    string_pos("stair_21", _name) > 0 || string_pos("stair_22", _name) > 0 || string_pos("stair_23", _name) > 0 ||
    string_pos("stair_33", _name) > 0 || string_pos("stair_34", _name) > 0 || string_pos("stair_35", _name) > 0 ||
    string_pos("stair_45", _name) > 0 || string_pos("stair_46", _name) > 0 || string_pos("stair_47", _name) > 0 ||
    string_pos("stair_57", _name) > 0 || string_pos("stair_58", _name) > 0 || string_pos("stair_59", _name) > 0 ||
    string_pos("stair_69", _name) > 0 || string_pos("stair_70", _name) > 0 || string_pos("stair_71", _name) > 0 ||
    string_pos("stair_81", _name) > 0 || string_pos("stair_82", _name) > 0 || string_pos("stair_83", _name) > 0) {
    stair_direction = -1;  // Left/up
} else {
    stair_direction = 1;   // Right/up
}

// Visual: use wall sprite but could be customized
sprite_index = sWall;
image_speed = 0;
solid = false;
visible = true;