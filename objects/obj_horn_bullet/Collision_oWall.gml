if (is_frozen) exit;

// A door is a child of oWall, so this event fires when the horn hits one.
// Damage it before the horn bounces back. Check the glass roof hatch as
// well, since it is a special breakable child of oDoor. Only an outgoing
// horn can break things, and only once per throw.
//
// oWall itself has no hp/flash fields, so use dynamic access: the analyzer
// knows the value is optional and plain walls are skipped by the guard.
if (state == "out"
    && (other.object_index == oDoor || other.object_index == oSkylight)
    && !array_contains(hit_list, other.id)) {
    array_push(hit_list, other.id);

    var _target = other.id;
    if (variable_instance_exists(_target, "hp")) {
        var _target_hp = variable_instance_get(_target, "hp") - door_damage;
        variable_instance_set(_target, "hp", _target_hp);
        variable_instance_set(_target, "flash", 6);

        if (_target_hp <= 0) {
            effect_create_above(ef_explosion, _target.x, _target.y, 1, c_orange);
            instance_destroy(_target);
        }
    }
}

if (state == "out") {
    speed = 0;
    state = "return";
}
