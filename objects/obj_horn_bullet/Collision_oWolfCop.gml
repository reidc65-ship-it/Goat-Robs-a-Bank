// obj_horn_bullet -> Collision with oWolfCop
// The thrown horn is the player's ranged attack, so it hurts guards.
if (variable_instance_exists(other, "take_damage")) {
    other.take_damage(1, sign(other.x - x));
}

if (state == "out") {
    speed = 0;
    state = "return";
}
