// =====================================================================
//  oMenu -> Step
// =====================================================================

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

// --- Fade transition --------------------------------------------------
if (fade_dir == 1) {
    fade = min(fade + 0.09, 1);

    if (fade >= 1) {
        if (next_screen == "game") {
            room_goto(pending_room);
            exit;
        }
        if (next_screen == "farm") {
            room_goto(rm_farm);
            exit;
        }

        menu_screen = next_screen;
        fade_dir = -1;
    }
} else if (fade_dir == -1) {
    fade = max(fade - 0.09, 0);
    if (fade <= 0) fade_dir = 0;
}

if (denied_timer > 0) denied_timer--;

// No input while the screen is fading
if (fade_dir != 0) exit;

// --- Level select -----------------------------------------------------
var _count   = array_length(levels);
var _clicked = -1;
var _moved   = (_mx != mx_prev || _my != my_prev);
var _press   = mouse_check_button_pressed(mb_left);

mx_prev = _mx;
my_prev = _my;

for (var i = 0; i < _count; i++) {
    var _r = button_rect(i);

    if (point_in_rectangle(_mx, _my, _r.x1, _r.y1, _r.x2, _r.y2)) {
        // Only let the mouse take over when it actually moves, so
        // W/S navigation works with the cursor parked on a button.
        if (_moved || _press) sel = i;
        if (_press) _clicked = i;
    }
}

if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
    sel = (sel - 1 + _count) mod _count;
}
if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
    sel = (sel + 1) mod _count;
}

if (keyboard_check_pressed(vk_escape)) {
    begin_fade("farm", noone);
    exit;
}

var _confirm = keyboard_check_pressed(vk_enter)
            || keyboard_check_pressed(vk_space)
            || (_clicked != -1);

if (_confirm) {
    if (levels[sel].locked || levels[sel].target_room == noone) {
        denied_timer = 24;
        denied_index = sel;
    } else {
        begin_fade("game", levels[sel].target_room);
    }
}
