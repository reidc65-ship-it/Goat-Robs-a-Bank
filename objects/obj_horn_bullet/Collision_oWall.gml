// A door is a child of oWall, so this event fires when the horn hits one.
// Damage it before the horn bounces back. Check the glass roof hatch as
// well, since it is a special breakable child of oDoor.
if (other.object_index == oDoor || other.object_index == oSkylight) {
    with (other) {
        hp -= 1;
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
