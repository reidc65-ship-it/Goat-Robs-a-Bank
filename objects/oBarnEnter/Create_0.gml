// =====================================================================
//  oBarnEnter -> Create
//  Invisible trigger in the farm barn doorway. Walking into the dark
//  opening carries the player into the barn interior.
// =====================================================================

if (!variable_global_exists("game_paused"))     global.game_paused = false;
if (!variable_global_exists("dialogue_active")) global.dialogue_active = false;
