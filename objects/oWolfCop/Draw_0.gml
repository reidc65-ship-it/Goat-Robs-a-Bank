// =====================================================================
//  oWolfCop -> Draw
//  Draws sprite + vision cone (debug) + alert indicator
// =====================================================================

// --- Shadow ---
draw_sprite_ext(sprite_index, image_index, x + 4, y + 6,
                image_xscale, image_yscale, image_angle, c_black, 0.25);
draw_self();

// --- Vision Cone (Debug - only in debug mode) ---
if (debug_mode) {
    // Vision cone
    var _cone_len = sight_range;
    var _cone_angle = sight_angle;
    var _center_dir = (facing == 1) ? 0 : 180;
    
    draw_set_alpha(0.15);
    draw_set_colour(c_blue);
    
    var _steps = 10;
    var _start = _center_dir - _cone_angle;
    var _end = _center_dir + _cone_angle;
    
    draw_primitive_begin(pr_trianglefan);
    draw_vertex(x, y);
    for (var i = 0; i <= _steps; i++) {
        var _ang = _start + (_end - _start) * i / _steps;
        var _rad = degtorad(_ang);
        draw_vertex(x + cos(_rad) * _cone_len, y + sin(_rad) * _cone_len);
    }
    draw_primitive_end();
    
    draw_set_alpha(1);
    
    // Line of sight ray to player
    if (chase_target != noone && instance_exists(chase_target)) {
        draw_set_colour(c_red);
        draw_line_width(x, y, chase_target.x, chase_target.y, 2);
    }
    
    // Patrol points
    draw_set_colour(c_yellow);
    for (var i = 0; i < array_length(patrol_points); i++) {
        var _pt = patrol_points[i];
        draw_circle(_pt.x, _pt.y, 8, true);
        if (i == patrol_index) {
            draw_set_colour(c_lime);
            draw_circle(_pt.x, _pt.y, 12, true);
        }
    }
    
    // State text
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_text(x - 64, y - 80, "STATE: " + string_upper(state));
    draw_text(x - 64, y - 64, "ALERT: " + string(alert_level));
    if (chase_target != noone) {
        draw_text(x - 64, y - 48, "TARGET: YES");
    }
}

// --- Alert Indicator ---
if (alert_level > 0) {
    var _bob = sin(current_time / 150) * 4;
    var _ax = x;
    var _ay = bbox_top - 24 + _bob;
    
    // Background
    draw_set_alpha(0.8);
    draw_set_colour(c_black);
    draw_roundrect_ext(_ax - 16, _ay - 16, _ax + 16, _ay + 16, 8, 8, false);
    draw_set_alpha(1);
    
    // Alert icon
    switch (alert_level) {
        case 1: // Suspicious - yellow ?
            draw_set_colour(make_colour_rgb(255, 220, 50));
            draw_set_font(-1);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text_transformed(_ax, _ay + 2, "?", 1.8, 1.8, 0);
            break;
        case 2: // Alerted - red !
            draw_set_colour(c_red);
            draw_set_font(-1);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text_transformed(_ax, _ay + 2, "!", 2.2, 2.2, 0);
            // Pulsing ring
            var _pulse = 0.5 + 0.5 * sin(current_time / 100);
            draw_set_alpha(0.3 * _pulse);
            draw_circle(_ax, _ay, 24 + _pulse * 8, true);
            draw_set_alpha(1);
            break;
    }
}

// --- Health Bar (when damaged) ---
if (hp < max_hp && state != "dead") {
    var _bar_w = 48;
    var _bar_h = 6;
    var _bx = x - _bar_w / 2;
    var _by = bbox_top - 18;
    var _pct = hp / max_hp;
    
    draw_set_colour(c_black);
    draw_rectangle(_bx - 1, _by - 1, _bx + _bar_w + 1, _by + _bar_h + 1, false);
    
    draw_set_colour(c_red);
    draw_rectangle(_bx, _by, _bx + _bar_w, _by + _bar_h, false);
    
    draw_set_colour(c_lime);
    draw_rectangle(_bx, _by, _bx + _bar_w * _pct, _by + _bar_h, false);
    
    draw_set_colour(c_white);
}