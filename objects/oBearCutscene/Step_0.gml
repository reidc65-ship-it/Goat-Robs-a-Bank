// =====================================================================
//  oBearCutscene -> Step
//  Advance the eight storyboard panels. ENTER/SPACE/E/click skips ahead
//  after a short delay so the first key press on the results card does
//  not accidentally blow through the whole movie.
// =====================================================================

var _skip = keyboard_check_pressed(vk_enter)
         || keyboard_check_pressed(vk_space)
         || keyboard_check_pressed(ord("E"))
         || keyboard_check_pressed(vk_escape)
         || mouse_check_button_pressed(mb_left);

if (_skip && beat_time > 90) {
    if (beat < array_length(durations) - 1) {
        // Jump to the final panel; one more press leaves the cutscene.
        beat = array_length(durations) - 1;
        beat_time = durations[beat] - 1;
    } else {
        global.level_complete = false;
        global.spawn_x = -1;
        global.spawn_y = -1;
        room_goto(rm_farm);
        exit;
    }
}

beat_time++;

if (beat_time >= durations[beat]) {
    beat_time = 0;
    beat++;

    if (beat >= array_length(durations)) {
        global.level_complete = false;
        global.spawn_x = -1;
        global.spawn_y = -1;
        room_goto(rm_farm);
    }
}
