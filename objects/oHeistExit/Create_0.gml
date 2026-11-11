// =====================================================================
//  oHeistExit -> Create
//  The sewer hatch. Stays locked until the vault has been robbed, then
//  walking into it ends the heist.
// =====================================================================

game_state_init();

hint_timer = 0;   // stops the "locked" message repeating every frame
