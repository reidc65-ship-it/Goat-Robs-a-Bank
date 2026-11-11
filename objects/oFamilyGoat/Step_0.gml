// =====================================================================
//  oFamilyGoat -> Step
// =====================================================================

can_talk = false;

if (!game_is_frozen() && instance_exists(oPlayer)) {
    var _p = instance_find(oPlayer, 0);
    if (point_distance(x, y, _p.x, _p.y) < talk_range) {
        can_talk = true;
    }
}

if (can_talk && keyboard_check_pressed(ord("E"))) {
    start_conversation();
}
