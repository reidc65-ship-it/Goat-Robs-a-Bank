// =====================================================================
//  oCash -> Step
// =====================================================================

if (game_is_frozen()) exit;
if (!instance_exists(oPlayer)) exit;

var _p = instance_find(oPlayer, 0);

if (abs(_p.x - x) < 44 && abs(_p.y - y) < 52) {
    collect();
}
