// =====================================================================
//  oPauseMenu -> Draw GUI
// =====================================================================

if (room == rm_menu) exit;

// Don't let the pause UI or FPS counter draw over a conversation.
if (global.dialogue_active) exit;

// The results card has its own full-screen treatment.
if (variable_global_exists("level_complete") && global.level_complete) exit;

// Optional FPS counter while the menu is closed.
if (!is_open) {
    if (global.settings.show_fps) {
        draw_set_font(-1);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_colour(c_black);
        draw_set_alpha(0.75);
        draw_text(12, 10, "FPS: " + string(round(fps)));
        draw_set_colour(c_white);
        draw_set_alpha(0.9);
        draw_text(10, 8, "FPS: " + string(round(fps)));
        draw_set_alpha(1);
    }
    exit;
}

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

draw_set_font(-1);
draw_set_alpha(1);

// --- Dim the frozen level ---------------------------------------------
draw_set_colour(c_black);
draw_set_alpha(0.72);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);

// --- Panel ------------------------------------------------------------
var _px1 = (_gw - panel_w) * 0.5;
var _px2 = _px1 + panel_w;
var _py1 = panel_y;
var _py2 = _py1 + panel_h;

// Shadow
draw_set_alpha(0.5);
draw_roundrect_colour_ext(_px1 + 10, _py1 + 12, _px2 + 10, _py2 + 12,
                          24, 24, c_black, c_black, false);
draw_set_alpha(1);

// Body
draw_roundrect_colour_ext(_px1, _py1, _px2, _py2, 24, 24,
                          make_colour_rgb(22, 29, 41),
                          make_colour_rgb(10, 14, 22), false);

// Outer gold border
draw_set_colour(make_colour_rgb(201, 162, 39));
draw_roundrect_ext(_px1, _py1, _px2, _py2, 24, 24, true);

// Inner gold line
draw_set_alpha(0.32);
draw_roundrect_ext(_px1 + 7, _py1 + 7, _px2 - 7, _py2 - 7, 18, 18, true);
draw_set_alpha(1);

// --- Header -----------------------------------------------------------
draw_ui_text(_gw * 0.5, 120, "PAUSED", 3.6,
             make_colour_rgb(242, 208, 107), fa_center, 1);
draw_ui_text(_gw * 0.5, 164, "SETTINGS & OPTIONS", 1.25,
             c_white, fa_center, 0.55);

// --- Rows -------------------------------------------------------------
for (var i = 0; i < row_count; i++) {
    var _r      = row_rect(i);
    var _is_sel = (i == sel);
    var _cy     = (_r.y1 + _r.y2) * 0.5;

    var _c1     = _is_sel ? make_colour_rgb(54, 45, 19) : make_colour_rgb(24, 31, 43);
    var _c2     = _is_sel ? make_colour_rgb(33, 27, 12) : make_colour_rgb(16, 21, 30);
    var _border = _is_sel ? make_colour_rgb(242, 208, 107) : make_colour_rgb(58, 69, 88);

    draw_roundrect_colour_ext(_r.x1, _r.y1, _r.x2, _r.y2, 12, 12, _c1, _c2, false);
    draw_set_colour(_border);
    draw_roundrect_ext(_r.x1, _r.y1, _r.x2, _r.y2, 12, 12, true);

    // Label
    var _label = "";
    switch (i) {
        case 0: _label = "MASTER VOLUME"; break;
        case 1: _label = "FULLSCREEN";    break;
        case 2: _label = "SHOW FPS";      break;
        case 3: _label = "RESUME";        break;
        case 4: _label = "RESTART LEVEL"; break;
        case 5: _label = "QUIT TO TITLE"; break;
    }

    if (i <= 2) {
        draw_ui_text(_r.x1 + 32, _cy, _label, 1.7, c_white, fa_left, 1);
    } else {
        draw_ui_text((_r.x1 + _r.x2) * 0.5, _cy, _label, 1.7,
                     _is_sel ? make_colour_rgb(242, 208, 107) : c_white,
                     fa_center, 1);
    }

    // Value / slider
    if (i == 0) {
        var _vr = volume_rect();

        // Track
        draw_set_colour(make_colour_rgb(8, 11, 17));
        draw_roundrect_ext(_vr.x1, _vr.y1, _vr.x2, _vr.y2, 6, 6, false);

        // Fill
        var _fx = _vr.x1 + (_vr.x2 - _vr.x1) * global.settings.master_volume;
        if (_fx > _vr.x1) {
            draw_set_colour(make_colour_rgb(201, 162, 39));
            draw_roundrect_ext(_vr.x1, _vr.y1, _fx, _vr.y2, 6, 6, false);
        }

        // Knob
        var _kx = clamp(_fx, _vr.x1, _vr.x2);
        draw_set_colour(make_colour_rgb(242, 208, 107));
        draw_roundrect_ext(_kx - 3, _vr.y1 - 6, _kx + 3, _vr.y2 + 6, 3, 3, false);

        var _pct = string(round(global.settings.master_volume * 100)) + "%";
        draw_ui_text(_r.x2 - 32, _cy, _pct, 1.55,
                     make_colour_rgb(242, 208, 107), fa_right, 1);
    } else if (i == 1) {
        var _on_fs = global.settings.fullscreen;
        draw_ui_text(_r.x2 - 32, _cy, _on_fs ? "ON" : "OFF", 1.55,
                     _on_fs ? make_colour_rgb(242, 208, 107)
                            : make_colour_rgb(125, 136, 152),
                     fa_right, 1);
    } else if (i == 2) {
        var _on_fps = global.settings.show_fps;
        draw_ui_text(_r.x2 - 32, _cy, _on_fps ? "ON" : "OFF", 1.55,
                     _on_fps ? make_colour_rgb(242, 208, 107)
                             : make_colour_rgb(125, 136, 152),
                     fa_right, 1);
    } else if (_is_sel) {
        // Chevrons on the selected action row
        draw_set_colour(make_colour_rgb(242, 208, 107));
        draw_triangle(_r.x1 + 24, _cy - 10, _r.x1 + 24, _cy + 10,
                      _r.x1 + 36, _cy, false);
        draw_triangle(_r.x2 - 24, _cy - 10, _r.x2 - 24, _cy + 10,
                      _r.x2 - 36, _cy, false);
    }
}

// --- Divider between settings and actions -----------------------------
var _div_y = row_rect(2).y2 + row_gap * 0.5;
draw_set_colour(make_colour_rgb(201, 162, 39));
draw_set_alpha(0.35);
draw_rectangle(_px1 + 80, _div_y - 1, _px2 - 80, _div_y + 1, false);
draw_set_alpha(1);

// --- Footer -----------------------------------------------------------
draw_ui_text(_gw * 0.5, 666,
             "W/S NAVIGATE     A/D TO CHANGE     ENTER TO SELECT     ESC TO RESUME",
             1.1, c_white, fa_center, 0.55);

draw_set_alpha(1);
