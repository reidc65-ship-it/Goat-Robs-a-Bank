// =====================================================================
//  oMenu -> Draw GUI
// =====================================================================

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

var _gold       = make_colour_rgb(201, 162, 39);
var _gold_light = make_colour_rgb(242, 208, 107);

draw_set_font(-1);
draw_set_alpha(1);

switch (menu_screen) {
    case "title":
        draw_sprite_stretched(sMenuSplash, 0, 0, 0, _gw, _gh);

        // The goat, next to the title.
        draw_sprite_ext(sPlayer, 0, 120, 110, 2.6, 2.6, 0, c_white, 1);
        draw_game_title(370, 105, 7.5);

        for (var i = 0; i < array_length(title_items); i++) {
            draw_menu_button(i, title_items[i].label, "", false);
        }

        if (game_has_progress()) {
            draw_ui_text(330, 270, "BANKED  $" + string(global.bank_balance),
                         1.4, _gold_light, fa_center, 0.9);
        }

        draw_ui_text(_gw * 0.5, 740,
                     "W / S OR UP / DOWN TO SELECT     ENTER OR CLICK TO CONFIRM",
                     1.2, c_white, fa_center, 0.65);
        break;

    case "howto":
        draw_sprite_stretched(sMenuLevels, 0, 0, 0, _gw, _gh);

        draw_set_alpha(0.82);
        draw_set_colour(make_colour_rgb(10, 14, 22));
        draw_roundrect_ext(50, 24, _gw - 50, 672, 20, 20, false);
        draw_set_alpha(1);
        draw_set_colour(_gold);
        draw_roundrect_ext(50, 24, _gw - 50, 672, 20, 20, true);

        draw_ui_text(_gw * 0.5, 66, "HOW TO PLAY", 3, _gold_light, fa_center, 1);

        for (var i = 0; i < array_length(howto_rows); i++) {
            var _row_y = 124 + i * 60;
            draw_ui_text(92, _row_y, howto_rows[i].head, 1.6, _gold_light, fa_left, 1);

            draw_set_halign(fa_left);
            draw_set_valign(fa_middle);
            draw_set_colour(c_white);
            draw_text_transformed(250, _row_y, howto_rows[i].text, 1.25, 1.25, 0);
        }

        draw_menu_button(0, "BACK", "", false);
        break;

    case "confirm":
        draw_sprite_stretched(sMenuLevels, 0, 0, 0, _gw, _gh);
        draw_game_title(_gw * 0.5, 90, 4.5);

        draw_ui_text(_gw * 0.5, 270, "START A NEW GAME?", 2.8, _gold_light, fa_center, 1);
        draw_ui_text(_gw * 0.5, 325,
                     "This erases your $" + string(global.bank_balance)
                     + ", your upgrades and your farm improvements.",
                     1.4, c_white, fa_center, 0.9);

        for (var i = 0; i < array_length(confirm_items); i++) {
            draw_menu_button(i, confirm_items[i], "", false);
        }
        break;

    case "settings":
        draw_sprite_stretched(sMenuLevels, 0, 0, 0, _gw, _gh);
        draw_game_title(_gw * 0.5, 70, 4);

        for (var i = 0; i < array_length(settings_rows); i++) {
            switch (settings_rows[i]) {
                case "volume":
                    draw_menu_button(i, "MASTER VOLUME",
                                string(round(global.settings.master_volume * 100)) + "%", false);
                    break;
                case "fullscreen":
                    draw_menu_button(i, "FULLSCREEN", global.settings.fullscreen ? "ON" : "OFF", false);
                    break;
                case "fps":
                    draw_menu_button(i, "SHOW FPS", global.settings.show_fps ? "ON" : "OFF", false);
                    break;
                case "tips":
                    draw_menu_button(i, "TUTORIAL TIPS", global.tips_enabled ? "ON" : "OFF", false);
                    break;
                case "back":
                    draw_menu_button(i, "BACK", "", false);
                    break;
            }
        }

        draw_ui_text(_gw * 0.5, 740,
                     "W / S OR UP / DOWN TO SELECT     A / D OR LEFT / RIGHT TO CHANGE     ESC TO GO BACK",
                     1.2, c_white, fa_center, 0.65);
        break;

    case "levels":
        draw_sprite_stretched(sMenuLevels, 0, 0, 0, _gw, _gh);
        draw_game_title(_gw * 0.5, 72, 4);

        draw_ui_text(_gw * 0.5, 206, "SELECT A JOB", 3.4, _gold_light, fa_center, 1);

        draw_ui_text(_gw * 0.5, 170, "BANKED  $" + string(global.bank_balance)
                     + "     JOBS DONE  " + string(global.heists_completed)
                     + "     BEST HAUL  $" + string(global.best_haul),
                     1.15, _gold, fa_center, 0.9);

        // Divider
        draw_set_colour(_gold);
        draw_set_alpha(0.55);
        draw_rectangle(_gw * 0.5 - 240, 254, _gw * 0.5 + 240, 256, false);
        draw_set_alpha(1);

        for (var i = 0; i < array_length(levels); i++) {
            var _lv  = levels[i];
            var _tag = "PLAY";
            if (_lv.locked) _tag = (i < global.jobs_unlocked) ? "COMING SOON" : "LOCKED";
            draw_menu_button(i, _lv.name, _tag, _lv.locked);
        }

        // First-time hint, only until the first job has been finished.
        if (global.tips_enabled && global.heists_completed == 0) {
            draw_ui_text(_gw * 0.5, 712, "Pick JOB 01 and press ENTER to start your first robbery.",
                         1.3, _gold_light, fa_center, 1);
        }

        draw_ui_text(_gw * 0.5, 744,
                     "W / S OR UP / DOWN TO SELECT     ENTER TO START     ESC TO GO BACK",
                     1.2, c_white, fa_center, 0.65);
        break;
}

// Fade overlay
if (fade > 0) {
    draw_set_alpha(fade);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);
}
