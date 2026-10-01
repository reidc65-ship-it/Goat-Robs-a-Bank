// Get player input
key_left = keyboard_check(vk_left);
key_right = keyboard_check(vk_right);
key_jump = keyboard_check_pressed(vk_space);

// horizontal movement 
var move = key_right - key_left;

hsp  = move  * walksp;

vsp =  vsp + grv;

if (place_meeting(x,y+1,oWall)) and (key_jump)
{
	vsp  = -7;
}

// Horizontal collision
if (place_meeting(x+hsp,y,oWall))
{
	while (!place_meeting(x+hsp,y,oWall))
	{
		x = x + sign(hsp);
	}
	hsp = 0;
}

// move player 
x = x + hsp;

// Vertical colision
if (place_meeting(x,y+vsp,oWall))
{
	while (!place_meeting(x,y+vsp,oWall))
	{
		y = y + sign(vsp);
	}
	vsp = 0;
}

// move player 
y = y + vsp;

