// =====================================================================
//  oBarnExit -> Step
// =====================================================================

if (global.game_paused || global.dialogue_active) exit;
if (!instance_exists(oPlayer)) exit;

var _p = instance_find(oPlayer, 0);

if (point_in_rectangle(_p.x, _p.y, x - 44, y - 110, x + 44, y + 110)) {
    // Land just outside the barn door, not back at the far end of the farm.
    global.spawn_x = 1320;
    global.spawn_y = 608;
    room_goto(rm_farm);
}
