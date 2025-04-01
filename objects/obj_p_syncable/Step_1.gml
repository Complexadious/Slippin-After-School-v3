//// save list of all variables and values, if they change send it to the clients!
//inst_vars = array_without(variable_instance_get_names(id), excluded_vars)
//inst_vals = []

//for (var i = 0; i < array_length(inst_vars); i++) {
//	array_push(inst_vals, self[$ inst_vars[i]])
//}

////show_debug_message("Inst vars and vals for object " + string(object_get_name(object_index)) + ":\n- vars: " + string(inst_vars) + "\n-vals: " + string(inst_vals))

//if (object_index != obj_pkun) && (can_client_mob_move())
//	dx = 0
	
// update last pos
last.x = x
last.dx = dx
last.y = y
last.dir = dir