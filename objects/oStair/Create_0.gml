// oStair -> Create
// A single diagonal stair flight. The instance sits at the low (bottom)
// end. The high (top) end is `w` pixels away horizontally and `h` pixels
// up. A negative image_xscale in the Room Editor makes the flight rise to
// the left instead of the right.
dir = (image_xscale < 0) ? -1 : 1;
image_xscale = 1;
image_yscale = 1;

w = 700;
h = 640;

// This object owns the slope interaction. Actors never calculate the
// slope themselves: End Step places them on this surface. There is no
// solid mask; the landing slabs handle ordinary wall collision.

surface_y_at = function(_px) {
    var _t = clamp((_px - x) / (dir * w), 0, 1);
    return y - _t * h;
};

/// @desc Best surface under a point across all flights (a switchback
///       landing has two), or noone. Returns { stair: id, y: surface_y }.
best_surface_at = function(_px, _py) {
    var _best = noone;
    var _best_y = -999999;
    var _count = instance_number(oStair);

    for (var _i = 0; _i < _count; _i++) {
        var _s = instance_find(oStair, _i);
        if (!instance_exists(_s)) continue;

        var _high_x = _s.x + _s.dir * _s.w;
        var _min_x = min(_s.x, _high_x);
        var _max_x = max(_s.x, _high_x);
        if (_px < _min_x || _px > _max_x) continue;

        var _sy = _s.surface_y_at(_px);

        // The same +/-40 band the player used: forgiving enough to catch
        // a fall, narrow enough not to grab a flight on the floor below.
        if (_py >= _sy - 40 && _py <= _sy + 40 && _sy > _best_y) {
            _best_y = _sy;
            _best = _s;
        }
    }

    if (_best == noone) return noone;
    return { stair: _best, y: _best_y };
};
