// =====================================================================
//  oWolfVaultDialogue -> Step
// =====================================================================

// Hold the pause one frame after the last input so the same click cannot
// also fire the goat's horn when control returns.
if (close_timer > 0) {
    close_timer--;
    if (close_timer <= 0) {
        var _done = on_complete;
        if (!is_undefined(_done)) _done();
        instance_destroy();
    }
    exit;
}

// Swallow the input that opened the report.
if (start_timer > 0) {
    start_timer--;
    exit;
}

var _len = string_length(current_text);
if (visible_chars < _len) {
    visible_chars = min(visible_chars + char_speed, _len);
}

if (keyboard_check_pressed(vk_escape)) {
    end_dialogue();
    exit;
}

if (keyboard_check_pressed(ord("E"))
 || keyboard_check_pressed(vk_enter)
 || keyboard_check_pressed(vk_space)
 || mouse_check_button_pressed(mb_left)) {
    advance_line();
}
