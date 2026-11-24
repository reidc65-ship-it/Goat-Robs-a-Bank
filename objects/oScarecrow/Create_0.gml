// =====================================================================
//  oScarecrow -> Create
//  The Scout's dash-training dummy. It only goes down when the goat
//  dashes through it, so the tutorial teaches the starter ability.
// =====================================================================

game_state_init();

// The dummy only exists while the Scout's lesson is running. The room
// instance is reused, so clean up when the tutorial is over or not begun.
if (!flag_get("scarecrow_pending") || flag_get("scarecrow_defeated")) {
    instance_destroy();
    exit;
}

max_hp = 2;
hp     = max_hp;
state  = "idle";     // "idle" or "dying"
state_timer = 0;
wobble = 0;
hit_flash = 0;

image_speed = 0;

/// @desc Take a hit. Only a dash counts; the horn just rattles it.
take_damage = function(_amt, _dir, _from_dash = false) {
    if (state == "dying") return;

    if (!_from_dash) {
        wobble = 6;
        if (instance_exists(oPlayer)) {
            instance_find(oPlayer, 0).show_hint(
                "That won't budge it. DASH through it with SHIFT!", 180);
        }
        return;
    }

    hp -= max(1, _amt);
    wobble = 12;
    hit_flash = 8;
    image_blend = c_red;

    repeat (6) {
        effect_create_above(ef_spark,
            x + irandom_range(-22, 22), y - irandom_range(15, 70),
            0, make_colour_rgb(224, 182, 86));
    }

    if (hp <= 0) {
        knock_down();
    } else if (instance_exists(oPlayer)) {
        instance_find(oPlayer, 0).show_hint(
            "Hit! Again - hold A / D and tap SHIFT", 150);
    }
};

/// @desc Fall over, unlock the board, and let the straw fly.
knock_down = function() {
    state = "dying";
    state_timer = 0;

    flag_set("scarecrow_defeated");
    flag_clear("scarecrow_pending");

    effect_create_above(ef_explosion, x, y - 40, 1,
                        make_colour_rgb(224, 182, 86));
    repeat (12) {
        effect_create_above(ef_spark,
            x + irandom_range(-28, 28), y - irandom_range(8, 84),
            0, make_colour_rgb(242, 212, 132));
    }

    if (instance_exists(oPlayer)) {
        instance_find(oPlayer, 0).show_hint(
            "SCARECROW DOWN! Job board unlocked - back to the SCOUT", 300);
    }
};
