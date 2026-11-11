// =====================================================================
//  oHeist -> Step
// =====================================================================

if (state == "active") {
    // The clock stops while a menu or conversation is open.
    if (global.game_paused || global.dialogue_active) exit;

    time_left--;
    if (time_left <= 0) {
        fail_heist("TIME'S UP!", "The police arrived and took everything but your dignity.");
    }

    // Age the floating text.
    for (var i = array_length(popups) - 1; i >= 0; i--) {
        popups[i].life--;
        popups[i].y -= 0.7;
        if (popups[i].life <= 0) array_delete(popups, i, 1);
    }
    exit;
}

// --- Results card -----------------------------------------------------
card_timer++;

// A short delay, so a key already being mashed can't skip the card.
if (card_timer > 45) {
    if (keyboard_check_pressed(vk_enter)
     || keyboard_check_pressed(vk_space)
     || keyboard_check_pressed(ord("E"))
     || mouse_check_button_pressed(mb_left)) {
        return_to_farm();
    }
}
