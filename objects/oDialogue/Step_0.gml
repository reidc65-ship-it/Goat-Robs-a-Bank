// =====================================================================
//  oDialogue -> Step
// =====================================================================

// One frame after the closing input, hand control back to the player.
if (close_timer > 0) {
    close_timer--;
    if (close_timer <= 0) {
        global.dialogue_active = false;
        global.game_paused     = false;
        instance_destroy();
    }
    exit;
}

// Swallow the E press that opened the conversation.
if (start_timer > 0) {
    start_timer--;
    exit;
}

// --- Typewriter -------------------------------------------------------
var _len = string_length(current_text);
if (visible_chars < _len) {
    visible_chars = min(visible_chars + char_speed, _len);
}

// --- Input ------------------------------------------------------------
if (keyboard_check_pressed(vk_escape)) {
    end_dialogue();
    exit;
}

var _advance = keyboard_check_pressed(ord("E"))
            || keyboard_check_pressed(vk_enter)
            || keyboard_check_pressed(vk_space)
            || mouse_check_button_pressed(mb_left);

if (_advance) {
    advance_line();
}
