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
			
			var _pid = (struct_names_count(server.clients) + 1) // add 1 to account for server pid being 0
			var username = "unsetUsername_" + string(_pid)
			struct_set(server.clients, string(sock), {pid: _pid, connection_state: CONNECTION_STATE.CONNECT})
//			var _player = new player_entity(username, -4, -4, 1, {}, _pid)
//			_player.create()

//			if is_undefined(sock_to_inst(sock)) {
//				_log("Sock (" + string(sock) + ") doesn't have a network object!", logWarningType)
				
////				var target_socks = array_without(struct_get_names(server.clients), sock)
//				//do_packet(new PLAY_CB_CREATE_ENTITY(no.entity_uuid, -4, 0, -4, 0, no.object_index), target_socks)
//				//do_packet(new PLAY_CB_MOVE_ENTITY_POS()(no.entity_uuid, -4, 0, -4, 0, no.object_index), target_socks)
////				do_packet(new PLAY_CB_MOVE_ENTITY_POS(no.entity_uuid, no.x, no.dx, no.y, no.dir, 0, no.object_index), target_socks)
//			}
			
//			for (var i = 0; i < array_length(struct_get_names(server.clients)); i++) {
//				do_packet(generate_game_state_packet(struct_get_names(server.clients)[i]), struct_get_names(server.clients)[i]) //sock)
//			}
			break;	
		}
		case network_type_disconnect: {
			var _msg = "Client (" + string(sock) + ") disconnected."
			_log(_msg)
			
			if instance_exists(obj_pkun) {
				obj_pkun.miniMsgStr = _msg
				obj_pkun.miniMsgTmr = 300
			}
			
			var _tn = (string(sock) + "_SEND_KEEPALIVE_TIMER")
			if struct_exists(network.timers, _tn) {
				struct_remove(network.timers, _tn)
				packetLog("Removed '" + _tn + "' timer.")
			} else {
				packetLog("No '" + _tn + "' timer to remove?", "WARNING")
			}
			
			//server_disconnect(sock)
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
//				obj_multiplayer.network.connection_state++
			} else {
				_log("Connection to server timed out... (type_non_blocking_connect) (" + string(success) + ")")
//				obj_multiplayer.network.connection_state--
			}
			break;	
		}
	}
}