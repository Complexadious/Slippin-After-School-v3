dir = 1
dx = 0
last = {}

show_debug_message("syncable inst created (" + string(object_get_name(object_index)) + ")")
if (is_multiplayer()) {
	if ((object_index == obj_pkun) && (instance_exists(obj_multiplayer))) {
		if (variable_struct_exists(id, "__entity")) {
			__entity.destroy()	
		}
		__entity = new player_entity("CLIENT", x, y, dir, {}, obj_multiplayer.client.player.pid)
		__entity.attach(id)
	} else {
		__entity = new entity(x, y, dir, object_index, depth)
		__entity.attach(id)
	}
}