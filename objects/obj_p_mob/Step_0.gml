var can_move = !collision_rectangle(x + dx, y - 1, x, y + 1, obj_wall, false, true)

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
} else if (__disable_ai > 0) { // maybe not when controlled?
	__disable_ai -= adjust_to_fps(1)
	if !(abs(x - target_x) < move_speed) && (can_move) { // dont go past target x and only move when can
		var _ndir = (x < target_x) ? 1 : -1
		if (dir != _ndir)
			mob_set_dir(_ndir)
		mob_move(move_speed * _ndir)
	}
	if (trace_i > -1) && ((abs((x - trace_x[trace_i])) < 50) && (abs((y - trace_y[trace_i])) < 100)) {
		mob_use_portal()
		__disable_ai = 0
	}
	exit;
}

if ((can_move) && !(can_client_mob_move())) // only apply dx for the client, fucks up server one
	x += dx
	
if (closest_target_curr > 0)
	closest_target_curr-= adjust_to_fps(1)
else
{
	closest_target_curr = closest_target_tmr
	current_target = closest_floor_target()
//	show_debug_message(object_get_name(object_index) + " updated current_target = '" + string(current_target) + "'")
}