// =====================================================================
//  oUpgradeMenu -> Draw GUI
// =====================================================================

if (!is_open) exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

draw_set_font(-1);
draw_set_alpha(1);

// --- Dim background ---------------------------------------------------
draw_set_colour(c_black);
draw_set_alpha(0.78);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);

// --- Menu backdrop ----------------------------------------------------
var _pad = 40;
var _mx1 = _pad;
var _my1 = _pad;
var _mx2 = _gw - _pad;
var _my2 = _gh - _pad;

// Shadow
draw_set_alpha(0.5);
draw_roundrect_colour_ext(_mx1 + 12, _my1 + 14, _mx2 + 12, _my2 + 14, 32, 32, c_black, c_black, false);
draw_set_alpha(1);

// Body gradient
draw_roundrect_colour_ext(_mx1, _my1, _mx2, _my2, 32, 32,
                          make_colour_rgb(28, 22, 16),
                          make_colour_rgb(16, 12, 8), false);

// Gold border
draw_set_colour(make_colour_rgb(201, 162, 39));
draw_roundrect_ext(_mx1, _my1, _mx2, _my2, 32, 32, true);

// Inner gold line
draw_set_alpha(0.35);
draw_roundrect_ext(_mx1 + 8, _my1 + 8, _mx2 - 8, _my2 - 8, 24, 24, true);
draw_set_alpha(1);

// --- Header -----------------------------------------------------------
draw_ui_text(_gw * 0.5, 80, "ELDER'S UPGRADES", 3.8,
             make_colour_rgb(242, 208, 107), fa_center, 1);
draw_ui_text(_gw * 0.5, 124, "Spend your stolen gold wisely.", 1.3,
             c_white, fa_center, 0.65);

// Bank balance
draw_ui_text(_gw * 0.5, 152, "$" + string(global.bank_balance), 2.8,
             make_colour_rgb(242, 208, 107), fa_center, 1);

// --- Slots ------------------------------------------------------------
for (var i = 0; i <= max_sel; i++) {
    var _up   = global.upgrades[i];
    var _r    = slot_rect(i);
    var _sel  = (i == sel);
    var _tier = _up.tier; // 0=locked, 1=available, 2=owned

    // Slot colors by tier
    var _c1, _c2, _border, _icon_alpha, _text_alpha;
    switch (_tier) {
        case 0: // Locked
            _c1 = make_colour_rgb(35, 30, 25);
            _c2 = make_colour_rgb(22, 18, 14);
            _border = make_colour_rgb(80, 70, 55);
            _icon_alpha = 0.35;
            _text_alpha = 0.5;
            break;
        case 1: // Available
            _c1 = make_colour_rgb(55, 45, 20);
            _c2 = make_colour_rgb(35, 28, 12);
            _border = make_colour_rgb(201, 162, 39);
            _icon_alpha = 1;
            _text_alpha = 1;
            break;
        case 2: // Owned
            _c1 = make_colour_rgb(30, 50, 30);
            _c2 = make_colour_rgb(18, 32, 18);
            _border = make_colour_rgb(100, 200, 100);
            _icon_alpha = 1;
            _text_alpha = 1;
            break;
    }

    // Selection highlight
    if (_sel) {
        _c1 = make_colour_rgb(min(_c1 & 0xFF + 30, 255), min((_c1 >> 8) & 0xFF + 20, 255), min((_c1 >> 16) & 0xFF + 10, 255));
        _c2 = make_colour_rgb(min(_c2 & 0xFF + 20, 255), min((_c2 >> 8) & 0xFF + 15, 255), min((_c2 >> 16) & 0xFF + 8, 255));
        _border = make_colour_rgb(242, 208, 107);
    }

    // Drop shadow
    draw_set_alpha(0.35);
    draw_set_colour(c_black);
    draw_roundrect_colour_ext(_r.x1 + 6, _r.y1 + 8, _r.x2 + 6, _r.y2 + 8, 18, 18, c_black, c_black, false);
    draw_set_alpha(1);

    // Slot body
    draw_roundrect_colour_ext(_r.x1, _r.y1, _r.x2, _r.y2, 18, 18, _c1, _c2, false);
    draw_set_colour(_border);
    draw_roundrect_ext(_r.x1, _r.y1, _r.x2, _r.y2, 18, 18, true);

    // Inner glow for selected
    if (_sel) {
        draw_set_alpha(0.25);
        draw_roundrect_ext(_r.x1 + 4, _r.y1 + 4, _r.x2 - 4, _r.y2 - 4, 14, 14, true);
        draw_set_alpha(1);
    }

    // --- Icon ---
    var _ix = (_r.x1 + _r.x2) * 0.5;
    var _iy = _r.y1 + 70;
    draw_set_alpha(_icon_alpha);
    draw_sprite_ext(_up.sprite, 0, _ix, _iy, 2.2, 2.2, 0, c_white, 1);
    draw_set_alpha(1);

    // Lock icon for locked
    if (_tier == 0) {
        draw_set_colour(make_colour_rgb(120, 100, 70));
        draw_set_alpha(0.9);
        draw_sprite_ext(sUpgradeDash, 0, _ix, _iy, 1.0, 1.0, 0, c_black, 0.7); // placeholder lock
        draw_set_alpha(1);
    }

    // Checkmark for owned
    if (_tier == 2) {
        draw_set_colour(make_colour_rgb(100, 220, 100));
        var _cx = _r.x2 - 30;
        var _cy = _r.y1 + 30;
        draw_set_alpha(1);
        draw_triangle(_cx - 8, _cy, _cx - 2, _cy + 6, _cx + 10, _cy - 10, false);
        draw_triangle(_cx - 7, _cy, _cx - 1, _cy + 6, _cx + 9, _cy - 10, false);
    }

    // --- Name ---
    var _name_y = _r.y1 + 140;
    draw_ui_text(_ix, _name_y, _up.name, 1.6,
                 _tier == 2 ? make_colour_rgb(180, 255, 180) : c_white,
                 fa_center, _text_alpha);

    // --- Cost / Status ---
    var _cost_y = _name_y + 32;
    if (_tier == 0) {
        draw_ui_text(_ix, _cost_y, "LOCKED", 1.4,
                     make_colour_rgb(160, 120, 80), fa_center, 0.8);
        draw_ui_text(_ix, _cost_y + 24, "Buy previous to unlock", 1.0,
                     make_colour_rgb(120, 100, 70), fa_center, 0.7);
    } else if (_tier == 1) {
        draw_ui_text(_ix, _cost_y, "$" + string(_up.cost), 2.0,
                     make_colour_rgb(242, 208, 107), fa_center, 1);
        // Affordability indicator
        if (global.bank_balance >= _up.cost) {
            draw_ui_text(_ix, _cost_y + 28, "AFFORDABLE", 1.1,
                         make_colour_rgb(100, 220, 100), fa_center, 0.9);
        } else {
            draw_ui_text(_ix, _cost_y + 28, "Need $" + string(_up.cost - global.bank_balance) + " more", 1.0,
                         make_colour_rgb(220, 100, 100), fa_center, 0.8);
        }
    } else {
        draw_ui_text(_ix, _cost_y, "OWNED", 1.6,
                     make_colour_rgb(100, 220, 100), fa_center, 1);
    }

    // --- Description (only for selected) ---
    if (_sel && _tier > 0) {
        var _desc_y = _r.y2 - 50;
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_colour(c_white);
        draw_set_alpha(0.85);
        // Simple word wrap for description
        var _words = string_split(_up.desc, " ");
        var _line = "";
        var _lines = [];
        for (var w = 0; w < array_length(_words); w++) {
            var _test = (_line == "") ? _words[w] : _line + " " + _words[w];
            if (string_width(_test) > slot_w - 30 && _line != "") {
                array_push(_lines, _line);
                _line = _words[w];
            } else {
                _line = _test;
            }
        }
        if (_line != "") array_push(_lines, _line);
        for (var l = 0; l < array_length(_lines); l++) {
            draw_text(_ix, _desc_y + l * 22, _lines[l]);
        }
        draw_set_alpha(1);
    }

    // Selection arrows
    if (_sel) {
        var _cy = (_r.y1 + _r.y2) * 0.5;
        draw_set_colour(make_colour_rgb(242, 208, 107));
        // Left arrow
        draw_triangle(_r.x1 - 18, _cy, _r.x1 - 6, _cy - 10, _r.x1 - 6, _cy + 10, false);
        // Right arrow
        draw_triangle(_r.x2 + 18, _cy, _r.x2 + 6, _cy - 10, _r.x2 + 6, _cy + 10, false);
    }
}

// --- Footer hints -----------------------------------------------------
draw_ui_text(_gw * 0.5, _my2 - 50,
             "A / D OR ARROWS TO SELECT     ENTER TO BUY     ESC TO CLOSE",
             1.2, c_white, fa_center, 0.6);

draw_set_alpha(1);