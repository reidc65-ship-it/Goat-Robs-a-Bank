// =====================================================================
//  oNavArrow -> Create
//  A bobbing yellow direction marker. It never blocks anything. Set these
//  in each instance's creation code in the Room Editor:
//    arrow_dir / arrow_label    which way to point: "left", "right", "down"
//    after_dir / after_label    the same, once the vault has been robbed
//                               ("" hides the arrow after the robbery)
//    until_skylight             true hides it once the skylight is broken
// =====================================================================

game_state_init();

arrow_dir      = "right";
arrow_label    = "";
after_dir      = "";
after_label    = "";
until_skylight = false;
