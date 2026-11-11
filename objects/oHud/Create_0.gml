// =====================================================================
//  oHud -> Create
//  Created by oPlayer, so every room with a player gets a HUD, tutorial
//  tips, and a short fade-in that shows the player the room has changed.
// =====================================================================

room_fade = 1;     // 1 = black, fades out when a room starts

tip_id   = "";     // flag this tip completes
tip_text = "";     // empty = no tip showing
tip_age  = 0;      // frames the current tip has been on screen

start_x  = -1;     // where the goat began, to notice the first walk
