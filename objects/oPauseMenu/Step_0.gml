// =====================================================================
//  oPauseMenu -> Step
// =====================================================================

// The title screen has its own input handling.
if (room == rm_menu) {
    is_open       = false;
    unpause_timer = 0;
    global.game_paused = false;
    global.dialogue_active = false;
    exit;
}

// A conversation owns the screen and the pause state while it runs.
if (global.dialogue_active) exit;

// The upgrade shop has its own Escape handling; don't stack the two menus.
if (instance_exists(oUpgradeMenu)) {
    var _upgrade_menu = instance_find(oUpgradeMenu, 0);
    if (_upgrade_menu.is_open) exit;
}

// The level-complete card owns the screen. Don't let Escape open the
// pause menu behind it.
if (variable_global_exists("level_complete") && global.level_complete) {
    is_open       = false;
    unpause_timer = 0;
    global.game_paused = false;
    exit;
}

// Delay the unpause by one frame so the closing input is fully consumed.
if (unpause_timer > 0) {
    unpause_timer--;
    if (unpause_timer <= 0) {
        global.game_paused = false;
    }
}

// --- Open / close -----------------------------------------------------
if (keyboard_check_pressed(vk_escape)) {
    if (is_open) {
        close_menu();
    } else {
        open_menu();
    }
    exit;
}

if (!is_open) exit;

// --- Mouse ------------------------------------------------------------
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _press = mouse_check_button_pressed(mb_left);
var _held  = mouse_check_button(mb_left);
var _moved = (_mx != mx_prev || _my != my_prev);

mx_prev = _mx;
my_prev = _my;

var _hover = -1;
for (var i = 0; i < row_count; i++) {
    var _r = row_rect(i);
    if (point_in_rectangle(_mx, _my, _r.x1, _r.y1, _r.x2, _r.y2)) {
        _hover = i;
        if (_moved || _press) sel = i;
    }
}

// --- Volume slider ----------------------------------------------------
var _vr = volume_rect();
if (sel == 0 && _press && point_in_rectangle(_mx, _my, _vr.x1, _vr.y1, _vr.x2, _vr.y2)) {
    dragging_vol = true;
}
if (!_held) dragging_vol = false;
if (dragging_vol) {
    set_volume((_mx - _vr.x1) / (_vr.x2 - _vr.x1));
}

// --- Keyboard navigation ---------------------------------------------
if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
    sel = (sel - 1 + row_count) mod row_count;
}
if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
    sel = (sel + 1) mod row_count;
}

// Left / right adjusts the selected setting
if (sel == 0) {
    if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
        set_volume(global.settings.master_volume - 0.05);
    }
    if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
        set_volume(global.settings.master_volume + 0.05);
    }
} else if (sel == 1) {
    if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
        global.settings.fullscreen = false;
        window_set_fullscreen(false);
    }
    if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
        global.settings.fullscreen = true;
        window_set_fullscreen(true);
    }
} else if (sel == 2) {
    if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
        global.settings.show_fps = false;
    }
    if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
        global.settings.show_fps = true;
    }
}

// --- Activate ---------------------------------------------------------
var _confirm = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
var _clicked = (_press && _hover != -1);

if (sel == 0) {
    // Volume is adjusted with left/right or the slider.
} else if (_confirm || _clicked) {
    switch (sel) {
        case 1: toggle_fullscreen(); break;
        case 2: global.settings.show_fps = !global.settings.show_fps; break;
        case 3: close_menu(); break;
        case 4: restart_level(); break;
        case 5: quit_to_title(); break;
    }
}
