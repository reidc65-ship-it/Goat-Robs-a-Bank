// obj_horn_bullet -> Collision with oWolfCop
// The thrown horn is the player's ranged attack, so it hurts guards.
if (is_frozen) exit;

// The overlap lasts several frames, but each throw only hits a guard once.
if (array_contains(hit_list, other.id)) exit;
array_push(hit_list, other.id);

if (variable_instance_exists(other, "take_damage")) {
    other.take_damage(damage, sign(other.x - x));
}

if (state == "out") {
    speed = 0;
    state = "return";
}
