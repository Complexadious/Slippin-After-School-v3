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

entity_uuid = (check_is_server()) ? generate_uuid4_string() : ""
if ((entity_uuid != "") && (is_multiplayer()))
	struct_set(obj_multiplayer.network.network_objects, entity_uuid, id)
	
bstep_pos = [-4, -4, 1, 0]
_pcnt = 0

_cb_create_entity(entity_uuid, x, dx, y, dir, object_index)