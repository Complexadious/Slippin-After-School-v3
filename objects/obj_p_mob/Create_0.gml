//event_inherited()

/// @description Insert description here
// You can write your code in this editor
if !instance_exists(obj_pkun)
	instance_destroy()
mob_init_trace()

//move_speed = 0
last_movement_key = -4
last_move_speed = 0
dx = 0
dir = 1
target_x = 0
state = 0
controlled = 0
move_speed = 0
entity_uuid = ""

_pcnt = 0
closest_target = closest_floor_target()
current_target = closest_target
closest_target_tmr = global.mob_reaction_time
closest_target_curr = 0

//_cb_create_entity(entity_uuid, x, dx, y, dir, object_index)
event_inherited()
