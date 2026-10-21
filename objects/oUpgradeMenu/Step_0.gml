// =====================================================================
//  oUpgradeMenu -> Step
// =====================================================================

if (!is_open) exit;

// Close on Escape
if (keyboard_check_pressed(vk_escape)) {
    close_menu();
    exit;
}

// Navigation
if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
    sel = (sel - 1 + 5) mod 5;
}
if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
    sel = (sel + 1) mod 5;
}

// Confirm purchase
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    try_buy();
}

// Confirm timer for visual feedback
if (confirm_timer > 0) confirm_timer--;