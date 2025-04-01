/// @description Insert description here
// You can write your code in this editor

// if controlled, do movement
if (controlled == -1) {
	if keyboard_check(vk_left) {
		state = 1
		mob_set_dir(-1, 1)
		mob_move(move_speed * dir, 0, 1)
	} else if keyboard_check(vk_right) {
		state = 1
		mob_set_dir(1, 1)
		mob_move(move_speed * dir, 0, 1)
	} else {
		state = 0
		dx = 0
		last_move_speed = 0
	}
}

var can_move = !collision_rectangle(x + dx, y - 1, x, y + 1, obj_wall, false, true)
if ((can_move) && !(can_client_mob_move())) // only apply dx for the client, fucks up server one
	x += dx