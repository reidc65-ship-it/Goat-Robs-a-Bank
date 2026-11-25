// Vault guard walks from the vault floor up the final flight to the
// antechamber, then back down to guard the loot.
patrol_points = [
    { x: 1500, y: 3232 },   // vault floor
    { x: 1400, y: 3232 },   // bottom of the vault flight
    { x: 700,  y: 2592 }    // antechamber landing
];
patrol_index = 0;
patrol_dir   = 1;
