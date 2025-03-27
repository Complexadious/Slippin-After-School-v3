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
//			add_timer(generate_uuid4_string(), adjust_to_fps(1), adjust_to_fps(900))
			
			// send packet back to client
			var _entities = []
			var _nos = struct_get_names(network.network_objects)
			for (var i = 0; i < array_length(_nos); i++) {
				with (network.network_objects[$ _nos[i]]) {
					array_push(_entities, [entity_uuid, x, dx, y, dir, object_index])
					var s = (struct_exists(self, "state")) ? state : 0
					//do_packet(new PLAY_CB_MOVE_ENTITY_POS(entity_uuid, x, dx, y, dir, s, object_index), sock)
					if object_index == obj_network_object
						do_packet(new PLAY_CB_MOVE_PLAYER_POS(entity_uuid, x, dx, y, dir), sock)	
				}
			}
			
			do_packet(new PLAY_CB_DESTROY_OBJECT(obj_p_mob), sock)
			if (array_length(_entities) > 0) {
				//do_packet(new PLAY_CB_CREATE_ENTITIES(_entities), sock)
				
				//do_packet(new PLAY_CB_MOVE_ENTITY_POS(_entities.entity_uuid, _entities.x, _entities.dx, _entities.y, _entities.dir, _entities.object_index), sock)	
			}
				
			//if !instance_exists(obj_network_object) {
			if is_undefined(sock_to_inst(sock)) {
				_log("Client (" + string(sock) + ") doesn't have a network object. Adding one now.")
				var no = instance_create_depth(-4, -4, 0, obj_network_object)
				no.network_obj_type = "player"
				no.entity_uuid = generate_uuid4_string()
				struct_set(obj_multiplayer.network.players, sock, no.entity_uuid)
				struct_set(obj_multiplayer.network.network_objects, no.entity_uuid, no.id)
				no.nametag = no.entity_uuid // self.sock
				
				var target_socks = array_without(struct_get_names(server.clients), sock)
				//do_packet(new PLAY_CB_CREATE_ENTITY(no.entity_uuid, -4, 0, -4, 0, no.object_index), target_socks)
				//do_packet(new PLAY_CB_MOVE_ENTITY_POS()(no.entity_uuid, -4, 0, -4, 0, no.object_index), target_socks)
				do_packet(new PLAY_CB_MOVE_ENTITY_POS(no.entity_uuid, no.x, no.dx, no.y, no.dir, 0, no.object_index), target_socks)
			}
				
			
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