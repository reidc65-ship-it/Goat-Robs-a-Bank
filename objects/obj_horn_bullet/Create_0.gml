// obj_horn_bullet -> Create Event
move_speed = 12;
return_speed = 15;

state = "out";
target_player = noone;

// Set initial forward movement based on its spawn direction
speed = move_speed;

// One throw hits each guard or door at most once.
hit_list = [];
damage = 1;
door_damage = 1;

// The horn turns back after this distance, or at the edge of the room,
// so it can never fly off and leave the goat unable to throw again.
max_range = 900;
travelled = 0;

// Motion saved while the game is paused.
is_frozen = false;
saved_speed = 0;
