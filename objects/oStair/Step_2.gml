// oStair -> End Step
// The slope object, not the actors, decides who is standing on a flight.
// Runs after every Step event, so it corrects positions after movement.

/// @desc Put one actor on this flight if this is the surface under it.
place_actor = function(_actor) {
    if (!instance_exists(_actor)) return;

    var _feet = _actor.y + 32;

    // Jumping upward must not re-attach. The player has vsp; guards don't.
    if (variable_instance_exists(_actor, "vsp") && _actor.vsp < -1) {
        if (_actor.on_stair == id) _actor.on_stair = noone;
        return;
    }

    var _hit = best_surface_at(_actor.x, _feet);
    if (_hit != noone && _hit.stair == id) {
        _actor.on_stair = id;
        _actor.y = _hit.y - 32;
        if (variable_instance_exists(_actor, "vsp")) _actor.vsp = 0;
        return;
    }

    // Only the flight the actor was on may clear its own flag.
    if (_actor.on_stair != id) return;
    _actor.on_stair = noone;

    // Crossing the top edge: land on the slab instead of being caught
    // a few pixels below its top face.
    var _top_x = x + dir * w;
    var _top_y = y - h;
    var _crossed = ((dir == -1 && _actor.x <= _top_x)
                 || (dir == 1  && _actor.x >= _top_x));
    if (_crossed) _actor.y = _top_y - 32;
};

// `id` inside each with-block is the actor to place; `other` is this stair.
with (oPlayer)  other.place_actor(id);
with (oWolfCop) other.place_actor(id);
