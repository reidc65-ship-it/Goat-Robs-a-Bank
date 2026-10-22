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

// The player controller reads these values and snaps the goat to the
// sloped surface. There is deliberately no solid collision mask here.
