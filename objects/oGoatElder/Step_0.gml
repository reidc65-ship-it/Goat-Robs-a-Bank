// =====================================================================
//  oGoatElder -> Step
// =====================================================================

can_talk = false;

if (!global.dialogue_active && !global.game_paused && instance_exists(oPlayer)) {
    var _p = instance_find(oPlayer, 0);
    // Check distance from NPC's feet to player's feet (more accurate)
    var _npc_feet_y = y + (sprite_get_height(sprite_index) / 2); // origin 4 = bottom center
    var _player_feet_y = _p.y + (sprite_get_height(_p.sprite_index) / 2);
    if (point_distance(x, _npc_feet_y, _p.x, _player_feet_y) < talk_range) {
        can_talk = true;
    }
}

if (can_talk && keyboard_check_pressed(ord("E"))) {
    start_conversation();
}