// oBankBackdrop -> Draw
// Static cutaway art for the bank heist. All collision comes from the
// invisible oBankBlocker instances; this object is purely the set dressing.
// Depth 250 keeps it behind the stairs, doors, guards, and player while
// staying in front of the room's background colour.

draw_set_alpha(1);
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _night       = make_colour_rgb(9, 13, 26);
var _night2      = make_colour_rgb(16, 22, 40);
var _night3      = make_colour_rgb(26, 34, 56);
var _stone       = make_colour_rgb(34, 38, 49);
var _stone_dark  = make_colour_rgb(21, 24, 32);
var _stone_light = make_colour_rgb(78, 84, 100);
var _panel       = make_colour_rgb(28, 35, 47);
var _panel_dark  = make_colour_rgb(18, 23, 33);
var _gold        = make_colour_rgb(201, 162, 39);
var _gold_light  = make_colour_rgb(242, 208, 107);
var _gold_dark   = make_colour_rgb(126, 98, 22);
var _carpet      = make_colour_rgb(108, 28, 42);
var _carpet_dark = make_colour_rgb(65, 15, 25);
var _glass       = make_colour_rgb(58, 104, 128);
var _glass_light = make_colour_rgb(132, 190, 210);
var _screen      = make_colour_rgb(47, 143, 131);
var _screen_dark = make_colour_rgb(20, 64, 63);
var _red         = make_colour_rgb(170, 48, 48);
var _paper       = make_colour_rgb(214, 204, 176);

// =====================================================================
//  ROOFTOP SKY
// =====================================================================
draw_set_colour(_night);
draw_rectangle(0, 0, 1920, 170, false);
draw_set_colour(_night2);
draw_rectangle(0, 170, 1920, 360, false);
draw_set_colour(_night3);
draw_rectangle(0, 360, 1920, 540, false);

// Stars.
for (var i = 0; i < 48; i++) {
    var _sx = (i * 211 + 73) mod 1920;
    var _sy = (i * 97 + 41) mod 420;
    var _ss = ((i mod 4) == 0) ? 2 : 1;
    draw_set_colour((i mod 3 == 0) ? _gold_light : make_colour_rgb(196, 208, 232));
    draw_rectangle(_sx, _sy, _sx + _ss, _sy + _ss, false);
}

// Moon with a soft halo.
draw_set_alpha(0.05);
draw_set_colour(make_colour_rgb(220, 230, 255));
draw_circle(1510, 118, 94, false);
draw_set_alpha(0.08);
draw_circle(1510, 118, 72, false);
draw_set_alpha(1);
draw_set_colour(make_colour_rgb(224, 228, 214));
draw_circle(1510, 118, 52, false);
draw_set_colour(make_colour_rgb(190, 198, 190));
draw_circle(1532, 104, 9, false);
draw_circle(1494, 136, 6, false);

// Distant skyline. The buildings sit behind the bank roof.
for (var b = 0; b < 16; b++) {
    var _bx = b * 138 - 34;
    var _bh = 96 + ((b * 73 + 31) mod 210);
    var _by = 560 - _bh;
    var _bw = 112 + ((b * 37) mod 46);
    draw_set_colour((b mod 2 == 0) ? make_colour_rgb(12, 17, 30) : make_colour_rgb(18, 24, 40));
    draw_rectangle(_bx, _by, _bx + _bw, 704, false);

    // A few lit windows on each block.
    for (var wx = 0; wx < 5; wx++) {
        for (var wy = 0; wy < 6; wy++) {
            if (((b + wx * 3 + wy * 7) mod 5) < 2) {
                var _winx = _bx + 12 + wx * 20;
                var _winy = _by + 18 + wy * 26;
                if (_winx + 7 < _bx + _bw && _winy + 10 < 700) {
                    draw_set_colour(((b + wy) mod 4 == 0) ? _gold_light : make_colour_rgb(106, 138, 164));
                    draw_rectangle(_winx, _winy, _winx + 7, _winy + 10, false);
                }
            }
        }
    }

    // Rooftop antenna / water tank silhouettes.
    if ((b mod 3) == 0) {
        draw_set_colour(make_colour_rgb(8, 12, 22));
        draw_line_width(_bx + _bw * 0.5, _by, _bx + _bw * 0.5, _by - 42, 3);
    }
}

// =====================================================================
//  BANK ROOF AND SIGN
// =====================================================================
// Roof deck, with the skylight opening left empty so the glass hatch can
// be seen (and smashed) above it.
draw_set_colour(_stone);
draw_rectangle(0, 704, 304, 768, false);
draw_rectangle(496, 704, 1920, 768, false);
draw_set_colour(_stone_light);
draw_rectangle(0, 704, 304, 716, false);
draw_rectangle(496, 704, 1920, 716, false);
draw_set_colour(_stone_dark);
draw_rectangle(0, 764, 304, 768, false);
draw_rectangle(496, 764, 1920, 768, false);

// The dark shaft under the skylight.
draw_set_colour(make_colour_rgb(4, 7, 12));
draw_rectangle(304, 704, 496, 768, false);

// Steel skylight curb and hazard corners.
draw_set_colour(make_colour_rgb(42, 46, 58));
draw_rectangle(296, 696, 504, 704, false);
draw_set_colour(_gold);
draw_rectangle(296, 696, 504, 700, false);
for (var hz = 0; hz < 8; hz++) {
    draw_set_colour((hz mod 2 == 0) ? _gold : _gold_dark);
    draw_rectangle(304 + hz * 24, 696, 312 + hz * 24, 704, false);
}

// Rooftop air handling units.
draw_set_colour(make_colour_rgb(38, 42, 52));
draw_rectangle(760, 624, 930, 704, false);
draw_set_colour(make_colour_rgb(55, 60, 74));
draw_rectangle(768, 632, 922, 654, false);
draw_set_colour(make_colour_rgb(24, 28, 36));
for (var v = 0; v < 6; v++) {
    draw_rectangle(780 + v * 23, 662, 796 + v * 23, 690, false);
}
draw_set_colour(_gold_dark);
draw_line_width(754, 624, 936, 624, 3);

// A second vent stack.
draw_set_colour(make_colour_rgb(30, 34, 44));
draw_rectangle(1580, 648, 1630, 704, false);
draw_set_colour(make_colour_rgb(58, 62, 74));
draw_rectangle(1572, 640, 1638, 652, false);

// Rooftop bank sign.
draw_set_colour(_stone_dark);
draw_rectangle(948, 462, 1470, 658, false);
draw_set_colour(make_colour_rgb(22, 28, 38));
draw_rectangle(960, 474, 1458, 646, false);
draw_set_colour(_gold_dark);
draw_rectangle(948, 462, 1470, 474, false);
draw_set_colour(_gold);
draw_rectangle(960, 474, 1458, 486, false);
draw_rectangle(960, 634, 1458, 646, false);
draw_line_width(960, 474, 960, 646, 4);
draw_line_width(1458, 474, 1458, 646, 4);

// Sign supports.
draw_set_colour(make_colour_rgb(28, 32, 42));
draw_rectangle(1000, 658, 1024, 704, false);
draw_rectangle(1394, 658, 1418, 704, false);

// Bank name.
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_colour(c_black);
draw_text_transformed(1210, 546, "GOAT NATIONAL BANK", 2.55, 2.55, 0);
draw_set_colour(_gold_light);
draw_text_transformed(1208, 544, "GOAT NATIONAL BANK", 2.55, 2.55, 0);
draw_set_colour(_gold);
draw_rectangle(1060, 584, 1354, 587, false);
draw_set_colour(make_colour_rgb(198, 192, 170));
draw_text_transformed(1208, 608, "VAULT DEPOSITS  -  EST. 1924", 1.05, 1.05, 0);

// Roof-access stencil. This points the player at the skylight.
draw_set_colour(_gold);
draw_text_transformed(300, 652, "ROOF ACCESS", 1.05, 1.05, 0);
draw_set_colour(_red);
draw_triangle(398, 674, 386, 692, 410, 692, false);
draw_rectangle(395, 690, 405, 712, false);

draw_set_halign(fa_left);
draw_set_valign(fa_top);

// =====================================================================
//  EXECUTIVE OFFICE (x 0..700, floor y 1344)
// =====================================================================
// Back wall and panelling.
draw_set_colour(_panel);
draw_rectangle(0, 704, 700, 1344, false);
draw_set_colour(_panel_dark);
for (var p = 0; p < 7; p++) {
    draw_rectangle(96 + p * 96, 736, 100 + p * 96, 1190, false);
}
draw_set_colour(make_colour_rgb(52, 38, 30));
draw_rectangle(0, 1190, 700, 1344, false);
draw_set_colour(_gold_dark);
draw_rectangle(0, 1186, 700, 1194, false);
draw_set_colour(make_colour_rgb(38, 28, 24));
for (var w = 0; w < 14; w++) {
    draw_rectangle(12 + w * 50, 1210, 51 + w * 50, 1332, false);
}

// Ceiling / roof underside around the skylight shaft.
draw_set_colour(_stone_dark);
draw_rectangle(0, 704, 304, 736, false);
draw_rectangle(496, 704, 700, 736, false);
draw_set_colour(make_colour_rgb(8, 12, 18));
draw_rectangle(304, 704, 496, 736, false);
draw_set_colour(_gold_dark);
draw_line_width(304, 736, 496, 736, 3);

// Moonlight shaft falling through the roof opening.
draw_set_alpha(0.055);
draw_set_colour(make_colour_rgb(188, 216, 244));
draw_triangle(304, 736, 496, 736, 610, 1344, false);
draw_triangle(304, 736, 610, 1344, 190, 1344, false);
draw_set_alpha(1);

// Back window with night city view.
draw_set_colour(make_colour_rgb(18, 24, 38));
draw_rectangle(56, 796, 252, 1120, false);
draw_set_colour(_night3);
draw_rectangle(64, 804, 244, 1112, false);
draw_set_colour(make_colour_rgb(30, 40, 62));
draw_rectangle(64, 980, 244, 1112, false);
draw_set_colour(make_colour_rgb(18, 24, 40));
for (var cw = 0; cw < 7; cw++) {
    var _cbx = 68 + cw * 26;
    var _cbh = 48 + ((cw * 29) mod 90);
    draw_rectangle(_cbx, 980 - _cbh, _cbx + 20, 980, false);
    draw_set_colour(_gold_light);
    draw_rectangle(_cbx + 5, 980 - _cbh + 12, _cbx + 8, 980 - _cbh + 17, false);
    draw_set_colour(make_colour_rgb(18, 24, 40));
}
draw_set_colour(make_colour_rgb(206, 214, 198));
draw_circle(206, 874, 20, false);
draw_set_colour(_gold);
draw_rectangle(50, 790, 258, 798, false);
draw_rectangle(50, 1116, 258, 1124, false);
draw_line_width(50, 790, 50, 1124, 5);
draw_line_width(258, 790, 258, 1124, 5);
draw_set_colour(make_colour_rgb(40, 44, 54));
draw_line_width(154, 796, 154, 1118, 4);
draw_line_width(54, 956, 254, 956, 4);
// Blind slats.
draw_set_colour(make_colour_rgb(74, 64, 50));
for (var sl = 0; sl < 7; sl++) {
    draw_rectangle(62, 806 + sl * 18, 246, 810 + sl * 18, false);
}

// Framed painting.
draw_set_colour(_gold_dark);
draw_rectangle(304, 832, 388, 956, false);
draw_set_colour(make_colour_rgb(52, 30, 35));
draw_rectangle(312, 840, 380, 948, false);
draw_set_colour(make_colour_rgb(124, 92, 58));
draw_circle(346, 884, 18, false);
draw_set_colour(make_colour_rgb(30, 36, 48));
draw_triangle(316, 940, 346, 892, 376, 940, false);

// Executive desk.
draw_set_colour(make_colour_rgb(76, 46, 30));
draw_rectangle(258, 1180, 532, 1344, false);
draw_set_colour(make_colour_rgb(104, 66, 42));
draw_rectangle(250, 1172, 540, 1210, false);
draw_set_colour(_gold_dark);
draw_rectangle(250, 1172, 540, 1178, false);
draw_set_colour(make_colour_rgb(54, 32, 22));
draw_rectangle(274, 1218, 330, 1338, false);
draw_rectangle(478, 1218, 520, 1338, false);

// Monitor, papers, and phone on the desk.
draw_set_colour(make_colour_rgb(22, 26, 34));
draw_rectangle(400, 1088, 500, 1170, false);
draw_set_colour(_screen_dark);
draw_rectangle(408, 1096, 492, 1158, false);
draw_set_colour(_screen);
draw_rectangle(414, 1102, 486, 1152, false);
draw_set_colour(make_colour_rgb(9, 14, 18));
for (var _line = 0; _line < 5; _line++) {
    draw_rectangle(420, 1110 + _line * 8,
                   420 + 22 + ((_line * 17) mod 34), 1112 + _line * 8, false);
}
draw_set_colour(make_colour_rgb(38, 42, 52));
draw_rectangle(436, 1158, 464, 1176, false);
draw_set_colour(_paper);
draw_rectangle(282, 1172, 380, 1204, false);
draw_set_colour(make_colour_rgb(86, 82, 74));
draw_line_width(292, 1184, 368, 1184, 1);
draw_line_width(292, 1192, 354, 1192, 1);
draw_set_colour(make_colour_rgb(30, 34, 42));
draw_rectangle(458, 1180, 486, 1200, false);

// Safe.
draw_set_colour(make_colour_rgb(44, 48, 58));
draw_rectangle(556, 1090, 636, 1210, false);
draw_set_colour(make_colour_rgb(62, 68, 82));
draw_rectangle(564, 1098, 628, 1202, false);
draw_set_colour(_gold);
draw_circle(596, 1148, 14, false);
draw_circle(596, 1148, 5, false);
draw_line_width(596, 1134, 596, 1162, 2);
draw_set_colour(_gold_dark);
draw_rectangle(564, 1098, 628, 1104, false);

// Coat rack / plant near the window.
draw_set_colour(make_colour_rgb(24, 28, 36));
draw_line_width(84, 1120, 84, 1338, 4);
draw_line_width(60, 1160, 108, 1160, 4);
draw_set_colour(make_colour_rgb(44, 92, 58));
draw_circle(60, 1148, 24, false);
draw_circle(108, 1148, 24, false);
draw_circle(84, 1132, 26, false);

// Security door sign.
draw_set_colour(make_colour_rgb(20, 24, 32));
draw_rectangle(548, 1228, 652, 1258, false);
draw_set_colour(_red);
draw_rectangle(548, 1228, 652, 1232, false);
draw_set_halign(fa_center);
draw_set_colour(_red);
draw_text_transformed(600, 1244, "AUTHORISED ONLY", 0.72, 0.72, 0);
draw_set_halign(fa_left);

// Office floor.
draw_set_colour(_stone_dark);
draw_rectangle(0, 1344, 700, 1376, false);
draw_set_colour(_stone_light);
draw_rectangle(0, 1344, 700, 1358, false);
draw_set_colour(_gold);
draw_rectangle(0, 1358, 700, 1362, false);
draw_set_colour(_stone);
draw_rectangle(0, 1362, 700, 1376, false);

// =====================================================================
//  CENTRAL STAIRWELL (x 700..1400, y 704..3264)
// =====================================================================
draw_set_colour(make_colour_rgb(17, 21, 30));
draw_rectangle(700, 704, 1400, 3264, false);
draw_set_colour(make_colour_rgb(23, 28, 39));
for (var sw = 0; sw < 11; sw++) {
    draw_rectangle(700 + sw * 64, 736, 703 + sw * 64, 3264, false);
}
// Horizontal beams at each landing level.
for (var beam = 0; beam < 4; beam++) {
    var _by2 = 1344 + beam * 640;
    draw_set_colour(make_colour_rgb(34, 39, 52));
    draw_rectangle(700, _by2, 1400, _by2 + 14, false);
    draw_set_colour(_gold_dark);
    draw_rectangle(700, _by2 + 14, 1400, _by2 + 18, false);
}

// Tall stairwell window showing the city.
draw_set_colour(make_colour_rgb(26, 32, 46));
draw_rectangle(760, 790, 1060, 1160, false);
draw_set_colour(_night3);
draw_rectangle(770, 800, 1050, 1150, false);
draw_set_colour(make_colour_rgb(24, 32, 52));
draw_rectangle(770, 1000, 1050, 1150, false);
for (var tw = 0; tw < 11; tw++) {
    var _twx = 778 + tw * 25;
    var _twh = 40 + ((tw * 41) mod 100);
    draw_set_colour(make_colour_rgb(13, 19, 32));
    draw_rectangle(_twx, 1000 - _twh, _twx + 18, 1000, false);
    draw_set_colour(_gold_light);
    draw_rectangle(_twx + 5, 1000 - _twh + 12, _twx + 7, 1000 - _twh + 18, false);
}
draw_set_colour(make_colour_rgb(42, 48, 60));
draw_line_width(770, 975, 1050, 975, 4);
draw_line_width(910, 800, 910, 1150, 4);
draw_set_colour(_gold_dark);
draw_rectangle(754, 784, 1066, 792, false);
draw_rectangle(754, 1156, 1066, 1164, false);
draw_line_width(760, 790, 760, 1160, 5);
draw_line_width(1060, 790, 1060, 1160, 5);

// Wall lamps and pipes.
for (var lamp = 0; lamp < 4; lamp++) {
    var _ly2 = 900 + lamp * 640;
    draw_set_colour(make_colour_rgb(30, 34, 44));
    draw_rectangle(1330, _ly2, 1346, _ly2 + 42, false);
    draw_set_alpha(0.08);
    draw_set_colour(_gold_light);
    draw_circle(1338, _ly2 + 44, 52, false);
    draw_set_alpha(1);
    draw_set_colour(_gold_light);
    draw_rectangle(1330, _ly2 + 36, 1346, _ly2 + 44, false);
}
draw_set_colour(make_colour_rgb(52, 48, 42));
draw_line_width(1360, 736, 1360, 3264, 7);
draw_set_colour(make_colour_rgb(28, 32, 42));
draw_line_width(1374, 736, 1374, 3264, 4);

// Floor numbers stencilled on the shaft wall.
draw_set_halign(fa_center);
draw_set_colour(_gold_dark);
draw_text_transformed(1230, 1278, "02", 2.1, 2.1, 0);
draw_text_transformed(1230, 1918, "03", 2.1, 2.1, 0);
draw_text_transformed(1230, 2558, "04", 2.1, 2.1, 0);
draw_set_halign(fa_left);

// =====================================================================
//  SECURITY LANDING (x 1400..1920, floor y 1984)
// =====================================================================
draw_set_colour(make_colour_rgb(25, 33, 42));
draw_rectangle(1400, 1344, 1920, 1984, false);
draw_set_colour(make_colour_rgb(18, 24, 32));
for (var sp = 0; sp < 6; sp++) {
    draw_rectangle(1424 + sp * 80, 1376, 1428 + sp * 80, 1900, false);
}
draw_set_colour(make_colour_rgb(32, 40, 50));
draw_rectangle(1400, 1860, 1920, 1984, false);

// Monitor bank.
draw_set_colour(make_colour_rgb(16, 20, 27));
draw_rectangle(1500, 1460, 1852, 1758, false);
draw_set_colour(make_colour_rgb(42, 48, 60));
draw_rectangle(1508, 1468, 1844, 1750, false);
for (var m = 0; m < 6; m++) {
    var _mx = 1522 + (m mod 3) * 106;
    var _my = 1486 + floor(m / 3) * 126;
    draw_set_colour(make_colour_rgb(22, 26, 34));
    draw_rectangle(_mx, _my, _mx + 92, _my + 102, false);
    draw_set_colour(_screen_dark);
    draw_rectangle(_mx + 5, _my + 5, _mx + 87, _my + 90, false);
    draw_set_colour(_screen);
    draw_rectangle(_mx + 9, _my + 9, _mx + 83, _my + 86, false);
    draw_set_colour(make_colour_rgb(9, 20, 20));
    for (var ml = 0; ml < 6; ml++) {
        draw_rectangle(_mx + 13, _my + 16 + ml * 10,
                       _mx + 13 + 18 + ((m * 13 + ml * 17) mod 42),
                       _my + 18 + ml * 10, false);
    }
    draw_set_colour(make_colour_rgb(20, 24, 30));
    draw_rectangle(_mx + 38, _my + 97, _mx + 54, _my + 110, false);
}

// Security desk.
draw_set_colour(make_colour_rgb(48, 42, 38));
draw_rectangle(1488, 1748, 1864, 1820, false);
draw_set_colour(make_colour_rgb(69, 60, 50));
draw_rectangle(1480, 1740, 1872, 1760, false);
draw_set_colour(_gold_dark);
draw_rectangle(1480, 1740, 1872, 1744, false);

// Chair silhouette.
draw_set_colour(make_colour_rgb(18, 22, 30));
draw_rectangle(1624, 1800, 1696, 1860, false);
draw_rectangle(1608, 1844, 1712, 1858, false);
draw_line_width(1660, 1858, 1660, 1938, 5);

// Coffee cup, keyboard, and a red alert lamp.
draw_set_colour(_paper);
draw_rectangle(1546, 1712, 1574, 1740, false);
draw_set_colour(make_colour_rgb(96, 62, 40));
draw_rectangle(1549, 1714, 1571, 1726, false);
draw_set_colour(_screen_dark);
draw_rectangle(1710, 1704, 1830, 1738, false);
draw_set_colour(make_colour_rgb(20, 24, 30));
draw_rectangle(1440, 1396, 1460, 1416, false);
draw_set_colour(_red);
draw_circle(1450, 1406, 6, false);

draw_set_halign(fa_center);
draw_set_colour(_gold);
draw_text_transformed(1660, 1408, "SECURITY", 1.4, 1.4, 0);
draw_set_halign(fa_left);

// Security landing floor.
draw_set_colour(_stone_dark);
draw_rectangle(1400, 1984, 1920, 2016, false);
draw_set_colour(_stone_light);
draw_rectangle(1400, 1984, 1920, 1998, false);
draw_set_colour(_gold);
draw_rectangle(1400, 1998, 1920, 2002, false);
draw_set_colour(_stone);
draw_rectangle(1400, 2002, 1920, 2016, false);

// =====================================================================
//  VAULT ANTECHAMBER (x 0..700, floor y 2624)
// =====================================================================
draw_set_colour(make_colour_rgb(30, 35, 43));
draw_rectangle(0, 1984, 700, 2624, false);
draw_set_colour(make_colour_rgb(22, 26, 34));
for (var ap = 0; ap < 7; ap++) {
    draw_rectangle(0 + ap * 96, 2016, 4 + ap * 96, 2560, false);
}
draw_set_colour(make_colour_rgb(24, 29, 37));
draw_rectangle(0, 2016, 700, 2060, false);
draw_set_colour(_gold_dark);
draw_rectangle(0, 2058, 700, 2064, false);

// Deposit boxes.
draw_set_colour(make_colour_rgb(17, 21, 28));
draw_rectangle(28, 2136, 270, 2496, false);
for (var dx = 0; dx < 4; dx++) {
    for (var dy = 0; dy < 6; dy++) {
        var _dbx = 40 + dx * 56;
        var _dby = 2148 + dy * 55;
        draw_set_colour(make_colour_rgb(54, 58, 68));
        draw_rectangle(_dbx, _dby, _dbx + 48, _dby + 47, false);
        draw_set_colour(make_colour_rgb(32, 36, 44));
        draw_rectangle(_dbx + 5, _dby + 5, _dbx + 43, _dby + 42, false);
        draw_set_colour(_gold_dark);
        draw_circle(_dbx + 24, _dby + 24, 4, false);
    }
}

// Security checkpoint console.
draw_set_colour(make_colour_rgb(46, 50, 60));
draw_rectangle(360, 2392, 580, 2624, false);
draw_set_colour(make_colour_rgb(66, 70, 82));
draw_rectangle(352, 2384, 588, 2412, false);
draw_set_colour(make_colour_rgb(18, 22, 28));
draw_rectangle(384, 2288, 536, 2384, false);
draw_set_colour(_screen_dark);
draw_rectangle(392, 2296, 528, 2376, false);
draw_set_colour(_screen);
draw_rectangle(400, 2304, 520, 2368, false);
draw_set_colour(make_colour_rgb(9, 20, 20));
for (var cl = 0; cl < 5; cl++) {
    draw_rectangle(408, 2312 + cl * 10, 408 + 26 + ((cl * 23) mod 52), 2314 + cl * 10, false);
}
draw_set_colour(_gold);
draw_circle(460, 2596, 10, false);
draw_set_colour(make_colour_rgb(20, 24, 30));
draw_rectangle(432, 2588, 488, 2604, false);

// Archway/metal detector frame.
draw_set_colour(make_colour_rgb(56, 60, 72));
draw_rectangle(600, 2150, 628, 2624, false);
draw_rectangle(680, 2150, 700, 2624, false);
draw_rectangle(600, 2150, 700, 2178, false);
draw_set_colour(_gold);
draw_rectangle(600, 2178, 628, 2184, false);
draw_rectangle(680, 2178, 700, 2184, false);

draw_set_halign(fa_center);
draw_set_colour(_gold);
draw_text_transformed(350, 2088, "VAULT ACCESS", 1.5, 1.5, 0);
draw_set_colour(_red);
draw_text_transformed(350, 2118, "AUTHORISED PERSONNEL ONLY", 0.78, 0.78, 0);
draw_set_halign(fa_left);

// Antechamber floor.
draw_set_colour(_stone_dark);
draw_rectangle(0, 2624, 700, 2656, false);
draw_set_colour(_stone_light);
draw_rectangle(0, 2624, 700, 2638, false);
draw_set_colour(_gold);
draw_rectangle(0, 2638, 700, 2642, false);
draw_set_colour(_stone);
draw_rectangle(0, 2642, 700, 2656, false);

// =====================================================================
//  VAULT (x 0..1920, floor y 3264)
// =====================================================================
draw_set_colour(make_colour_rgb(28, 33, 41));
draw_rectangle(0, 2624, 1920, 4096, false);
draw_set_colour(make_colour_rgb(20, 24, 31));
for (var vp = 0; vp < 16; vp++) {
    draw_rectangle(vp * 120, 2656, vp * 120 + 4, 4096, false);
}
for (var hb = 0; hb < 4; hb++) {
    draw_set_colour(make_colour_rgb(35, 40, 50));
    draw_rectangle(0, 2790 + hb * 300, 1920, 2800 + hb * 300, false);
}

// Deposit boxes along the left.
draw_set_colour(make_colour_rgb(16, 20, 27));
draw_rectangle(20, 2740, 330, 3160, false);
for (var vx = 0; vx < 5; vx++) {
    for (var vy = 0; vy < 7; vy++) {
        var _vbx = 34 + vx * 58;
        var _vby = 2754 + vy * 56;
        draw_set_colour(make_colour_rgb(58, 62, 72));
        draw_rectangle(_vbx, _vby, _vbx + 50, _vby + 48, false);
        draw_set_colour(make_colour_rgb(34, 38, 46));
        draw_rectangle(_vbx + 5, _vby + 5, _vbx + 45, _vby + 43, false);
        draw_set_colour(_gold_dark);
        draw_circle(_vbx + 25, _vby + 24, 4, false);
    }
}

// Giant round vault door frame behind the breakable door.
draw_set_colour(make_colour_rgb(14, 18, 24));
draw_circle(1760, 3136, 214, false);
draw_set_colour(make_colour_rgb(52, 56, 68));
draw_circle(1760, 3136, 196, false);
draw_set_colour(make_colour_rgb(30, 34, 44));
draw_circle(1760, 3136, 176, false);
draw_set_colour(_gold_dark);
draw_circle(1760, 3136, 160, false);
draw_set_colour(make_colour_rgb(38, 42, 52));
draw_circle(1760, 3136, 146, false);
for (var spk = 0; spk < 8; spk++) {
    var _ang = spk * 45;
    draw_set_colour(make_colour_rgb(70, 74, 86));
    draw_line_width(1760 + lengthdir_x(60, _ang), 3136 + lengthdir_y(60, _ang),
                    1760 + lengthdir_x(136, _ang), 3136 + lengthdir_y(136, _ang), 8);
}
draw_set_colour(_gold);
draw_circle(1760, 3136, 54, false);
draw_set_colour(make_colour_rgb(26, 30, 38));
draw_circle(1760, 3136, 40, false);

// Gold visible in the alcove behind the breakable vault door.
for (var gb = 0; gb < 4; gb++) {
    draw_set_colour(_gold_dark);
    draw_rectangle(1668, 3224 - gb * 14, 1852, 3236 - gb * 14, false);
    draw_set_colour(_gold_light);
    draw_rectangle(1672, 3224 - gb * 14, 1848, 3228 - gb * 14, false);
}
draw_set_alpha(0.12);
draw_set_colour(_gold_light);
draw_circle(1760, 3200, 120, false);
draw_set_alpha(1);

// Loose gold stacks.
for (var gs = 0; gs < 5; gs++) {
    var _gx = 1430 + (gs mod 3) * 74;
    var _gy = 3246 - floor(gs / 3) * 18;
    draw_set_colour(_gold_dark);
    draw_rectangle(_gx, _gy - 14, _gx + 60, _gy, false);
    draw_set_colour(_gold);
    draw_rectangle(_gx + 3, _gy - 11, _gx + 57, _gy - 4, false);
    draw_set_colour(_gold_light);
    draw_rectangle(_gx + 6, _gy - 10, _gx + 54, _gy - 8, false);
}

// Vault carpet leading from the stairs.
draw_set_colour(_carpet_dark);
draw_rectangle(1360, 3260, 1720, 3276, false);
draw_set_colour(_carpet);
draw_rectangle(1360, 3260, 1720, 3268, false);
draw_set_colour(_gold);
draw_line_width(1360, 3262, 1720, 3262, 2);

// Vault signage.
draw_set_halign(fa_center);
draw_set_colour(c_black);
draw_text_transformed(420, 2698, "VAULT", 4.2, 4.2, 0);
draw_set_colour(_gold);
draw_text_transformed(418, 2696, "VAULT", 4.2, 4.2, 0);
draw_set_colour(make_colour_rgb(198, 192, 170));
draw_text_transformed(418, 2742, "DEPOSITORY  -  LEVEL 05", 1.0, 1.0, 0);
draw_set_halign(fa_left);

// Vault floor.
draw_set_colour(_stone_dark);
draw_rectangle(0, 3264, 1920, 3330, false);
draw_set_colour(_stone_light);
draw_rectangle(0, 3264, 1920, 3280, false);
draw_set_colour(_gold);
draw_rectangle(0, 3280, 1920, 3286, false);
draw_set_colour(_stone);
draw_rectangle(0, 3286, 1920, 3330, false);

// Lower vault gloom and a second, deeper door silhouette.
draw_set_colour(make_colour_rgb(11, 14, 20));
draw_rectangle(0, 3330, 1920, 4096, false);
draw_set_colour(make_colour_rgb(20, 24, 32));
draw_circle(1660, 3740, 260, false);
draw_set_colour(make_colour_rgb(34, 38, 48));
draw_circle(1660, 3740, 232, false);
draw_set_colour(_gold_dark);
draw_circle(1660, 3740, 204, false);
draw_set_colour(make_colour_rgb(18, 22, 30));
draw_circle(1660, 3740, 186, false);
draw_set_alpha(0.08);
draw_set_colour(_gold_light);
draw_circle(1660, 3740, 300, false);
draw_set_alpha(1);

// =====================================================================
//  FRONT LIPS
// =====================================================================
// The interior back walls are painted top-down, so re-assert the thin
// rooftop deck and the antechamber lip in front of them. This keeps the
// goat standing on a visible roof edge and keeps the landing at y=2624
// from disappearing under the vault wall.
draw_set_colour(_stone);
draw_rectangle(0, 704, 304, 716, false);
draw_rectangle(496, 704, 1920, 716, false);
draw_set_colour(_stone_light);
draw_rectangle(0, 704, 304, 709, false);
draw_rectangle(496, 704, 1920, 709, false);
draw_set_colour(_gold_dark);
draw_rectangle(0, 709, 304, 712, false);
draw_rectangle(496, 709, 1920, 712, false);

draw_set_colour(_stone_dark);
draw_rectangle(0, 2624, 700, 2656, false);
draw_set_colour(_stone_light);
draw_rectangle(0, 2624, 700, 2638, false);
draw_set_colour(_gold);
draw_rectangle(0, 2638, 700, 2642, false);
draw_set_colour(_stone);
draw_rectangle(0, 2642, 700, 2656, false);

// =====================================================================
//  BORDER WALLS
// =====================================================================
draw_set_colour(make_colour_rgb(17, 20, 28));
draw_rectangle(0, 0, 32, 4096, false);
draw_rectangle(1888, 0, 1920, 4096, false);
draw_set_colour(make_colour_rgb(54, 58, 70));
draw_rectangle(28, 0, 32, 4096, false);
draw_rectangle(1888, 0, 1892, 4096, false);
draw_set_colour(_gold_dark);
draw_rectangle(24, 0, 28, 4096, false);
draw_rectangle(1892, 0, 1896, 4096, false);

// Reset draw state for the next object.
draw_set_colour(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
