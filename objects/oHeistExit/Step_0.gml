// =====================================================================
//  oHeistExit -> Step
// =====================================================================

if (hint_timer > 0) hint_timer--;

if (game_is_frozen()) exit;
if (!instance_exists(oPlayer) || !instance_exists(oHeist)) exit;

var _p = instance_find(oPlayer, 0);
var _heist = instance_find(oHeist, 0);

if (point_in_rectangle(_p.x, _p.y, x - 48, y - 60, x + 48, y + 60)) {
    if (_heist.vault_looted) {
        _heist.finish_heist();
    } else if (hint_timer <= 0) {
        hint_timer = 120;
        _heist.add_popup("Not without the vault loot!", x + 70, y - 90, c_white);
    }
}
