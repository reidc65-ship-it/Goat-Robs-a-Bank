// =====================================================================
//  oBarnEnter -> Step
// =====================================================================

if (global.game_paused || global.dialogue_active) exit;
if (!instance_exists(oPlayer)) exit;

var _p = instance_find(oPlayer, 0);

// A little inside the doorway, so the player visibly steps into the barn.
if (point_in_rectangle(_p.x, _p.y, x - 44, y - 110, x + 44, y + 110)) {
    global.spawn_x = 220;
    global.spawn_y = 608;
    room_goto(rm_barn);
}
