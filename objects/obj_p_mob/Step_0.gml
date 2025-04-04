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
	
// mobs only see players within 1000 px
// target is closest within 1000 px
// target is updated every 0.2 seconds for a reaction time
// if target uses a portal, it will add a trace
// will ignore other targettable instances, unless they are within 600 px
// if they are within 600 px, target changes to them
// else, it will go through normal targetting shit

// state 0 = idle
// state 1 = wander
// state 2 = chasing

// global.mob_sight_range = 1000
// global.mob_reaction_time = 15
// global.mob_force_switch_target_range = 600

if (closest_target_curr > 0)
	closest_target_curr-= adjust_to_fps(1)
else
{
	closest_target_curr = closest_target_tmr
	current_target = closest_floor_target()
//	show_debug_message(object_get_name(object_index) + " updated current_target = '" + string(current_target) + "'")
}