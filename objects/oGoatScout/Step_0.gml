// =====================================================================
//  oGoatScout -> Step
// =====================================================================

can_talk = false;

if (!global.dialogue_active && !global.game_paused && instance_exists(oPlayer)) {
    var _p = instance_find(oPlayer, 0);
    if (point_distance(x, y - 40, _p.x, _p.y) < talk_range) {
        can_talk = true;
    }
}

if (can_talk && keyboard_check_pressed(ord("E"))) {
    start_conversation();
}