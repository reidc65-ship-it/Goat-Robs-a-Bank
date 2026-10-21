// =====================================================================
//  draw_stair_sprite() - Programmatic stair drawing
//  Call this from oStair's Draw event to render stairs without a PNG
// =====================================================================

/// @function draw_stair_sprite();
/// @description Draws a Katana ZERO-style stair sprite programmatically

// Colors (warm brown/wood tones)
var _wood_dark    = make_colour_rgb(101, 67, 33);    // Dark wood
var _wood_mid     = make_colour_rgb(139, 94, 48);    // Medium wood
var _wood_light   = make_colour_rgb(180, 130, 75);   // Light wood highlight
var _wood_edge    = make_colour_rgb(70, 45, 20);     // Dark edge
var _highlight    = make_colour_rgb(200, 150, 90);   // Top highlight

// Stair dimensions
var _w = 64;
var _h = 64;

// Origin is bottom-center (32, 64)
var _ox = x - 32;
var _oy = y - 64;

if (is_landing) {
    // ==================== LANDING (flat platform) ====================
    var _land_w = _w * scaleX;  // Wider for landings
    var _left = x - (_land_w / 2);
    var _top = y - 64;
    
    // Main platform
    draw_rectangle_colour(_left, _top, _left + _land_w, y, 
                          _wood_mid, _wood_mid, _wood_dark, _wood_dark, false);
    
    // Top highlight line
    draw_line_colour(_left, _top, _left + _land_w, _top, _highlight, _highlight);
    
    // Edge lines
    draw_line_colour(_left, _top, _left, y, _wood_edge, _wood_edge);
    draw_line_colour(_left + _land_w, _top, _left + _land_w, y, _wood_edge, _wood_edge);
    
    // Wood grain lines
    for (var i = 1; i < 4; i++) {
        var _gx = _left + (_land_w / 4) * i;
        draw_line_colour(_gx, _top + 4, _gx + 2, y - 4, _wood_dark, _wood_dark);
    }
    
    // Subtle planks (horizontal lines)
    for (var i = 1; i < 4; i++) {
        var _py = _top + (64 / 4) * i;
        draw_line_colour(_left, _py, _left + _land_w, _py, _wood_edge, _wood_edge);
    }
    
} else {
    // ==================== STAIR STEP ====================
    // Stair goes up in stair_direction (1 = right, -1 = left)
    var _dir = stair_direction;  // 1 or -1
    
    // Calculate step shape (triangular wedge)
    var _step_top_y = y - 16;  // Step height = 16px
    
    if (_dir == 1) {
        // Stair goes RIGHT/UP - wedge on left side
        var _points = [
            _ox, y,           // Bottom-left
            _ox, _step_top_y, // Top-left (vertical riser)
            _ox + 48, _step_top_y, // Top of tread
            _ox + _w, y       // Bottom-right
        ];
    } else {
        // Stair goes LEFT/UP - wedge on right side
        var _points = [
            _ox, y,           // Bottom-left
            _ox + 16, _step_top_y, // Top of tread
            _ox + _w, _step_top_y, // Top-right (vertical riser)
            _ox + _w, y       // Bottom-right
        ];
    }
    
    // Draw stair polygon (tread + riser)
    draw_primitive_begin(pr_trianglefan);
    draw_vertex_colour(_points[0], _points[1], _wood_mid, 1);
    draw_vertex_colour(_points[2], _points[3], _wood_light, 1);
    draw_vertex_colour(_points[4], _points[5], _wood_light, 1);
    draw_vertex_colour(_points[6], _points[7], _wood_dark, 1);
    draw_primitive_end();
    
    // Draw riser (vertical face) - darker
    if (_dir == 1) {
        draw_rectangle_colour(_ox, _step_top_y, _ox + 2, y, _wood_edge, _wood_edge, _wood_dark, _wood_dark, false);
        // Tread top highlight
        draw_line_colour(_ox, _step_top_y, _ox + 48, _step_top_y, _highlight, _highlight);
    } else {
        draw_rectangle_colour(_ox + _w - 2, _step_top_y, _ox + _w, y, _wood_edge, _wood_edge, _wood_dark, _wood_dark, false);
        draw_line_colour(_ox + 16, _step_top_y, _ox + _w, _step_top_y, _highlight, _highlight);
    }
    
    // Side edge
    if (_dir == 1) {
        draw_line_colour(_ox + 48, _step_top_y, _ox + _w, y, _wood_edge, _wood_edge);
    } else {
        draw_line_colour(_ox, y, _ox + 16, _step_top_y, _wood_edge, _wood_edge);
    }
    
    // Wood grain on tread
    for (var i = 1; i < 3; i++) {
        var _gx = (_dir == 1) ? _ox + 16 * i : _ox + 16 + 16 * i;
        var _gy = _step_top_y + 4;
        draw_line_colour(_gx - 2, _gy, _gx + 2, y - 4, _wood_dark, _wood_dark);
    }
}

// Draw collision debug (optional - remove in production)
// draw_rectangle(x - 32, y - 64, x + 32, y, true);