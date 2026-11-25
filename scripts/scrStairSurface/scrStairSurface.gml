// =====================================================================
//  scrStairSurface
//  Shared slope lookup for actors. oStair only draws the flight; the goat
//  and the wolves ask this helper which surface is under their feet.
// =====================================================================

/// @desc Best stair surface under a point (feet), or noone.
///       Returns { stair: instance id, y: surface y }. A switchback landing
///       has two flights, so the lowest matching surface wins.
function stair_surface_at(_px, _py) {
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

        var _t = clamp((_px - _s.x) / (_s.dir * _s.w), 0, 1);
        var _sy = _s.y - _t * _s.h;

        // Wide enough to catch a fall, narrow enough not to grab a flight
        // on the floor below.
        if (_py >= _sy - 40 && _py <= _sy + 40 && _sy > _best_y) {
            _best_y = _sy;
            _best = _s;
        }
    }

    if (_best == noone) return noone;
    return { stair: _best, y: _best_y };
}

/// @desc If an actor just walked off the top of this flight, return the y
///       of the landing slab so it does not sink a few pixels into it.
function stair_top_y(_stair, _actor_x) {
    if (_stair == noone || !instance_exists(_stair)) return noone;

    var _top_x = _stair.x + _stair.dir * _stair.w;
    var _crossed = ((_stair.dir == -1 && _actor_x <= _top_x)
                 || (_stair.dir == 1  && _actor_x >= _top_x));
    if (!_crossed) return noone;
    return _stair.y - _stair.h;
}
