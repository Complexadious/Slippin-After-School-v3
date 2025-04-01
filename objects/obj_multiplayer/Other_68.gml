/// @description Handle Network Requests
var event_id = async_load[? "id"]
//show_debug_message("obj_multiplayer NETWORK EVENT FIRED!")
if ((event_id > -1)) { // == network.server.socket) || (event_id == network.server.connection) || (array_contains(struct_get_names(server.clients), event_id))) {
	var type = async_load[? "type"]
	var sock = async_load[? "socket"]
	var server_sock = async_load[? "server"]
//	_log("EVENT ID!!! " + string(event_id))
	
	switch type { // handle each type
		case network_type_connect: {
			_log("Client (" + string(sock) + ") connected!")
			
			var _pid = struct_names_count(server.clients)
			struct_set(server.clients, string(sock), "unsetUsername_" + string(_pid))
			struct_set(network.players, server.clients[$ sock], generate_uuid4_string())
//			add_timer(generate_uuid4_string(), adjust_to_fps(1), adjust_to_fps(900))
			
			// send packet back to client
			//if instance_exists(obj_pkun)
			//	do_packet(new PLAY_CB_MOVE_PLAYER_POS(server.player.entity_uuid, obj_pkun.x, obj_pkun.dx, obj_pkun.y, obj_pkun.dir, obj_pkun.hiding), sock) // send server pkun
			//do_packet(new PLAY_CB_DESTROY_OBJECT(obj_p_mob), sock) // get rid of existing mobs on connecting client
			
			//var _entities = []
			//var _nos = struct_get_names(network.entities)
			//for (var i = 0; i < array_length(_nos); i++) {
			//	with (network.entities[$ _nos[i]]) {
			//		if (!variable_struct_exists(self, "dx"))
			//			continue;
					
			//		array_push(_entities, [entity_uuid, x, dx, y, dir, object_index])
			//		var s = (struct_exists(self, "state")) ? state : 0
			//		//do_packet(new PLAY_CB_MOVE_ENTITY_POS(entity_uuid, x, dx, y, dir, s, object_index), sock)
			//		if (object_index == obj_network_object) {
			//			// other players
			//			do_packet(new PLAY_CB_MOVE_PLAYER_POS(entity_uuid, x, dx, y, dir, hiding), sock)	
			//		} else {
			//			// mobs
			//			do_packet(new PLAY_CB_MOVE_ENTITY_POS(entity_uuid, x, dx, y, dir, state, object_index), sock)	
			//		}
			//	}
			//}
			
			//// update hiding
			//with (obj_interactable) {
			//	if (type == "hidespot") && !(passenger == -4) {
			//		do_packet(new PLAY_CB_INTERACT_AT(passenger.entity_uuid, type, x, y, 0), sock)	
			//	}
			//}

			if is_undefined(sock_to_inst(sock)) {
				_log("Client (" + string(sock) + ") doesn't have a network object. Adding one now.")
				var no = instance_create_depth(-4, -4, 0, obj_network_object)
				no.network_obj_type = "player"
				no.entity_uuid = network.players[$ sock]
				struct_set(network.entities, no.entity_uuid, no.id)
				no.nametag = no.entity_uuid // self.sock
				
//				var target_socks = array_without(struct_get_names(server.clients), sock)
				//do_packet(new PLAY_CB_CREATE_ENTITY(no.entity_uuid, -4, 0, -4, 0, no.object_index), target_socks)
				//do_packet(new PLAY_CB_MOVE_ENTITY_POS()(no.entity_uuid, -4, 0, -4, 0, no.object_index), target_socks)
//				do_packet(new PLAY_CB_MOVE_ENTITY_POS(no.entity_uuid, no.x, no.dx, no.y, no.dir, 0, no.object_index), target_socks)
			}
			
			for (var i = 0; i < array_length(struct_get_names(server.clients)); i++) {
				do_packet(generate_game_state_packet(struct_get_names(server.clients)[i]), struct_get_names(server.clients)[i]) //sock)
			}
			break;	
		}
		case network_type_disconnect: {
			var _msg = "Client (" + string(sock) + ") disconnected."
			_log(_msg)
			
			if instance_exists(obj_pkun) {
				obj_pkun.miniMsgStr = _msg
				obj_pkun.miniMsgTmr = 300
			}
			
			server_remove_player_inst(sock)
			do_packet(new PLAY_CB_SET_PKUN_MINI_MSG(_msg, 300), struct_get_names(server.clients))
			break;	
		}
		case network_type_data: {
//			_log("Recieved data!! Sock = " + string(event_id))
			
			var _buf = async_load[? "buffer"]
			multiplayer_handle_packet(event_id, _buf)
			global.multiplayer_packets_recieved++
			break;	
		}
		case network_type_non_blocking_connect: {
			var success = async_load[? "succeeded"]
			if (success) {
				_log("Connected to server! (type_non_blocking_connect) (" + string(success) + ")")
				obj_multiplayer.network.connection_state++
			} else {
				_log("Connection to server timed out... (type_non_blocking_connect) (" + string(success) + ")")
				obj_multiplayer.network.connection_state--
			}
			break;	
		}
	}
}