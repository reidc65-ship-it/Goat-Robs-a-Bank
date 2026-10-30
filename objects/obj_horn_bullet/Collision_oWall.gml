if (is_frozen) exit;

// A door is a child of oWall, so this event fires when the horn hits one.
// Damage it before the horn bounces back. Check the glass roof hatch as
// well, since it is a special breakable child of oDoor. Only an outgoing
// horn can break things, and only once per throw.
if (state == "out"
    && (other.object_index == oDoor || other.object_index == oSkylight)
    && !array_contains(hit_list, other.id)) {
    array_push(hit_list, other.id);

    var _door_damage = door_damage;
    with (other) {
        hp -= _door_damage;
        flash = 6;
        if (hp <= 0) {
            effect_create_above(ef_explosion, x, y, 1, c_orange);
            instance_destroy();
        }
    }
}

if (state == "out") {
    speed = 0;
    state = "return";
}
