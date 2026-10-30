// =====================================================================
//  oCash -> Create
//  Money pickup. Goes into the current heist's loot, not the bank: it is
//  only banked when the goat escapes. Children (oGoldBar, oVaultLoot)
//  change `value` and `kind` after calling event_inherited().
// =====================================================================

game_state_init();

value     = 50;
kind      = "cash";   // "cash", "gold" or "vault"
collected = false;

collect = function() {
    if (collected) return;
    collected = true;

    if (instance_exists(oHeist)) {
        var _heist = instance_find(oHeist, 0);
        _heist.add_loot(value, x, y);
        if (kind == "vault") _heist.on_vault_looted();
    }

    instance_destroy();
};
