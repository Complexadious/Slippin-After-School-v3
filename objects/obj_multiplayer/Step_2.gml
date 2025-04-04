var _entities = struct_get_names(network.entities)
for (var i = 0; i < array_length(_entities); i++) {
	// go through every entity, if x or y or dir or dx changed, send (IF SERVER)
	var _entity = network.entities[$ _entities[i]]
	var _instance = _entity.instance
	
	if !check_is_server() { // only sync client pkun
		_instance = obj_pkun //pid_to_inst(client.player.pid)
//		other._log(object_get_name(object_index) + ": gonna sync " + string(_instance))
	} else if !(struct_exists(_entity, "instance")) {
		continue;
	}
	
	with (_instance) {
		var _ls = last_synced
		var _l = last
		var cdx = (x - _l.x) // calculated dx
		
		if ((y == _ls.y) && (cdx == _ls.dx) && (dir == _ls.dir)) {
			if (_ls.pos_check) {
//				_log(object_get_name(object_index) + ": SKIP UPDATE")
				continue;
			} else {
//				other._log(object_get_name(object_index) + ": lsdx=" + string(_ls.dx) + " cal_dx=" + string(cdx) + " ldx = " + string(_l.dx))
//				other._log(object_get_name(object_index) + ": POS DIDNT CHANGE! SEND LAST SHIT!")
				_ls.pos_check = 1
			}
		} else {
			// position changed
			_ls.pos_check = 0
//			other._log(object_get_name(object_index) + ": lsdx=" + string(_ls.dx) + " cal_dx=" + string(cdx) + " ldx = " + string(_l.dx))
//			other._log(object_get_name(object_index) + ": POS CHANGED! SEND SHIT!")
		}
		
		var _ly = _ls.y
		_ls.x = x
		_ls.dx = cdx //dx
		_ls.y = y
		_ls.dir = dir
		
		if !(check_is_server()) && (other.network.server.connection > -1) && (object_index == obj_pkun) { // only sync client pkun
//			show_debug_message("sending PLAY_CB_MOVE_PLAYER_POS to server")
			do_packet(new PLAY_SB_MOVE_PLAYER_POS(-1, x, cdx, y, dir, hiding), other.network.server.connection)
//			show_debug_message("DONE sending PLAY_CB_MOVE_PLAYER_POS to server")
			exit; // we did pkun, skip others
		} else if check_is_server() {
			var _t = struct_get_names(other.server.clients)
			var _state = variable_struct_exists(id, "state") ? state : 0
			
			// do floor stuff optimization
			if !(global.mob_updates_to_clients_on_different_floors) {
				var _flr = get_floor(y)
				for (var i = 0; i < array_length(_t); i++) {
					var __inst = sock_to_inst(_t[i])
					if (__inst != noone) {
						if !(_flr == get_floor(__inst.y)) && (_ly == y) { // floor mismatch, dont need to send, send if y changed tho so it appears on client correct
//							other._log(object_get_name(object_index) + ": DONT NEED TO SEND UPDATE, FLOOR MISMATCH!! (removing " + string(_t[i]) + ")")
							array_delete(_t, i, 1)
						}
					}
				}
			}
			if ((object_index == obj_pkun) || (object_index == obj_network_object)) {
				var _sock = -1
				if !(player_id == obj_multiplayer.server.player.pid) { // prevent warnings of getting invalid pid sock
					_sock = pid_to_sock(player_id)
					_t = array_without(_t, string(_sock))
				}
//				show_debug_message("sending PLAY_CB_MOVE_PLAYER_POS to every sock except " + string(string(_sock)) + ", to socks " + string(_t))
				do_packet(new PLAY_CB_MOVE_PLAYER_POS(player_id, x, cdx, y, dir, hiding), _t)
//				show_debug_message("DONE sending PLAY_CB_MOVE_PLAYER_POS to every sock except " + string(string(_sock)) + ", to socks " + string(_t))
			} else {
//				show_debug_message("sending PLAY_CB_MOVE_ENTITY_POS to " + string(_t))
				do_packet(new PLAY_CB_MOVE_ENTITY_POS(entity_id, x, cdx, y, dir, _state, object_index), _t)
//				show_debug_message("DONE sending PLAY_CB_MOVE_ENTITY_POS to " + string(_t))
			}
		}
	}
}

