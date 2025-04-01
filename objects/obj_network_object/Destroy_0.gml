/// @description Insert description here
// You can write your code in this editor
show_debug_message("OBJ_NETWORK_OBJECT (" + string(entity_uuid) + ") DESTROYING!")
if struct_exists(obj_multiplayer.network.network_objects, entity_uuid)
	struct_remove(obj_multiplayer.network.network_objects, entity_uuid)