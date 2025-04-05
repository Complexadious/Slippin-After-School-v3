dir = 1
dx = 0
last = {}
parent_pid = -1

variable_struct = {}
if (object_index == obj_police) && (check_is_server()) {
	parent_pid = script_execute_ext(choose, struct_get_names(obj_multiplayer.network.players))
	log("Chose random PID: " + string(parent_pid))
	struct_set(variable_struct, "parent_pid", parent_pid)
}

show_debug_message("syncable inst created (" + string(object_get_name(object_index)) + ")")
if (is_multiplayer()) {
	if ((object_index == obj_pkun) && (instance_exists(obj_multiplayer))) {
		if (variable_struct_exists(id, "__entity")) {
			__entity.destroy()	
		}
		var m = obj_multiplayer
		__entity = new player_entity("CLIENT", x, y, dir, {}, (check_is_server()) ? m.server.player.pid : m.client.player.pid)
		__entity.attach(id)
	} else {
		__entity = new entity(x, y, dir, object_index, depth, (struct_names_count(variable_struct) > 0) ? variable_struct : undefined)
		__entity.attach(id)
	}
}