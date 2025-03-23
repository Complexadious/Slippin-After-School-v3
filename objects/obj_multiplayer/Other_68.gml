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
			struct_set(server.clients, string(sock), _pid)
			add_timer(generate_uuid4_string(), adjust_to_fps(1), adjust_to_fps(900))
			
			// send packet back to client
			//var buf = buffer_create(256, buffer_grow, 1)
			//buffer_write(buf, buffer_string, "Connected to server!")
			//network_send_packet(sock, buf, buffer_get_size(buf))
			//buffer_delete(buf)
			break;	
		}
		case network_type_disconnect: {
			_log("Client (" + string(sock) + ") disconnected.")
			
			if struct_exists(network.players, string(sock))
				instance_destroy(sock_to_inst(string(sock)))
			struct_remove(server.clients, string(sock))
			break;	
		}
		case network_type_data: {
//			_log("Recieved data!! Sock = " + string(event_id))
			
			var _buf = async_load[? "buffer"]
			multiplayer_handle_packet(event_id, _buf)
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