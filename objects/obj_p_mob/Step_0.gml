/// @description Insert description here
// You can write your code in this editor
var can_move = !collision_rectangle(x + dx, y - 1, x, y + 1, obj_wall, false, true)
if ((can_move) && (!can_client_mob_move())) // only apply dx for the client, fucks up server one
	x += dx