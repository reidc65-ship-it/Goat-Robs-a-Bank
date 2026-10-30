// =====================================================================
//  oUpgradeMenu -> Step
// =====================================================================

if (!is_open) exit;

// Close on Escape
if (keyboard_check_pressed(vk_escape)) {
    close_menu();
    exit;
}

// Switch between the goat and farm tabs
if (keyboard_check_pressed(vk_tab)) {
    tab = 1 - tab;
    sel = 0;
}

// Navigation
var _count = array_length(current_list());
if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
    sel = (sel - 1 + _count) mod _count;
}
if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
    sel = (sel + 1) mod _count;
}

// Confirm purchase
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    try_buy();
}

// Confirm timer for visual feedback
if (confirm_timer > 0) confirm_timer--;