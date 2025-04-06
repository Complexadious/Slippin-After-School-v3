function server_add_client(sock, username, status, data = {}) {
	var client = new _client(sock, username, status, data)
	
	struct_set(obj_multiplayer.server.clients, sock, client)
}

function _client(_sock, _username, _status, _data = {}) constructor {
	sock = _sock
	username = _username
	status = _status
}

function remove_timer(name, run_expiration_func = 0) {
	if struct_exists(obj_multiplayer.network.timers, name)	{
		if (run_expiration_func)
			obj_multiplayer.network.timers[$ name].curr = 0
		else 
			struct_remove(obj_multiplayer.network.timers, name)
	}
}

function add_timer(uuid, _decrease_amt, _dur, _func = undefined, _loop = 0, _remove_on_expiration = 1) {
	var tmr = new multiplayer_timer(_decrease_amt, _dur, _func, _loop, _remove_on_expiration)
	struct_set(obj_multiplayer.network.timers, uuid, tmr)
}

function dt_wrapper(data, type) {
	self.__data_type = type
	self.__data = data
}

function is_dt_wrapper(value) {
	if !(typeof(value) == "struct")
		return 0
	else if (struct_exists(value, "__data_type")) && struct_exists(value, "__data")
		return 1
	else
		return 0
}

function generate_eid() {
	if !instance_exists(obj_multiplayer)
		return -1
	_eid = (MAX_CLIENTS + 1)
	while (array_contains(struct_get_names(obj_multiplayer.network.entities), _eid)) {
		_eid++		
	}
	return _eid
}

function generate_pid() {
	if !instance_exists(obj_multiplayer)
		return -1
	_pid = (MAX_CLIENTS + 1)
	while (array_contains(struct_get_names(obj_multiplayer.network.players), _pid)) {
		_pid++		
	}
	return _pid
}

/// @function multiplayer_timer
/// @param {number} _decrease_amt Amount to decrease per frame
/// @param {number} _dur Starting duration
/// @param {array} _func Optional function to exec on expiration ([FUNC_NAME, [ARGS]])
/// @param {bool} _loop Optional whether to loop or not (Default: 0)
/// @param {bool} _remove_on_expiration Whether to delete struct on expiration
/// @description Constructs a multiplayer timer struct for use within obj_multiplayer
function multiplayer_timer(_decrease_amt, _dur, _func = undefined, _loop = 0, _remove_on_expiration = 1) constructor {
	decrease_amt = _decrease_amt
	duration = _dur
	curr = duration
	func = _func
	loop = _loop
	remove_on_expiration = _remove_on_expiration
}

function start_server(port = SERVER_PORT) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/start_server")}
	
	if !instance_exists(obj_multiplayer) {
		instance_create_depth(0, 0, 999, obj_multiplayer)
		__log("Created 'obj_multiplayer' instance since it didn't exist.")
	}
	
	with (obj_multiplayer) {
		if (network.server.socket > 0) {
			__log("Tried to start already running server. NETWORK_SOCKET_ID: " + string(network.server.socket), logType.warning.def)	
		}
		
		// Create server
		network.server.socket = network_create_server(network_socket_tcp, port, MAX_CLIENTS)
		network.server.connected = 1
		network.role = NETWORK_ROLE.SERVER
		network.connection_state = CONNECTION_STATE.PLAY
		struct_set(network.statistics, "network_server_created_at", current_time)
		_log("Created server! NETWORK_SOCKET_ID: " + string(network.server.socket))
		obj_multiplayer.server.player.pid = 0
	}
}

function join_server(username = "joinserverUnsetUsername", ip = "127.0.0.1", port = SERVER_PORT) {
	var _log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/join_server")}
	
	if !instance_exists(obj_multiplayer) {
		instance_create_depth(0, 0, 999, obj_multiplayer)
		_log("Created 'obj_multiplayer' instance since it didn't exist.")
	}
	
	_log("Starting join process for server '" + string(ip) + ":" + string(port) + "'")
	
	with (obj_multiplayer) {
		if (network.server.connection > -1) {
			// alread connected
			if instance_exists(obj_pkun) { 
				obj_pkun.miniMsgStr = "Unable to join server. Use '/disconnect', then try again."	
				obj_pkun.miniMsgTmr = 300
			}
			exit;
		}
		
		client.player.username = username
		network.connection_state = CONNECTION_STATE.CONNECT
		network.server.socket = network_create_socket(network_socket_tcp)
		network.server.connection = network_connect(network.server.socket, ip, port)
		
		var _rid = floor(random_range(0, 255))
		_log("Joined, sending rid ping (" + string(_rid) + ")")
		
		// start connection process
		do_packet(new CONNECT_SB_PING_REQUEST(-1, _rid), network.server.connection)
	}
}

function leave_server(reason) {
	var _log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/leave_server")}
	
	_log("TRIED TO LEAVE SERVER, REASON = " + string(reason))
	exit;
	
	instance_destroy(obj_network_object);	
	instance_destroy(obj_p_mob);	
	with (obj_multiplayer) {
		do_packet(new PLAY_SB_DISCONNECT(-1, reason), obj_multiplayer.network.server.connection)
		network_destroy(network.server.connection)
		network_destroy(network.server.socket)
		_log("Sent disconnect stuff to server...")
		instance_destroy();
	}
}

function eid_to_entity_struct(eid) {
	if !is_multiplayer()
		return noone
	if struct_exists(obj_multiplayer.network.entities, eid)
		return obj_multiplayer.network.entities[$ eid]
	return noone
}

function pid_to_eid(pid) {
	if !is_multiplayer()
		return -1
	if struct_exists(obj_multiplayer.network.players, pid)
		return obj_multiplayer.network.players[$ pid].entity.entity_id
	return noone
}

function is_our_pid(pid) {
	pid = string(pid)
	if !is_multiplayer() {
		return 1	
	} else if check_is_server() {
		return ((pid == string(obj_multiplayer.server.player.pid)) || (pid == "0") || (pid == "1"))
	} else {
		return (pid == obj_multiplayer.client.player.pid)
	}
}

function mob_id_to_obj(mob_id) {
	var _log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/mob_id_to_obj")}
	mob_id = real(mob_id)
	// cant do struct lookup table ("1": obj_hachi) dumb af
		/*
	global.mob_id_lookup = {
		"1": obj_wpangel,
		"2": obj_ladypaint,
		"3": obj_kuchi,
		"4": obj_jianshi,
		"5": obj_police,
		"6": obj_doppel,
		"7": obj_pianist,
		"8": obj_mary,
		"9": obj_hachi,
		"11": obj_hanako_hide
	}
		*/
	switch mob_id {
		case 1: {return obj_wpangel;}
		case 2: {return obj_ladypaint;}
		case 3: {return obj_kuchi;}
		case 4: {return obj_jianshi;}
		case 5: {return obj_police;}
		case 6: {return obj_doppel;}
		case 7: {return obj_pianist;}
		case 8: {return obj_mary;}
		case 9: {return obj_hachi;}
		case 11: {return obj_hanako_hide;}
		default: {
			_log("Tried to get invalid mob id! (invalid mob id: '" + string(mob_id) + "')")
			return noone
		}
	}
}

function server_remove_player_inst(sock) {
	var _log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/server_remove_player_inst")}
//	var _pid = string(obj_multiplayer.server.clients[$ sock].pid)
	if !check_is_server()
		exit; // only as server dumbass
	
	_log("Removing player (" + string(sock) + ", '" + "')")
	
	var _pid = sock_get_pid(sock)
	var _eid = pid_to_eid(_pid)
	var _es = eid_to_entity_struct(_eid)
	
	if (_es != noone) && (_es != -4) && (struct_exists(_es, "destroy")) {
		_es.destroy()
	} else if (_es != -4) {
		_log("Can't find sock's entity struct (" + string(_es) + ") or it doesn't contain a 'destroy' method?", logType.error.not_found)
		do_packet(new PLAY_CB_DESTROY_ENTITY(_es.entity_id), struct_get_names(obj_multiplayer.server.clients))
	} else {
		_log("_es evaluated to '" + string(_es) + "'", logType.error.not_found)	
	}
	if struct_exists(network.entities, _eid)
		struct_remove(network.entities, _eid)
	if struct_exists(network.players, _pid)
		struct_remove(network.players, _pid)
	if struct_exists(server.clients, string(sock))
		struct_remove(server.clients, string(sock))
	//var _inst = sock_to_inst(string(sock))
	
	//if ((_inst == noone) || (!instance_exists(_inst))) {
	//	_log("Tried to remove non-existent sock inst! (" + string(sock) + ")")
	//	exit;
	//}
	
	//// unhide if hiding in non-hidebox
	//if ((_inst.hiding) && (_inst.hidebox == -4)) {
	//	var _intr_target = instance_nearest(_inst.x, _inst.y, obj_interactable)
	//	with (_intr_target) {
	//		if (distance_to_object(_inst) <= 50) {
	//			_log("Inst to remove is hiding. Nearest interactable is " + string(_intr_target))
	//			do_packet(new PLAY_CB_INTERACT_AT(obj_multiplayer.server.player.pid, _intr_target.type, _intr_target.x, _intr_target.y, 0), struct_get_names(obj_multiplayer.server.clients))
	//		} else {
	//			_log("Inst to remove is hiding. Nearest interactable is too far, skipping...")	
	//		}
	//	}
	//}
}

function close_server() {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/start_server")}
	__log("Attempting to close server...")
	if !instance_exists(obj_multiplayer)
		return 1
	
	with (obj_multiplayer) {
		if (network.server.socket > 0) {
			network_destroy(network.server.socket)
			network.server.socket = -1
			network.server.connected = 0
			
			network.role = NETWORK_ROLE.CLIENT
			struct_set(network.statistics, "network_server_socket_destroyed_at", current_time)
			
			__log("Server is closed. (Socket destroyed!)")
			instance_destroy();
		}
	}
	
	with (obj_pkun) { // generate server pkun's entity uuid
		entity_id = ""
	}
}

function is_multiplayer() {
	return (instance_exists(obj_multiplayer))	
}

function check_is_server() {
	if !is_multiplayer()
		return 0
	return (obj_multiplayer.network.role == NETWORK_ROLE.SERVER)
}

function multiplayer_queue_packet(sockets, buffer) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/multiplayer_queue_packet")}
	if !is_array(sockets) sockets = [sockets]
	for (var i = 0; i < array_length(sockets); i++) {
		var sock = sockets[i]
		with (obj_multiplayer) {
			if !struct_exists(network.packet_queue, sock)
				struct_set(network.packet_queue, sock, [])
			array_push(network.packet_queue[$ sock], buffer)
		}
		global.multiplayer_packets_queued++
		__log("Sent packet to queue! (" + string(sock) + ")")
	}
}

function multiplayer_send_packet(sockets, buffer) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/multiplayer_send_packet")}
	if !is_array(sockets) sockets = [sockets]
	__log("Starting")
	for (var i = 0; i < array_length(sockets); i++) {
		__log("In socket " + string(sockets[i]))
		if instance_exists(obj_multiplayer) {
			// throttle if too much
			__log("In multiplayer " + string(sockets[i]))
			var _network = obj_multiplayer.network
			if (_network.statistics.pps > _network.settings.max_pps_goal) {
				__log("PPS IS OVER MAX PPS GOAL!! THROTTLING!!")
				exit;
			}
			obj_multiplayer.network.statistics.pps++
		}
		__log("about to send packet")
		network_send_packet(real(sockets[i]), buffer, buffer_get_size(buffer))
		global.multiplayer_packets_sent++
		__log("Sent packet out! (" + string(sockets[i]) + ")")
	}
}

function multiplayer_handle_packet(sock, buffer) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/multiplayer_handle_packet")}
	buffer_seek(buffer, buffer_seek_relative, 0)
	
	var packet_count = buffer_read_ext(buffer)
	var _decombined_packets = packet_buffer_decombine(buffer)
	
	__log("Got " + string(packet_count) + " packets!")
	
	for (var i = 0; i < array_length(_decombined_packets); i++) {
		var _pkt_buff = _decombined_packets[i]
		buffer_seek(_pkt_buff, buffer_seek_relative, 0)
		var packet_id = buffer_read_ext(_pkt_buff)
		buffer_seek(_pkt_buff, buffer_seek_relative, 0)
		if ds_map_exists(global.packet_registry, packet_id) {
			var pkt = new global.packet_registry[? packet_id](sock)
			if (check_is_server()) {
				var _sock_state = sock_get_state(sock)
				if !(pkt.__options.connection_state == _sock_state) {
					__log("Ignoring recieved packet from sock (" + string(sock) + ") due to connection_state mismatch! (packet_title: '" + string(pkt.__options.packet_title) + "', sock_state: '" + string(_sock_state) + "', recieved packet_state:'" + string(pkt.__options.connection_state) + "')", logType.warning.def)
					exit;
				}
			} else {
				if !(pkt.__options.connection_state == obj_multiplayer.network.connection_state) {
					__log("Ignoring recieved packet due to connection_state mismatch! (packet_title: '" + string(pkt.__options.packet_title) + "', connection_state: '" + string(obj_multiplayer.network.connection_state) + "', recieved packet_state:'" + string(pkt.__options.connection_state) + "')", logType.warning.def)
					exit;
				}
			}
			pkt.readPacketData(_pkt_buff)
			pkt.processPacket()
		} else {
			__log("Packet ID not found in packet registry! (Packet ID: " + string(packet_id) + ")", logType.warning.def)
		}
		buffer_delete(_pkt_buff)
	}
}

function eid_to_inst(eid) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/eid_to_inst")}
	eid = string(eid)
	if (!is_multiplayer()) {
		__log("Tried to get instance from eid '" + eid + "' while not in multiplayer! (Returning noone)", logType.warning.not_multiplayer)
		return noone
	}
	if (struct_exists(obj_multiplayer.network.entities, eid)) {
		var _entity = obj_multiplayer.network.entities[$ eid]
		if (struct_exists(_entity, "instance")) {
			return _entity.instance
		} else {
			__log("Failed to get instance, eid '" + eid + "' in 'network.entities' doesn't have 'instance'! (Returning noone)", logType.error.not_found)
		}
	} else {
		__log("Failed to get instance, eid '" + eid + "' doesn't exist in 'network.entities'! (Returning noone)", logType.error.not_found)
	}
	return noone
}

function pid_to_inst(pid) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/pid_to_inst")}
	pid = string(pid)
	if (!is_multiplayer()) {
		__log("Tried to get instance from pid '" + pid + "' while not in multiplayer! (Returning noone)", logType.warning.not_multiplayer)
		return noone
	}
	if (struct_exists(obj_multiplayer.network.players, pid)) {
		var _plr = obj_multiplayer.network.players[$ pid]
		if (struct_exists(_plr, "entity")) {
			if (struct_exists(_plr[$ "entity"], "instance")) {
				return _plr.entity.instance
			} else {
				__log("Failed to get instance, pid '" + pid + "' in 'network.players' has 'entity' but not 'entity.instance'! (Returning noone)", logType.error.not_found)
			}
		} else {
			__log("Failed to get instance, pid '" + pid + "' in 'network.players' doesn't have 'entity'! (Returning noone)", logType.error.not_found)
		}
	} else {
		__log("Failed to get instance, pid '" + pid + "' doesn't exist in 'network.players'! (Returning noone)", logType.error.not_found)
	}
	return noone
}

function sock_to_inst(sock) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/sock_to_inst")}
	if (!is_multiplayer()) {
		__log("Tried to get sock '" + sock + "' instance while not in multiplayer! (Returning noone)", logType.warning.not_multiplayer)
		return noone
	} else if (!check_is_server()) {
		__log("Tried to get sock '" + sock + "' instance as client! (Returning noone)", logType.warning.server_action_as_client)
		return noone
	}
	sock = string(sock)
	var _pid = sock_get(sock, "pid", -1)
	if (_pid > -1) {
		return pid_to_inst(_pid) // pid
	} else {
		__log("Failed to get instance, sock '" + sock + "' doesn't exist in 'server.clients'! (Returning noone)", logType.error.not_found)
	}
	return noone
}

function is_controlling_cam_target() {
	if !instance_exists(obj_camera)
		return 0
	var ct = obj_camera.camTarget
	if (obj_camera.camTarget == -4)
		return 0
	else if instance_exists(obj_camera.camTarget) {
		return (variable_instance_exists(ct.id, "controlled")) ? (ct.controlled == -1) : 0
	} else
		return 0	
}

function num_to_pos(value) {
	// X: 15 bits, Y: 14 bits, DIR: 1 bit, AGAINST_WALL: 1 bit, FLASHLIGHT_ON: 1 bit
	value = int64(value)		
	var total_bits = BP_Y_ALLOCATION + BP_DIR_ALLOCATION + BP_AW_ALLOCATION + BP_FLASH_ALLOCATION
	var _x = logical_rshift(value, total_bits); total_bits -= BP_Y_ALLOCATION
	var _y = (logical_rshift(value, total_bits) & int64(power(2, BP_Y_ALLOCATION) - 1)); total_bits -= BP_DIR_ALLOCATION
	var _dir = (logical_rshift(value, total_bits) & int64(power(2, BP_DIR_ALLOCATION) - 1)); total_bits -= BP_AW_ALLOCATION
	var _aw = (logical_rshift(value, total_bits) & int64(power(2, BP_AW_ALLOCATION) - 1)); total_bits -= BP_FLASH_ALLOCATION
	var _flash = (logical_rshift(value, total_bits) & int64(power(2, BP_FLASH_ALLOCATION) - 1));
			
	// make _dir 1 or -1
	if (_dir != 1) _dir = -1;
	return [_x, _y, _dir, _aw, _flash]
}

function server_player_count() {
	if check_is_server()
		return struct_names_count(obj_multiplayer.server.clients)
	return -1
}

function sock_get(sock, value, fallback = -4) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/sock_get")}
	value = string(value); sock = string(sock);
	if (!is_multiplayer()) {
		__log("Tried to get '" + value + "' from sock '" + sock + "' while not in multiplayer! (Returning fallback '" + string(fallback) + "')", logType.warning.not_multiplayer)
		return fallback
	} else if (!check_is_server()) {
		__log("Tried to get '" + value + "' from sock '" + sock + "' as a client! (Returning fallback '" + string(fallback) + "')", logType.warning.server_action_as_client)
		return fallback
	}
	if (struct_exists(obj_multiplayer.server.clients, sock)) {
		if (struct_exists(obj_multiplayer.server.clients[$ sock], value)) {
			return obj_multiplayer.server.clients[$ sock][$ value]
		} else {
			__log("Tried to get non-existent value '" + value + "' from sock '" + sock + "'! (Returning fallback '" + string(fallback) + "')", logType.error.not_found)
			return fallback
		}
	} else {
		__log("Tried to get '" + value + "' from non-existent sock '" + sock + "'! (Returning fallback '" + string(fallback) + "')", logType.error.not_found)
		return fallback
	}
}

function sock_set(sock, variable, value) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/sock_set")}
	variable = string(variable); sock = string(sock);
	if (!is_multiplayer()) {
		__log("Setting sock '" + sock + "' '" + variable + "' to '" + string(value) + "' while not in multiplayer!", logType.warning.not_multiplayer)
	} else if (!check_is_server()) {
		__log("Setting sock '" + sock + "' '" + variable + "' to '" + string(value) + "' as a client!", logType.warning.server_action_as_client)
	}
	if (struct_exists(obj_multiplayer.server.clients, sock)) {
		if !(struct_exists(obj_multiplayer.server.clients[$ sock], value)) {
			__log("'" + variable + "' was previously undefined/unset for sock '" + sock + "'", logType.warning.def)
		}
		struct_set(obj_multiplayer.server.clients[$ sock], variable, value)
		__log("Set sock '" + sock + "' '" + variable + "' to '" + string(value) + "'")
	} else {
		__log("Tried to set non-existent sock '" + sock + "' '" + variable + "' to '" + string(value) + "'", logType.error.not_found)
	}
}

function pid_to_sock(pid) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/pid_to_sock")}
	if (!is_multiplayer()) {
		__log("Tried to get a sock from a PID while not in multiplayer! (attempted pid to use: " + string(pid) + ")", logType.warning.not_multiplayer)
		return -1
	} else if (!check_is_server()) {
		__log("Tried to get a sock from a PID as a client! (attempted pid to use: " + string(pid) + ")", logType.warning.server_action_as_client)
		return -1
	}
	var _clients = struct_get_names(obj_multiplayer.server.clients)
	for (var i = 0; i < array_length(_clients); i++) {
		if (string(obj_multiplayer.server.clients[$ _clients[i]].pid) == string(pid))
			return _clients[i]
	}
	__log("Unable to find sock from pid (returnning '-1')! (attempted pid to use: " + string(pid) + ")", logType.error.not_found)
	return -1
}

function sock_get_pid(sock) {
	return sock_get(sock, "pid", -1)
}

function sock_get_state(sock) {
	return sock_get(sock, "connection_state", -1)
}

function sock_set_state(sock, state) {
	sock_set(sock, "connection_state", state)
}

function run_entity_event(event_id, object_index = -4, data = undefined) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/run_entity_event")}
	__log("Running event_id: '" + string(event_id) + "' for obj_index: '" + string(object_index) + "'")
	switch event_id {
		case EVENT_ID.JIANSHI_SEAL: { // seal jianshi
			__log("Running event_id: '" + string(event_id) + "' (EVENT_ID.JIANSHI_SEAL) for obj_index: '" + string(object_index) + "'")
			if instance_exists(obj_jianshi) {
				__log("Sealing obj_jianshi")
				with (obj_jianshi) {
					play_se_at(se_seal, x, y)
		            sealed = 1
				}
			} else {
				__log("Failed to run event_id, obj_jianshi doesnt exist.")	
			}
			break;
		} case EVENT_ID.HACHI_WARP: { // hachi warp
			__log("Running event_id: '" + string(event_id) + "' (EVENT_ID.HACHI_WARP) for obj_index: '" + string(object_index) + "'")
			if instance_exists(obj_hachi) {
				__log("Warping obj_hachi")
				with (obj_hachi) {
		            warpDelay = 300
					x += (350 * dir)
		            mob_play_ds(se_warp)
				}
			} else {
				__log("Failed to run event_id, obj_hachi doesnt exist.")	
			}
			break;
		} case EVENT_ID.POLICE_SWITCH: { // police stop/go switch
			__log("Running event_id: '" + string(event_id) + "' (EVENT_ID.POLICE_SWITCH) for obj_index: '" + string(object_index) + "'")
			if instance_exists(obj_police) {
				__log("Switching obj_police")
				with (obj_police) {
					stopTimer = data[0]
					delay = data[1]
					stop = !stop
					stopAt = -1
			        if stop
			            set_sprite(spr_police_stop, 0.5)
			        else
			            set_sprite(spr_police_go, 0.5)
				}
			} else {
				__log("Failed to run event_id, obj_police doesnt exist.")	
			}
			break;
		}
	}
}

// CONSTRUCTORS

function entity(X, Y, DIR, OBJECT_INDEX, DEPTH_OR_LAYER, VARIABLES_STRUCT = {}, EID = -1, CREATE_ON_CLIENTS = 1) constructor {
	var e = self
	e.entity_id = (EID != -1) ? EID : generate_eid()
	e.x = X
	e.dx = 0
	e.y = Y
	e.dir = DIR
	e.instance = -4
	// "__" before variable means it wont applied to instance self on creation
	e.__object_index = OBJECT_INDEX
	e.__variables_struct = VARIABLES_STRUCT
	e.__depth_or_layer = DEPTH_OR_LAYER
	e.__sync_on_clients = CREATE_ON_CLIENTS
	e.last_synced = {
		x: e.x,
		dx: e.x,
		y: e.x,
		dir: e.x,
		pos_check: 0,
	}
	e.last = {
		x: e.x,
		dx: e.x,
		y: e.x,
		dir: e.x,
	}

	entityLog = function(msg, type = logType.info.def, src_func = "unspecifiedFunc") {
		var e = self
		var _obj_name = object_get_name(e.__object_index)
		log(msg, type, "ENTITY/" + _obj_name + "/" + string(src_func))
	}
	create = function() {
		var e = self
		var __log = function (msg, type = logType.info.def) {entityLog(msg, type, "create")}
		
		__log("Started creation process for '" + object_get_name(e.__object_index) + "' entity:")
		
		// check if eid already exists in shit
		if instance_exists(obj_multiplayer) {
			if struct_exists(obj_multiplayer.network.entities, e.entity_id)	{
				__log("Our EID exists in 'network.entities'!", logType.warning.def)
				
				if (obj_multiplayer.network.entitles.object_index == e.__object_index) {
					__log("Duplicated EID entity has same object index! Going to try and attach to it instead!", logType.warning.def)
					attach(eid_to_inst(e.entity_id).id)
					__log("Attachment might be successful?", logType.warning.def)
					exit;
				} else {
					__log("Duplicated EID entity doesn't have the same object index! Destroying it!", logType.warning.def)
					eid_to_entity_struct(e.entity_id).destroy()
					__log("Destroying might be successful?", logType.warning.def)
				}
			} else {
				__log("Our EID doesn't exist in 'network.entities'!", logType.info.def)
			}
		}
		
		if (typeof(e.__depth_or_layer) == "string") { // layer
			e.instance = instance_create_layer(e.x, e.y, e.__depth_or_layer, e.__object_index, e.__variables_struct)
		} else {
			e.instance = instance_create_depth(e.x, e.y, real(e.__depth_or_layer), e.__object_index, e.__variables_struct)
		}
		__log("- Created entity instance (" + string(e.instance) + ")")
		__log("- Applying entity (e) variables to instance:")
		var _vars = struct_get_names(e)
		for (var i = 0; i < array_length(_vars); i++) {
			var _var = string(_vars[i]), _val = e[$ _var]
			
			if string_starts_with(_var, "__") {
				__log(" - Skipping '" + _var + "' (starts with '__')")
			} else if (typeof(_val) == "method") {
				__log(" - Skipping '" + _var + "' (entity method)")
			} else {
				with (e.instance) {
					__log(" - Set '" + string(_var) + "' to '" + string(_val) + "'")
					variable_instance_set(id, _var, _val)
				}
			}
		}
		__log("- Applying entity __variables_struct to instance:")
		_vars = struct_get_names(e.__variables_struct)
		for (var i = 0; i < array_length(_vars); i++) {
			var _var = string(_vars[i])
			if string_starts_with(_var, "__") {
				__log(" - Skipping '" + _var + "'")
			} else {
				with (e.instance) {
					var _val = e.__variables_struct[$ _var]
					__log(" - Set '" + string(_var) + "' to '" + string(_val) + "'")
					variable_instance_set(id, _var, _val)
				}
			}
		}
		if !instance_exists(obj_multiplayer) {
			__log("- Created 'obj_multiplayer' instance since it didn't already exist.")
			instance_create_depth(0, 0, 0, obj_multiplayer)
		}
		struct_set(obj_multiplayer.network.entities, e.entity_id, self)
		__log("Created '" + object_get_name(e.__object_index) + "' entity! (x" + string(e.instance.x) + ", y" + string(e.instance.y) + ")")
		if (__sync_on_clients) && (check_is_server()) {
			__log("Sending create entity packet to clients!")
			do_packet(new PLAY_CB_CREATE_ENTITY(e.entity_id, e.x, e.dx, e.y, e.dir, e.__object_index, e.__variables_struct), struct_get_names(obj_multiplayer.server.clients))
		} else {
			__log("Not sending create entity packet to clients, '__sync_on_clients' is 'false', or not server.")
		}
	}
	attach = function(id) {
		var e = self
		var __log = function (msg, type = logType.info.def) {entityLog(msg, type, "attach")}
		
		e.instance = id
		
		__log("Started attachment process for '" + object_get_name(e.__object_index) + "' entity:")
		__log("- Entity instance already exists (" + string(e.instance) + ")")
		__log("- Applying entity (e) variables to instance:")
		var _vars = struct_get_names(e)
		for (var i = 0; i < array_length(_vars); i++) {
			var _var = string(_vars[i]), _val = e[$ _var]
			
			if string_starts_with(_var, "__") {
				__log(" - Skipping '" + _var + "' (starts with '__')")
			} else if (typeof(_val) == "method") {
				__log(" - Skipping '" + _var + "' (entity method)")
			} else {
				with (e.instance) {
					__log(" - Set '" + string(_var) + "' to '" + string(_val) + "'")
					variable_instance_set(id, _var, _val)
				}
			}
		}
		__log("- Applying entity __variables_struct to instance:")
		_vars = struct_get_names(e.__variables_struct)
		for (var i = 0; i < array_length(_vars); i++) {
			var _var = string(_vars[i])
			if string_starts_with(_var, "__") {
				__log(" - Skipping '" + _var + "'")
			} else {
				with (e.instance) {
					var _val = self[$ _var]
					__log(" - Set '" + string(_var) + "' to '" + string(_val) + "'")
					variable_instance_set(id, _var, _val)
				}
			}
		}
		if !instance_exists(obj_multiplayer) {
			__log("- Created 'obj_multiplayer' instance since it didn't already exist.")
			instance_create_depth(0, 0, 0, obj_multiplayer)
		}
		struct_set(obj_multiplayer.network.entities, e.entity_id, self)
		if (e.instance) && (instance_exists(e.instance)) {
			__log("Attached to '" + string(e.instance) + "' entity! (x" + string(e.instance.x) + ", y" + string(e.instance.y) + ")")
		} else {
			__log("Not sure if properly attached. e.instance is not evaluated to true! (e.instance = " + string(e.instance ?? "??NULL??") + ")", "WARNING")
		}
		if (__sync_on_clients) && (check_is_server()) && (e.instance) && (instance_exists(e.instance)) {
			__log("Sending create entity packet to clients!")
			do_packet(new PLAY_CB_CREATE_ENTITY(e.entity_id, e.x, e.dx, e.y, e.dir, e.__object_index, e.__variables_struct), struct_get_names(obj_multiplayer.server.clients))
		} else {
			if (e.instance) && (instance_exists(e.instance)) {
				__log("Not sending create entity packet to clients, '__sync_on_clients' is 'false', or not server.")
			} else {
				__log("Not sending create entity packet to clients, e.instance doesn't evaluate to true... (e.instance = " + string(e.instance ?? "??NULL??") + ")", "WARNING")	
			}
		}
	}
	destroy = function() {
		var e = self
		var __log = function (msg, type = logType.info.def) {entityLog(msg, type, "destroy")}

		__log("Started destroy process for '" + object_get_name(e.__object_index) + "' entity:")
		__log("- Destroying '" + object_get_name(e.__object_index) + "' instance")
		instance_destroy(e.instance)
		if instance_exists(obj_multiplayer) {
			__log("- Removing entity from obj_multiplayer entities struct.")
			struct_remove(obj_multiplayer.network.entities, e.entity_id)
		} else {
			__log("- Cannot remove entity from entities struct, obj_multiplayer instance doesn't exist.", logType.warning.def)	
		}
		__log("Destroyed '" + object_get_name(e.__object_index) + "' entity!")
		if (__sync_on_clients) && (check_is_server()) && (e.instance) && (instance_exists(e.instance)) {
			__log("Sending destroy entity packet to clients!")
			do_packet(new PLAY_CB_DESTROY_ENTITY(e.entity_id), struct_get_names(obj_multiplayer.server.clients))
		} else {
			if (e.instance) && (instance_exists(e.instance)) {
				__log("Not sending destroy entity packet to clients, '__sync_on_clients' is 'false', or not server.")
			} else {
				__log("Not sending destroy entity packet to clients, e.instance doesn't evaluate to true... (e.instance = " + string(e.instance ?? "??NULL??") + ")", "WARNING")	
			}
		}
	}
	var __log = function (msg, type = logType.info.def) {entityLog(msg, type, "structInit")}
	__log("Entity struct created! (" + object_get_name(e.__object_index) + ")")
}

function player_entity(USERNAME, X, Y, DIR, VARIABLES_STRUCT = {}, PLAYER_ID = undefined, CREATE_NETWORK_OBJ = 1) constructor {
	var p = self
	p.player_id = (is_undefined(PLAYER_ID)) ? ((instance_exists(obj_multiplayer)) ? struct_names_count(obj_multiplayer.network.players) + 1 : 0) : real(PLAYER_ID)
	p.username = string(USERNAME)
	p.__x = X
	p.__y = Y
	p.dir = DIR
	p.__object_index = obj_network_object
	var _vs = {"network_obj_type": "player", "username": p.username, "nametag": p.username, "player_id": p.player_id}
	p.entity = new entity(p.__x, p.__y, p.dir, p.__object_index, 0, _vs, p.player_id, 0)
	p.create_new_network_obj = CREATE_NETWORK_OBJ
	
	kick = function() {
		exit;
	}
	entityLog = function(msg, type = logType.info.def, src_func = "unspecifiedFunc") {
		var p = self
		log(msg, type, "PLAYER_ENTITY/" + p.username + "/" + string(src_func))
	}
	create = function() {
		var p = self
		var __log = function (msg, type = logType.info.def) {entityLog(msg, type, "create")}
		__log("Create ran for player entity, passthrough to entity.create")
		
		if p.create_new_network_obj {
			p.entity.create()
			struct_set(obj_multiplayer.network.players, p.player_id, self)
		} else {
			__log("- p.create_new_network_obj is 0, cancelling create...", logType.warning.def)
			exit;
		}
	}
	attach = function(_id) {
		var p = self
		var __log = function (msg, type = logType.info.def) {entityLog(msg, type, "attach")}
		__log("Attach ran for player entity, passthrough to entity.attach")
//		p.__object_index = _id.object_index
		p.entity.attach(_id)
		struct_set(obj_multiplayer.network.players, p.player_id, self)
	}
	destroy = function() {
		var p = self
		var __log = function (msg, type = logType.info.def) {entityLog(msg, type, "destroy")}
		__log("Destroy ran for player entity, passthrough to entity.destroy")
		p.entity.destroy()
		if instance_exists(obj_multiplayer) {	
			__log("- Removing player from obj_multiplayer players struct.")
			struct_remove(obj_multiplayer.network.players, p.player_id)
		} else {
			__log("- Cannot remove entity from players struct, obj_multiplayer instance doesn't exist.", logType.warning.def)	
		}
	}
	var __log = function (msg, type = logType.info.def) {entityLog(msg, type, "structInit")}
	__log("Player struct created! (" + p.username + ")")
}

//function player(SOCK, USERNAME) constructor {
//	self.sock = SOCK
//	self.username = USERNAME
//	self.network_object = instance_Create
//	self.entity_id = 
//}

////
//// PACKETS
////

global.packet_registry = ds_map_create()

/* base */
function BASE_PACKET(_id = -1) constructor {
	self.__id = _id
	self.__options = {
		connection_state: CONNECTION_STATE.CONNECT,
		packet_title: "BASE_PACKET",
		packet_size: -1
	}
	readPacketData = function(buf) {
		exit;
	}
	writePacketData = function() {
		exit;
	}
	processPacket = function() {
		exit;
	}
}

/* CONNECT (ID 5-10) */
function CONNECT_SB_PING_REQUEST(SOCK = -1, RID = -1) constructor {
	self.__id = 5
	self.__options = {
		connection_state: CONNECTION_STATE.CONNECT,
		packet_title: "CONNECT_SB_PING_REQUEST",
		packet_size: -1
	}
	
	self.sock = SOCK
	self.rid = RID
	struct_set(obj_multiplayer.network.connection_state_data, "connect_rid", RID)
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.rid = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(2, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_vint, self.rid)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// as server, send it back
		packetLog("Recieved Ping! (RID: " + string(self.rid) + ") from sock '" + string(self.sock) + "', sending it back")
		do_packet(new CONNECT_CB_PONG_RESPONSE(self.rid), self.sock)
		exit;
	}
}
ds_map_add(global.packet_registry, 5, CONNECT_SB_PING_REQUEST)

function CONNECT_CB_PONG_RESPONSE(RID = -1) constructor {
	self.__id = 6
	self.__options = {
		connection_state: CONNECTION_STATE.CONNECT,
		packet_title: "CONNECT_CB_PONG_RESPONSE",
		packet_size: -1
	}
	
	self.rid = RID
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.rid = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(2, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_vint, self.rid)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// client
		if (self.rid == obj_multiplayer.network.connection_state_data.connect_rid) {
			packetLog("Recieved correct PONG! (RID: " + string(self.rid) + ")")
			packetLog("Server is valid! Sending confirmation packet back...")
			packetLog("CONNECTION_STATE IS NOW 'CONFIGURATION'")
			obj_multiplayer.network.connection_state = CONNECTION_STATE.CONFIGURATION
			do_packet(new CONNECT_SB_CONNECTION_CONFIRMATION(-1), obj_multiplayer.network.server.connection)
		} else {
			packetLog("Recieved incorrect PONG! (EXPECTED RID: '" + string(obj_multiplayer.network.connection_state_data.connect_rid) + "', RECIEVED RID: '" + string(self.rid) + "')", "WARNING")
		}
	}
}
ds_map_add(global.packet_registry, 6, CONNECT_CB_PONG_RESPONSE)

function CONNECT_SB_CONNECTION_CONFIRMATION(SOCK = -1) constructor {
	self.__id = 7
	self.__options = {
		connection_state: CONNECTION_STATE.CONNECT,
		packet_title: "CONNECT_SB_CONNECTION_CONFIRMATION",
		packet_size: -1
	}

	self.sock = SOCK
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(2, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// server
		packetLog("Recieved connection confirmation from sock (" + string(self.sock) + ")!")
		packetLog("SOCK '" + string(self.sock) + "' CONNECTION_STATE IS NOW 'CONFIGURATION'")
		sock_set_state(self.sock, CONNECTION_STATE.CONFIGURATION)
		packetLog("Sending Client Info request..." + string(self.sock))
		do_packet(new CONFIGURATION_CB_REQUEST_CLIENT_INFO(), self.sock)
	}
}
ds_map_add(global.packet_registry, 7, CONNECT_SB_CONNECTION_CONFIRMATION)

/* CONFIGURATION (ID 11-30) */

//first send client info over, if its correct, we get confirmation, then game state
function CONFIGURATION_CB_REQUEST_CLIENT_INFO() constructor {
	self.__id = 11
	self.__options = {
		connection_state: CONNECTION_STATE.CONFIGURATION,
		packet_title: "CONFIGURATION_CB_REQUEST_CLIENT_INFO",
		packet_size: -1
	}

	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(2, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// client
		packetLog("Recieved client information request from server (" + string(obj_multiplayer.network.server.connection) + "). Sending client info!")
		
		var __x = (instance_exists(obj_pkun)) ? obj_pkun.x : -4
		var __dx = (instance_exists(obj_pkun)) ? obj_pkun.dx : 0
		var __y = (instance_exists(obj_pkun)) ? obj_pkun.y : -4
		var __dir = (instance_exists(obj_pkun)) ? obj_pkun.dir : 1
		
		do_packet(new CONFIGURATION_SB_CLIENT_INFO(-1, obj_multiplayer.client.player.username, [__x, __dx, __y, __dir]), obj_multiplayer.network.server.connection)
	}
}
ds_map_add(global.packet_registry, 11, CONFIGURATION_CB_REQUEST_CLIENT_INFO)

function CONFIGURATION_SB_CLIENT_INFO(SOCK = -1, USERNAME = "", POS = [-4, 0, -4, 1]) constructor {
	self.__id = 12
	self.__options = {
		connection_state: CONNECTION_STATE.CONFIGURATION,
		packet_title: "CONFIGURATION_SB_CLIENT_INFO",
		packet_size: -1
	}

	self.sock = SOCK
	self.client_username = USERNAME
	self.client_pos = POS
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.client_username = buffer_read_ext(buf)
		self.client_pos = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(2, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_string, self.client_username)
		buffer_write_ext(buf, buffer_position, self.client_pos)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// server
		packetLog("Recieved client information from sock (" + string(self.sock) + "):")
		packetLog("- Username: '" + string(self.client_username) + "'")
		packetLog("- Position: '" + string(self.client_pos) + "'")
		
		var _approved = 1
		var _reason = ""
		var _p = self.client_pos
		
		if (_approved) {
			packetLog("Client sock (" + string(self.sock) + ") is approved. Applying their information now. (adding player_entity)")
			var _player = new player_entity(self.client_username, _p[0], _p[2], _p[3], {"dx": _p[1]})
			_player.create()
			packetLog("Created new player_entity for them. player_entity: " + string(_player))
			packetLog("Their PID is (" + string(_player.player_id) + ")")
			
		} else {
			packetLog("Client sock (" + string(self.sock) + ") is denied. Terminating join process for them. Reason: '" + string(_reason) + "'")
			struct_remove(obj_multiplayer.server.clients, string(self.sock))
		}
		do_packet(new CONFIGURATION_CB_CLIENT_INFO_CONFIRMATION(_approved, _reason), self.sock)
		//			packetLog("SOCK '" + string(self.sock) + "' CONNECTION_STATE IS NOW 'LOAD_GAME'")
		//	sock_set_state(self.sock, CONNECTION_STATE.CONFIGURATION)
	}
}
ds_map_add(global.packet_registry, 12, CONFIGURATION_SB_CLIENT_INFO)

function CONFIGURATION_CB_CLIENT_INFO_CONFIRMATION(APPROVED = 1, REASON = "") constructor {
	self.__id = 13
	self.__options = {
		connection_state: CONNECTION_STATE.CONFIGURATION,
		packet_title: "CONFIGURATION_CB_CLIENT_INFO_CONFIRMATION",
		packet_size: -1
	}

	self.approved = APPROVED
	self.reason = REASON
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.approved = buffer_read_ext(buf)
		self.reason = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(2, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_bool, self.approved)
		buffer_write_ext(buf, buffer_string, self.reason)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// server
		packetLog("Recieved client info confirmation from server. Approved: '" + string(self.approved) + "', Reason: '" + string(self.reason) + "'")
		packetLog("We are allowed and valid. Sending load_game confirmation packet back...")
		packetLog("CONNECTION_STATE IS NOW 'LOAD_GAME'")
		obj_multiplayer.network.connection_state = CONNECTION_STATE.LOAD_GAME
		do_packet(new CONFIGURATION_SB_LOAD_GAME_READY(-1), obj_multiplayer.network.server.connection)
	}
}
ds_map_add(global.packet_registry, 13, CONFIGURATION_CB_CLIENT_INFO_CONFIRMATION)

function CONFIGURATION_SB_LOAD_GAME_READY(SOCK = -1) constructor {
	self.__id = 14
	self.__options = {
		connection_state: CONNECTION_STATE.CONFIGURATION,
		packet_title: "CONFIGURATION_SB_LOAD_GAME_READY",
		packet_size: -1
	}

	self.sock = SOCK
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(2, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// server
		packetLog("Recieved load_game confirmation from sock (" + string(self.sock) + ")!")
		packetLog("SOCK '" + string(self.sock) + "' CONNECTION_STATE IS NOW 'LOAD_GAME'")
		sock_set_state(self.sock, CONNECTION_STATE.LOAD_GAME)
		
		// send load_game_state shit
		packetLog("Sending LOAD_GAME_CB_GAME_STATE to sock (" + string(self.sock) + ")!")
		do_packet(generate_game_state_packet(self.sock), self.sock)
	}
}
ds_map_add(global.packet_registry, 14, CONFIGURATION_SB_LOAD_GAME_READY)

/* LOAD_GAME (ID 31-50) */

function LOAD_GAME_CB_GAME_STATE(GAME_STATE_ARRAY = [], INTERACTABLES_ARRAY = [], PLAYERS_ARRAY = [], MOBS_ARRAY = [], CLIENT_INFO = [], SERVER_INFO = []) constructor {
	// send over currently connected players, globals, really just a struct
	self.__id = 31
	self.__options = {
		connection_state: CONNECTION_STATE.LOAD_GAME,
		packet_title: "LOAD_GAME_CB_GAME_STATE",
		packet_size: -1
	}
	
	self.game_state_array = GAME_STATE_ARRAY
	self.interactables_array = INTERACTABLES_ARRAY
	self.players_array = PLAYERS_ARRAY
	self.mobs_array = MOBS_ARRAY
	self.client_info = CLIENT_INFO
	self.server_info = SERVER_INFO
	
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.game_state_array = buffer_read_ext(buf)
		self.interactables_array = buffer_read_ext(buf)
		self.players_array = buffer_read_ext(buf)
		self.mobs_array = buffer_read_ext(buf)
		self.client_info = buffer_read_ext(buf)
		self.server_info = buffer_read_ext(buf)
//		show_debug_message("PLAY_SB_MOVE_PLAYER_POS: READ: POS = " + string(self.pos))
	}
	writePacketData = function() {
		var buf = buffer_create(32, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_array, self.game_state_array)
		buffer_write_ext(buf, buffer_array, self.interactables_array)
		buffer_write_ext(buf, buffer_array, self.players_array)
		buffer_write_ext(buf, buffer_array, self.mobs_array)
		buffer_write_ext(buf, buffer_array, self.client_info)
		buffer_write_ext(buf, buffer_array, self.server_info)
		packetLog("Wrote Packet. Size is: " + string(buffer_tell(buf)) + " bytes", logType.info.def, "writePacketData")
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// apply stuff
		
		// apply client info
		packetLog("Applying Client Info...")
		packetLog("- Client PID from server is '" + string(self.client_info[0]) + "'")
		obj_multiplayer.client.player.pid = self.client_info[0]
		with (obj_pkun) {
			if (variable_instance_exists(id, "__entity")) && (struct_exists(__entity, "destroy")) {
				__entity.destroy()	
			}
			show_debug_message("MAKING PLAYER ENTITY FROM PID IN LOAD GAME")
			__entity = new player_entity("CLIENT", x, y, dir, {}, obj_multiplayer.client.player.pid)
			__entity.attach(id)
		}
		packetLog("Applied Client Info!")
		
		// apply server info
		packetLog("Applying Server Info...")
		packetLog("- Server's client USERNAME from server is '" + string(self.server_info[0]) + "'")
		packetLog("- Server's client PID from server is '" + string(self.server_info[1]) + "'")
//		struct_set(obj_multiplayer.network.players, string(self.server_info[0]), string(self.server_info[1]))
		packetLog("Applied Server Info!")
		packetLog("Completed Applying Game State Packet!")		
		
		// apply game state array ([ GLOBAL_VAR_NAME, VAL, ... ])
		packetLog("Applying Game State Array...")
		for (var i = 0; i < array_length(self.game_state_array) - 1; i+= 2) {
			var _var = self.game_state_array[i], _val = self.game_state_array[i + 1]
			struct_set(global, _var, _val)
			packetLog("- GLOBAL '" + string(_var) + "' is now set to '" + string(global[$ _var]) + "' (GSA VAL: '" + string(_val) + "')")
		}
		packetLog("Applied Game State Array!")
	
		// apply interactables array ([ pos, type, passenger, locked ])
		packetLog("Applying Interactables Array...")
		with (obj_interactable)
			instance_destroy();
		for (var i = 0; i < array_length(self.interactables_array); i++) {
			var _inst = self.interactables_array[i]
			packetLog("- Handling _inst: " + string(_inst))
			
			var _x = _inst[0][0]
			var _y = _inst[0][2]
			var _type = _inst[1]
			var _passenger = _inst[2]
			var _locked = _inst[3]
			
			var _closest_intr = instance_nearest(_x, _y, obj_interactable)
			if (_closest_intr == noone) || !(instance_exists(_closest_intr)) {
				packetLog("-- Closest Interactable at point (" + string(_x) + ", " + string(_y) + ") doesn't exist?")
				
				if (_type == "itemspot") {
					_closest_intr = instance_create_layer(_x, _y, "Instances", obj_intr_item)
					packetLog("-- Created new Item!")
					packetLog("-- COMPLETED PROCESSING THIS INTERACTABLE)")
					continue;
				}
			} else {
				with (_closest_intr) {
					if (type != _type) || (distance_to_point(_x, _y) > 50) {
						other.packetLog("-- Closest Interactable at point (" + string(_x) + ", " + string(_y) + ") is too far away (>50) OR type is mismatched. (Closest Type: " + string(type) + ", IntrArray Type: " + string(_type) + ")")
						other.packetLog("-- COMPLETED PROCESSING THIS INTERACTABLE)")
						continue;
					}
					
					// type is same and is close enough
					locked = _locked
					passenger = _passenger
					other.packetLog("-- Locked is now '" + string(_locked) + "')")
					other.packetLog("-- Passenger is now '" + string(_passenger) + "')")
					other.packetLog("-- COMPLETED PROCESSING THIS INTERACTABLE)")
				}
			}
		}
		packetLog("Applied Interactables Array!")
	
		// apply player array ([ username, x, dx, y, dir, pid, flash, hiding])
		packetLog("Applying Players Array...")
		var seen_plrs = []
		for (var i = 0; i < array_length(self.players_array); i++) {
			var _plr = self.players_array[i]
			packetLog("- Handling _plr: " + string(_plr))
			
			var _username = _plr[0]
			var _x = _plr[1]
			var _dx = _plr[2]
			var _y = _plr[3]
			var _dir = _plr[4]
			var _pid = _plr[5]
			var _flash = _plr[6]
			var _hiding = _plr[7]
			
			if array_contains(seen_plrs, _pid) { // pid
				packetLog("-- Skipping duplicate/seen _plr: " + string(_plr), logType.warning.def)
				continue;
			}
			if (_pid == obj_multiplayer.client.player.pid) {
				packetLog("-- Skipping _plr with our Client's PID (That's us!)", logType.warning.def)
				continue;
			}
			array_push(seen_plrs, _pid)

			if (pid_to_inst(_pid) == noone) {
				packetLog("-- Player INST doesn't exist. Creating it. (USERNAME: " + string(_username) + ", PID: " + string(_pid) + ")")
				var _player = new player_entity(_username, _x, _y, _dir, {"hiding": _hiding, "flashOn": _flash}, _pid, 1)
				_player.create()
			}
		
			// adjust client version of player
			with (pid_to_inst(_pid)) {
				other.packetLog("- Applying X, DX, Y, DIR, HIDING, & FLASH")
				x = _x
				y = _y
				dir = _dir
				dx = (_dx * dir)
				hiding = _hiding
				flashOn = _flash
			}
			packetLog("-- COMPLETED PROCESSING THIS PLAYER (" + string(_username) + ")")
		}
		packetLog("Applied Players Array!")
	
		// apply entities array ([ eid, x, dx, y, dir, state, obj_index ])
		packetLog("Applying Entities Array...")
		with (obj_p_mob)
			instance_destroy();
		for (var i = 0; i < array_length(self.mobs_array); i++) {
			var _mob = self.mobs_array[i]
			packetLog("- Handling _mob: " + string(_mob))
			var _eid = _mob[0]
			var _x = _mob[1]
			var _dx = _mob[2]
			var _y = _mob[3]
			var _dir = _mob[4]
			var _state = _mob[5]
			var _object_index = real(_mob[6])
			
			if ((_eid < 0 ) || is_undefined(_eid)) {
				packetLog("-- Skipping mob, EID is invalid or empty! (EID: " + string(_eid) + ")", logType.warning.def)
				continue;	
			}
			
			if (_eid == obj_multiplayer.client.player.pid) { // pid
				packetLog("-- Skipping mob, EID is us!" + string(_eid), logType.warning.def)
				continue;
			}
			
			if (eid_to_inst(_eid) == noone) {
				packetLog("-- Entity INST doesn't exist. Creating it. (OBJECT_NAME: " + string(object_get_name(_object_index)) + ", EID: " + string(_eid) + ")")
				var _entity = new entity(_x, _y, _dir, _object_index, -3, {"state": _state}, _eid)
				_entity.create()
				packetLog("-- Applied that entity. (OBJECT_NAME: " + string(object_get_name(_object_index)) + ", EID: " + string(_eid) + ")")
			}
		}
		packetLog("Applied Entities Array!")
		packetLog("CONNECTION_STATE IS NOW 'PLAY'")
		obj_multiplayer.network.connection_state = CONNECTION_STATE.PLAY
		
		// let server know we ready
		do_packet(new LOAD_GAME_SB_CLIENT_LOADED_GAME(-1), obj_multiplayer.network.server.connection)
		
		// add play timeout
		add_timer("SERVER_PLAY_KEEPALIVE_TIMEOUT", adjust_to_fps(1), 900, [leave_server, ["Server Timed Out..."]], 0, 1)
		add_timer("SEND_KEEPALIVE_TIMER", adjust_to_fps(1), 450, [do_packet, [new PLAY_SB_KEEP_ALIVE(-1), obj_multiplayer.network.server.connection]], 1, 0)
	}
}
ds_map_add(global.packet_registry, 31, LOAD_GAME_CB_GAME_STATE)

function LOAD_GAME_SB_CLIENT_LOADED_GAME(SOCK = -1) constructor {
	self.__id = 32
	self.__options = {
		connection_state: CONNECTION_STATE.LOAD_GAME,
		packet_title: "LOAD_GAME_SB_CLIENT_LOADED_GAME",
		packet_size: -1
	}

	self.sock = SOCK
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(2, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// server
		packetLog("Recieved ready to play confirmation from sock (" + string(self.sock) + ")!")
		packetLog("SOCK '" + string(self.sock) + "' CONNECTION_STATE IS NOW 'PLAY'")
		sock_set_state(self.sock, CONNECTION_STATE.PLAY)
//		add_timer(string(self.sock) + "_PLAY_KEEPALIVE_TIMEOUT", adjust_to_fps(1), 900, [server_remove_player_inst, [self.sock]], 0, 1)
		add_timer(string(self.sock) + "_SEND_KEEPALIVE_TIMER", adjust_to_fps(1), 450, [do_packet, [new PLAY_CB_KEEP_ALIVE(), self.sock]], 1, 0)
	}
}
ds_map_add(global.packet_registry, 32, LOAD_GAME_SB_CLIENT_LOADED_GAME)

/* PLAY (ID 51-120) */

/*
PLAY_PACKET = {
	// Client data to server
		// CONNECTION STUFF
	SB_DISCONNECT: {REASON: DATA_TYPE.STRING}, // Disconnect client with optional reason (client initiated)
		// PLAYER
	SB_SYNC_PLAYER_ACCEPT: {SYNC_ID: DATA_TYPE.VARINT}, // Accept player sync (with ID from CB_SYNC_PLAYER)
	SB_MOVE_PLAYER_POS: {
		X: DATA_TYPE.SHORT,
		Y: DATA_TYPE.SHORT,
		DIR: DATA_TYPE.BOOLEAN
	},
	SB_MOVE_PLAYER_DIR: {DIR: DATA_TYPE.BOOLEAN},
	SB_MOVE_PLAYER_STATUS: {STATUS: DATA_TYPE.BOOLEAN}, // Send whether player is on ground (0), pushing against wall (1)
	SB_INTERACT: { // Try to interact with an interactable
		ENTITY_EID: DATA_TYPE.EID,
		SNEAK_KEY_PRESSED: DATA_TYPE.BOOLEAN,
		TYPE: DATA_TYPE.UBYTE, // 0: interact, 1: attack, 2: interact at
		TARGET_X: DATA_TYPE.SHORT, // only if TYPE is INTERACT AT
		TARGET_Y: DATA_TYPE.SHORT, // only if TYPE is INTERACT AT
	},
	SB_CHAT: {MSG: DATA_TYPE.STRING}, // Try to send chat message
	SB_CHAT_COMMAND: {MSG: DATA_TYPE.STRING}, // Try to send chat command
		// PLAYER ITEMS
	SB_SET_SELECTED_ITEM: {SLOT: DATA_TYPE.UBYTE}, // Set currently selected itemSlot
	SB_USE_ITEM: {}, // Try to use currently selected item at itemSlot
	SB_USE_ITEM_ON: {}, // Try to use currently selected item at itemSlot on obj (like obj_jianshi seal)
		// GAME
	SB_SYNC_INST_ACCEPT: {SYNC_ID: DATA_TYPE.VARINT}, // Sync client inst pos
	
	
	// Server data to client
		// CONNECTION STUFF
	CB_DISCONNECT: {REASON: DATA_TYPE.STRING}, // Disconnect client with optional reason (server initiated)
		// PLAYER
	CB_SYNC_PLAYER: { // Sync client player position (with ID)
		SYNC_ID: DATA_TYPE.VARINT,
		X: DATA_TYPE.SHORT,
		Y: DATA_TYPE.SHORT,
		DIR: DATA_TYPE.BOOLEAN,
		VX: DATA_TYPE.SHORT,
		VY: DATA_TYPE.SHORT
	}, 
	CB_SET_PLAYER_DATA: {DATA: DATA_TYPE.PREFIXED_ARRAY_OF_X(STRING, USHORT)}, // array of VAR, VAL (struct)
	CB_SET_PLAYER_INV: {SLOT_DATA: DATA_TYPE.PREFIXED_ARRAY_OF_X(UBYTE)}, // Set client player itemSlots
	CB_SET_PLAYER_INV_SLOT: {SLOT: DATA_TYPE.VARINT, SLOT_DATA: DATA_TYPE.VARINT}, // Set client player itemSlot
	CB_SET_PLAYER_CAMTARGET: {CAMTARGET: DATA_TYPE.VARINT}, // Set client player camera (Ex. Spectating a mob)
	CB_GOTO_ROOM: {ROOM: DATA_TYPE.VARINT}, // Make client move to room
	CB_SET_GLOBAL_VAR: {DATA: DATA_TYPE.PREFIXED_ARRAY_OF_X}, // Set client global variable; array of VAR, VAL (struct)
		// GAME
	CB_INTERACT: {ENTITY_EID: DATA_TYPE.EID, INTERACTOR: DATA_TYPE.EID}, // Makes client obj interact with object (Ex. other player hiding or picking up item, etc.)
	CB_SET_TIME: { // Set client game clock time
		LEVEL_AGE: DATA_TYPE.LONG,
		CLOCK_HR: DATA_TYPE.BYTE,
		CLOCK_MIN: DATA_TYPE.UBYTE,
		CLOCK_TK: DATA_TYPE.VARINT,
		CLOCK_TK_SPD: DATA_TYPE.FSHORT
	},
	CB_SET_INST_DATA: {ENTITY_EID: DATA_TYPE.EID, DATA: DATA_TYPE.PREFIXED_ARRAY_OF_X(STRING, USHORT)}, // Set client object instance data (x, y, dir, doTrack, lostTarget, sprite, etc...) (struct)
	CB_UPDATE_INST_DATA: {}, // Tells client to update object instance data with deltas (like x momentum and stuff) (struct)
	CB_ADD_INST: { // Tells client to add object instance with data
		OBJ_ID: DATA_TYPE.VARINT,
		ENTITY_EID: DATA_TYPE.EID,
		X: DATA_TYPE.SHORT,
		Y: DATA_TYPE.SHORT,
		DIR: DATA_TYPE.BOOLEAN,
		VX: DATA_TYPE.SHORT,
		VY: DATA_TYPE.SHORT
	}, 
	CB_REMOVE_INST: {INSTANCES: DATA_TYPE.PREFIXED_ARRAY_OF_X(USHORT)}, // Tells client to remove object instance(s) (array)
	CB_REMOVE_OBJECT: {OBJ_ID: DATA_TYPE.VARINT}, // Tells client to remove all instances of an object
	CB_ROOM_EVENT: {ROOM_EVENT_ID: DATA_TYPE.VARINT}, // Like someone going up stairs, someone dying, etc...
	CB_INST_EVENT: {INST_EVENT_ID: DATA_TYPE.VARINT}, // Like a mob getting sealed or sum idfk
	
	CB_SET_MINI_DIALOG: {TEXT: DATA_TYPE.STRING, DUR: DATA_TYPE.VARINT}, // Set global.mini_dialog_line and obj_sys.mini_dialog_timer on client
	CB_SET_PKUN_DIALOG: {TEXT: DATA_TYPE.STRING, DUR: DATA_TYPE.VARINT}, // Set obj_pkun.mini_dialog_line and obj_pkun.mini_dialog_tier
		// SOUND
	CB_PLAY_BGM: {BGM: DATA_TYPE.VARINT}, // sets client bgm_curr
	CB_STOP_BGM: {}, // resets/removes client bgm_curr
	CB_PLAY_SE: {SE: DATA_TYPE.VARINT, LOOP: DATA_TYPE.BOOLEAN}, // plays se on client
	CB_PLAY_OBJ_SE: { // plays se at object
		ENTITY_EID: DATA_TYPE.EID,
		SE: DATA_TYPE.VARINT,
		LOOP: DATA_TYPE.VARINT
	},
	CB_STOP_SE: {SE: DATA_TYPE.VARINT}, // stops an se on client if playing
	CB_STOP_ALL_AUDIO: {}, // runs audio_stop_app on a client
}
*/

function PLAY_SB_MOVE_PLAYER_POS(SOCK = -1, X = 0, DX = 0, Y = 0, DIR = 0, HIDING = 0) constructor {
	self.__id = 51
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_SB_MOVE_PLAYER_POS",
		packet_size: -1
	}
	
	self.sock = SOCK
	self.pos = [X, DX, Y, DIR]
	self.hiding = HIDING
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.pos = buffer_read_ext(buf)
		self.hiding = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_position, self.pos)
		buffer_write_ext(buf, buffer_bool, self.hiding)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		if !is_array(self.pos) {
			packetLog("self.pos IS NOT ARRAY! self.pos = '" + string(self.pos) + "'", logType.error.def)	
			exit;
		}

		//if !instance_exists(obj_network_object) {
		if (sock_to_inst(self.sock) == noone) {
			packetLog("SOCK " + string(self.sock) + " isn't associated with an instance?", "ERROR") //, creating new INST for sock " + string(self.sock))
//			var no = instance_create_depth(self.pos[0], self.pos[2], 0, obj_network_object)
//			no.network_obj_type = "player"
//			no.entity_id = obj_multiplayer.network.players[$ _username]
////			struct_set(obj_multiplayer.network.players, self.sock, no.entity_id)
//			struct_set(obj_multiplayer.network.entities, no.entity_id, no.id)
//			no.nametag = _username

//			var _player = new player_entity("unknownAtSBMovePlayerPos", self.pos[0], self.pos[2], self.pos[3], {}, obj_multiplayer.server.clients[$ self.sock])
//			_player.create()
		}
		
		// adjust server version of pkun
		with (sock_to_inst(self.sock)) {
			array_push(posxq, other.pos[0]);
			array_shift(posxq)
			
			x = other.pos[0] // -= adjust_to_fps((x - other.pos[0]) / 2);
			y = other.pos[2] //-= adjust_to_fps((y - other.pos[2]) / 2);
			array_push(posyq, other.pos[2]);
			array_shift(posyq)
			
			dir = other.pos[3]
			dx = (other.pos[1] * dir)
			hiding = other.hiding
			
			// replicate update to all client version of source pkuns whatever
			if (server_player_count() > 1) { // only need to replicate changes to other clients if its more than server and 1 client.
//				packetLog("Replicating client changes to other clients! (no.entity_id = " + string(entity_id) + ")")
//				_cb_sync_pkun(entity_id, other.pos[0], other.pos[1], other.pos[2], other.pos[3], other.hiding, other.sock)
			}
		}
	}
}
ds_map_add(global.packet_registry, 51, PLAY_SB_MOVE_PLAYER_POS)

function PLAY_CB_MOVE_PLAYER_POS(PID = -1, X = 0, DX = 0, Y = 0, DIR = 0, HIDING = 0) constructor {
	self.__id = 52
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_CB_MOVE_PLAYER_POS",
		packet_size: -1
	}	
	
	self.pid = PID
	self.pos = [X, DX, Y, DIR] //[X, Y, DIR, TOUCHING_WALL, FLASHLIGHT_ON]
	self.hiding = HIDING
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.pid = buffer_read_ext(buf)
		self.pos = buffer_read_ext(buf)
		self.hiding = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_vint, self.pid)
		buffer_write_ext(buf, buffer_position, self.pos)
		buffer_write_ext(buf, buffer_bool, self.hiding)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		if (self.pid < 0) {
			packetLog("Couldn't create or edit player with invalid pid!", logType.warning.def)
			exit;
		}
		
		if (pid_to_inst(self.pid) == noone) {
//			packetLog("Creating new obj_network_obj with uuid " + string(self.pid))
			packetLog("PID " + string(self.pid) + " isn't associated with an instance?", "ERROR")
			//var no = instance_create_depth(self.pos[0], self.pos[2], 0, obj_network_object)
			//no.network_obj_type = "player"
			//no.entity_id = self.pid
			//struct_set(obj_multiplayer.network.entities, self.pid, no.id)
			//no.nametag = _username // self.sock

//			var _player = new player_entity("unknownAtCBMovePlayerPos", self.pos[0], self.pos[2], self.pos[3], {}, self.pid)
//			_player.create()
		}
		
		// adjust client version of pkun
		with (pid_to_inst(self.pid)) {
			x = other.pos[0] // -= adjust_to_fps((x - other.pos[0]) / 2);
			y = other.pos[2] //-= adjust_to_fps((y - other.pos[2]) / 2);			
			dir = other.pos[3]
			dx = (other.pos[1] * dir)
			hiding = other.hiding
		}
	}
}
ds_map_add(global.packet_registry, 52, PLAY_CB_MOVE_PLAYER_POS)

function PLAY_CB_MOVE_ENTITY_POS(EID = -1, X = 0, DX = 0, Y = 0, DIR = 0, STATE = 0, OBJECT_INDEX = -4) constructor {
	self.__id = 53
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_CB_MOVE_ENTITY_POS",
		packet_size: -1
	}
	
	self.eid = EID
	self.pos = [X, DX, Y, DIR] //[X, Y, DIR, TOUCHING_WALL, FLASHLIGHT_ON]
	self.state = STATE
	self.object_index = OBJECT_INDEX
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.eid = buffer_read_ext(buf)
		self.pos = buffer_read_ext(buf)
		self.state = buffer_read_ext(buf)
		self.object_index = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_vint, self.eid)
		buffer_write_ext(buf, buffer_position, self.pos)
		buffer_write_ext(buf, buffer_vint, self.state)
		buffer_write_ext(buf, buffer_vint, self.object_index)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		if (self.eid < 0) {
			packetLog("Couldn't create or edit entity with invalid eid!", logType.error.def)
			exit;
		}
		
		if (eid_to_inst(self.eid) == noone) {
			packetLog("Creating new '" + string(object_get_name(self.object_index)) + "' with eid '" + string(self.eid) + "'")
			//var inst = instance_create_depth(self.pos[0], self.pos[2], -3, self.object_index)
			//inst.entity_id = self.eid
			//struct_set(obj_multiplayer.network.entities, inst.entity_id, inst.id)
			var _entity = new entity(self.pos[0], self.pos[2], self.pos[3], self.object_index, -3, {}, self.eid)
			_entity.create()
		}
	
		// adjust client version of object
		with (eid_to_inst(self.eid)) {
			if !(entity_id == other.eid) {
				other.packetLog("Tried to move entity with wrong eid?? Packet provided eid: '" + string(other.eid) + "', current instance eid: '" + string(self.entity_id) + "'")	
				exit;
			}
			
			x = other.pos[0] // -= adjust_to_fps((x - other.pos[0]) / 2);
			y = other.pos[2] //-= adjust_to_fps((y - other.pos[2]) / 2);
			
			dir = other.pos[3]
			dx = (other.pos[1] * dir)
			state = other.state
		}
	}
}
ds_map_add(global.packet_registry, 53, PLAY_CB_MOVE_ENTITY_POS)

function PLAY_CB_CREATE_ENTITY(EID = -1, X = 0, DX = 0, Y = 0, DIR = 0, OBJECT_INDEX = -4, VAR_STRUCT = {}) constructor {
	self.__id = 54
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_CB_CREATE_ENTITY",
		packet_size: -1
	}
	
	self.eid = EID
	self.pos = [X, DX, Y, DIR] //[X, Y, DIR, TOUCHING_WALL, FLASHLIGHT_ON]
	self.object_index = OBJECT_INDEX
	self.variable_struct = VAR_STRUCT
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.eid = buffer_read_ext(buf)
		self.pos = buffer_read_ext(buf)
		self.object_index = buffer_read_ext(buf)
		var _tvs = buffer_read_ext(buf)
		self.variable_struct = (is_undefined(_tvs)) ? undefined : _tvs
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_vint, self.eid)
		buffer_write_ext(buf, buffer_position, self.pos)
		buffer_write_ext(buf, buffer_vint, self.object_index)
		buffer_write_ext(buf, ((self.variable_struct == {}) || (struct_names_count(self.variable_struct) == 0)) ? buffer_undefined : buffer_struct, self.variable_struct)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		if (self.eid < 0) {
			packetLog("Couldn't create entity with invalid eid!", logType.error.def)
			exit;
		}
		packetLog("Got create entity packet! (" + string(object_get_name(self.object_index)) + ")")
		if (self.variable_struct != undefined)
			packetLog("Has variable struct!! (" + string(self.variable_struct) + ")")
		
		// remove entity if has same uuid but different obj index
		var _ent = eid_to_inst(self.eid)
		if !(_ent == noone) {
			if (_ent[$ "object_index"] != self.object_index) {
				packetLog("Removing pre-existing entity sharing EID, because it is a different object type.")
				struct_remove(obj_multiplayer.network.entities, self.eid)
				instance_destroy(_ent)
			}
		}
		if (eid_to_inst(self.eid) == noone) { // check if entity doesn't exists
			packetLog("Creating new '" + string(object_get_name(self.object_index)) + "' with eid '" + string(self.eid) + "'")
			var _entity = new entity(self.pos[0], self.pos[2], self.pos[3], self.object_index, -3, self.variable_struct, self.eid)
			_entity.create()
		}
	}
}
ds_map_add(global.packet_registry, 54, PLAY_CB_CREATE_ENTITY)

function PLAY_CB_CREATE_ENTITIES(ENTITIES = []) constructor {
	self.__id = 55
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_CB_CREATE_ENTITIES",
		packet_size: -1
	}
	
	self.entities = ENTITIES // [EID, X, DX, Y, DIR, OBJ_INDEX]
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.entities = buffer_read_ext(buf)
		show_debug_message("PLAY_CB_CREATE_ENTITIES: Read, Entities: " + string(self.entities))
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_array, self.entities)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		if (array_length(self.entities) <= 0) {
			packetLog("Couldn't create entity with empty entities array!", logType.warning.def)
			exit;
		}
		for (var i = 0; i < array_length(self.entities); i++) {
			var _e = self.entities[i]
			packetLog("- Applying entity: " + string(_e))	
			if (array_length(_e) < 6) {
				packetLog("-- Couldnt create entity, entity_array doesn't have enough indexes.", logType.error.def)	
			}
			var _temp_packet = new PLAY_CB_CREATE_ENTITY(_e[0], _e[1], _e[2], _e[3], _e[4], _e[5])
			_temp_packet.processPacket()
		}
	}
}
ds_map_add(global.packet_registry, 55, PLAY_CB_CREATE_ENTITIES)

function PLAY_CB_DESTROY_ENTITY(EID = -1) constructor {
	self.__id = 56
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_CB_DESTROY_ENTITY",
		packet_size: -1
	}
	
	self.eid = EID
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.eid = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_vint, self.eid)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		if (self.eid < 0) {
			packetLog("Couldn't destroy entity with invalid eid!", logType.error.def)
			exit;
		}
		with (eid_to_inst(self.eid)) {
			struct_remove(obj_multiplayer.network.entities, entity_id)
			instance_destroy();
		}
	}
}
ds_map_add(global.packet_registry, 56, PLAY_CB_DESTROY_ENTITY)

function PLAY_CB_DESTROY_OBJECT(OBJECT_INDEX = -4) constructor {
	self.__id = 57
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_CB_DESTROY_OBJECT",
		packet_size: -1
	}
	
	self.object_index = OBJECT_INDEX
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.object_index = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_vint, self.object_index)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		if (self.object_index == -4) {
			packetLog("Couldn't destroy object with empty object index!", logType.error.def)
			exit;
		}
		with (self.object_index) {
			instance_destroy()
		}
		packetLog("Destroyed all instances of " + string(object_get_name(self.object_index)))
	}
}
ds_map_add(global.packet_registry, 57, PLAY_CB_DESTROY_OBJECT)

//function PLAY_CB_UPDATE_ENTITY_VAR(EID = -1, VAR_AND_VAL_ARRAY = [], OBJECT_INDEX = -4) constructor {
//	self.__id = 54
//	self.eid = EID
//	self.var_and_val_array = VAR_AND_VAL_ARRAY
////	self.val_array = VAL_ARRAY
//	self.object_index = OBJECT_INDEX
//	readPacketData = function(buf) {
////		buffer_seek(buf, buffer_seek_start, 0)
////		self.__id = buffer_read_ext(buf)
////		self.__id = buffer_read_ext(buf)
////		self.var_and_val_array = buffer_read_ext(buf)
//////		self.val_array = buffer_read_ext(buf)
////		self.object_index = buffer_read_ext(buf)
//		show_debug_message("READING UPDATE ENTITY VAR!")
//	}
//	writePacketData = function() {
//		var buf = buffer_create(32, buffer_grow, 1)
////		buffer_seek(buf, buffer_seek_start, 0)
////		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
//////		buffer_write_ext(buf, buffer_vint, self.eid)
//////		buffer_write_ext(buf, buffer_array, self.var_and_val_array)
////////		buffer_write_ext(buf, buffer_array, self.val_array)
//////		buffer_write_ext(buf, buffer_vint, self.object_index)
//		self.__options.packet_size = buffer_tell(buf); return buf
//	}
//	processPacket = function() {
//		if (self.eid < 0) {
//			show_debug_message("PLAY_CB_UPDATE_ENTITY_VAR: Couldn't create or edit entity with invalid eid!")
//			exit;
//		}
		
//		show_debug_message("YOO! GOT MOB PACKET! MOB IS " + string(object_get_name(self.object_index) + ", ARRAY IS " + string(self.var_and_val_array)))
////		if !(array_length(self.var_array) == array_length(self.val_array)) {
////			show_debug_message("PLAY_CB_UPDATE_ENTITY_VAR: Var and Val arrays are different sizes! Cancelling!")
////			exit;	
////		}
		
//		//if (eid_to_inst(self.eid) == noone) {
//		//	var inst = instance_create_depth(self.pos[0], self.pos[2], -3, self.object_index)
//		//	inst.entity_id = self.eid
//		//	struct_set(obj_multiplayer.network.entities, inst.entity_id, inst.id)
//		//}
	
//		//// adjust client version of object
//		//with (eid_to_inst(self.eid)) {
//		//	for (var i = 0; i < (array_length(other.var_and_val_array) - 1); i+= 2) {
//		//		var variable = other.var_and_val_array[i]
//		//		var value = other.var_and_val_array[i + 1]
//		//		show_debug_message("PLAY_CB_UPDATE_ENTITY_VAR, setting '" + string(variable) + "' to '" + string(value) + "'")
//		//		variable_instance_set(id, variable, value)
//		//	}
//		//}
//	}
//}
//ds_map_add(global.packet_registry, 54, PLAY_CB_UPDATE_ENTITY_VAR)

function PLAY_SB_TOGGLE_FLASHLIGHT(SOCK = -1, FLASH = 0) constructor {
	self.__id = 58
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_SB_TOGGLE_FLASHLIGHT",
		packet_size: -1
	}
	
	self.sock = SOCK
	self.flash = FLASH
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.flash = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_bool, self.flash)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// adjust server version of pkun
		with (sock_to_inst(self.sock)) {
			flashOn = other.flash
			play_se(se_flash)
			
			// replicate flashlight event to all other clients
//			if (server_player_count() > 1) {
//				_cb_sync_flashlight(entity_id, other.flash)
//			}
		}
	}
}
ds_map_add(global.packet_registry, 58, PLAY_SB_TOGGLE_FLASHLIGHT)

function PLAY_CB_TOGGLE_FLASHLIGHT(PID = -1, FLASH = 0) constructor {
	self.__id = 59
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_CB_TOGGLE_FLASHLIGHT",
		packet_size: -1
	}
	
	self.pid = PID
	self.flash = FLASH
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.pid = buffer_read_ext(buf)
		self.flash = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_vint, self.pid)
		buffer_write_ext(buf, buffer_bool, self.flash)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// adjust server version of pkun
		packetLog("Got flashlight toggle for PID " + string(self.pid))
		with (pid_to_inst(self.pid)) {
			flashOn = other.flash
			play_se(se_flash)
		}
	}
}
ds_map_add(global.packet_registry, 59, PLAY_CB_TOGGLE_FLASHLIGHT)

function PLAY_SB_SET_HSCENE(SOCK = -1, MOB_ID, HS_STP, HS_SND = -4, TRANS_ALP = 0, HIDE_FL = 0) constructor {
	self.__id = 60
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_SB_SET_HSCENE",
		packet_size: -1
	}
	
	self.sock = SOCK
	self.mob_id = MOB_ID
	self.hs_stp = HS_STP
	self.hs_snd = HS_SND
	self.hs_trans_alp = TRANS_ALP
	self.hs_hide_fl = HIDE_FL
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.mob_id = buffer_read_ext(buf)
		self.hs_stp = buffer_read_ext(buf)
		self.hs_snd = buffer_read_ext(buf)
		var _talp = (buffer_read_ext(buf))
		self.hs_trans_alp = ((_talp == undefined) ? 0 : (_talp / 100))
		packetLog("_talp: " + string(_talp) + ", mult: " + string(self.hs_trans_alp), "HSCENE", "readPacketData")
		self.hs_hide_fl = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_vint, self.mob_id)
		buffer_write_ext(buf, buffer_vint, self.hs_stp)
		buffer_write_ext(buf, ((self.hs_snd == -4) ? buffer_undefined : buffer_vint), self.hs_snd)
		buffer_write_ext(buf, ((self.hs_trans_alp == 0) ? buffer_undefined : buffer_vint), floor(self.hs_trans_alp * 100)) // 100th accuracy
		packetLog("_talp: " + string(self.hs_trans_alp) + ", mult: " + string(floor(self.hs_trans_alp * 100)), "HSCENE", "writePacketData")
		buffer_write_ext(buf, ((self.hs_hide_fl == 0) ? buffer_undefined : buffer_bool), self.hs_hide_fl)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// adjust server version of object
		packetLog("Adjusting HSCENE for Sock " + string(self.sock))
		with (sock_to_inst(self.sock)) {
			hs_mob_id = other.mob_id
			hs_stp = other.hs_stp
			if (other.hs_trans_alp != undefined)
				hs_trans_alp = other.hs_trans_alp
			if (other.hs_hide_fl != undefined)
				hs_hide_fl = other.hs_hide_fl
			if (other.hs_snd != undefined)
				play_se_at(other.hs_snd, x, y)
			
			// replicate update to all client version of source pkuns whatever
//			if (server_player_count() > 1) {
//				var _ts = array_without(struct_get_names(obj_multiplayer.server.clients), other.sock) 
//				do_packet(new PLAY_CB_SET_HSCENE(entity_id, hs_mob_id, hs_stp), _ts)
//			}
			if instance_exists(mob_id_to_obj(hs_mob_id))
				instance_destroy(mob_id_to_obj(hs_mob_id))
		}

	}
}
ds_map_add(global.packet_registry, 60, PLAY_SB_SET_HSCENE)

function PLAY_CB_SET_HSCENE(PID, MOB_ID, HS_STP, HS_SND = -4, TRANS_ALP = 0, HIDE_FL = 0) constructor {
	self.__id = 61
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_CB_SET_HSCENE",
		packet_size: -1
	}
	
	self.pid = PID
	self.mob_id = MOB_ID
	self.hs_stp = HS_STP
	self.hs_snd = HS_SND
	self.hs_trans_alp = TRANS_ALP
	self.hs_hide_fl = HIDE_FL
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.pid = buffer_read_ext(buf)
		self.mob_id = buffer_read_ext(buf)
		self.hs_stp = buffer_read_ext(buf)
		self.hs_snd = buffer_read_ext(buf)
		var _talp = (buffer_read_ext(buf))
		self.hs_trans_alp = ((_talp == undefined) ? 0 : (_talp / 100))
		packetLog("_talp: " + string(_talp) + ", mult: " + string(self.hs_trans_alp), "HSCENE", "readPacketData")
		self.hs_hide_fl = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_vint, self.pid)
		buffer_write_ext(buf, buffer_vint, self.mob_id)
		buffer_write_ext(buf, buffer_vint, self.hs_stp)
		buffer_write_ext(buf, ((self.hs_snd == -4) ? buffer_undefined : buffer_vint), self.hs_snd)
		buffer_write_ext(buf, ((self.hs_trans_alp == 0) ? buffer_undefined : buffer_vint), floor(self.hs_trans_alp * 100)) // 100th accuracy
		packetLog("_talp: " + string(self.hs_trans_alp) + ", mult: " + string(floor(self.hs_trans_alp * 100)), "HSCENE", "writePacketData")
		buffer_write_ext(buf, ((self.hs_hide_fl == 0) ? buffer_undefined : buffer_bool), self.hs_hide_fl)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// adjust client version of object
		packetLog("Adjusting HSCENE for PID " + string(self.pid))
		
		if (self.pid == obj_multiplayer.client.player.pid) {
			// thats us
			packetLog("Adjusting HSCENE for us!")
			global.hscene_target = {"mob_id": self.mob_id}
			if (self.hs_snd != undefined)
				play_se(self.hs_snd, 1)
			if (self.hs_trans_alp != undefined)
				global.trans_alp = self.hs_trans_alp
			if (self.hs_hide_fl != undefined)
				global.hscene_hide_fl = self.hs_hide_fl
			with (obj_pkun) {
				hs_stp = other.hs_stp	
			}
			exit;
		}
		
		with (pid_to_inst(self.pid)) {
			hs_mob_id = other.mob_id
			hs_stp = other.hs_stp
			if (other.hs_snd != undefined)
				play_se_at(other.hs_snd, x, y)
		}
	}
}
ds_map_add(global.packet_registry, 61, PLAY_CB_SET_HSCENE)

function PLAY_SB_SET_ENTITY_CONTROL(SOCK = -1, EID_TO_CONTROL = -1, CONTROL = 0) constructor {
	self.__id = 62
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_SB_SET_ENTITY_CONTROL",
		packet_size: -1
	}
	
	self.sock = SOCK
	self.eid = EID_TO_CONTROL
	self.control = CONTROL
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.eid = buffer_read_ext(buf)
		self.control = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_vint, self.eid)
		buffer_write_ext(buf, buffer_bool, self.control)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// adjust client version of object
		packetLog("Adjusting controller for EID " + string(self.eid) + ", controller Sock is " + string(self.sock))
		with (eid_to_inst(self.eid)) {
			var _temp = controlled
			controlled = (other.control) ? other.sock : 0 //(other.control) ? other.sock : 0
			other.packetLog("- CONTROLLER WAS " + string(_temp) + ", NOW IS " + string(controlled))
			dx = 0
			exit;
		}
		packetLog("NO ENTITY FOUND FOR EID " + string(self.eid) + ", CONTROLLER SOCK IS " + string(self.sock), logType.error.def)
	}
}
ds_map_add(global.packet_registry, 62, PLAY_SB_SET_ENTITY_CONTROL)

function PLAY_SB_MOVE_ENTITY_POS(SOCK = -1, EID = -1, X = 0, DX = 0, Y = 0, DIR = 0, STATE = 0) constructor {
	// THIS REQUIRES THAT THE ENTITY HAS CONTROLLER VARIABLE SET TO CLIENT SOCK
	self.__id = 63
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_SB_MOVE_ENTITY_POS",
		packet_size: -1
	}
	
	self.sock = SOCK
	self.eid = EID
	self.pos = [X, abs(DX), Y, DIR] //[X, Y, DIR, TOUCHING_WALL, FLASHLIGHT_ON]
	self.state = STATE
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.eid = buffer_read_ext(buf)
		self.pos = buffer_read_ext(buf)
		self.state = buffer_read_ext(buf)
		self.object_index = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_vint, self.eid)
		buffer_write_ext(buf, buffer_position, self.pos)
		buffer_write_ext(buf, buffer_vint, self.state)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		if (self.eid < 0) {
			packetLog("Couldn't create or edit entity with invalid eid!", logType.error.def)
			exit;
		}
		
		if (eid_to_inst(self.eid) == noone) {
			packetLog("Couldn't move entity on server from client request, client provided entity_id doesn't exist.", logType.error.def)
			exit;
		}
	
		// adjust server version of object
		with (eid_to_inst(self.eid)) {
			// check if being controlled, and if it is from right sock
			if !(controlled == other.sock) {
				other.packetLog("Illegal attempt from client to move entity '" + string(other.uuid) + "' (offender sock = " + string(other.sock) + ", entity.controlled = " + string(controlled) + ", client provided entity_id = " + string(other.uuid) + ")", logType.warning.def)
				exit;
			}

			x = other.pos[0] // -= adjust_to_fps((x - other.pos[0]) / 2);
			y = other.pos[2] //-= adjust_to_fps((y - other.pos[2]) / 2);
			
			dir = other.pos[3]
			dx = (other.pos[1] * dir)
			state = other.state
		}
	}
}
ds_map_add(global.packet_registry, 63, PLAY_SB_MOVE_ENTITY_POS)

function PLAY_SB_SET_TIME_STOP(SOCK = -1, TIMESTOP = 0) constructor {
	self.__id = 64
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_SB_SET_TIME_STOP",
		packet_size: -1
	}
	
	self.sock = SOCK
	self.timestop = TIMESTOP
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.timestop = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_vint, self.timestop)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// adjust server version of timestop
		global.timeStop = self.timestop
		global.timeStopCanMove = (self.sock == -1)
		play_se(se_tiktok)
			
		// replicate to other clients
		var _t = array_without(struct_get_names(obj_multiplayer.server.clients), self.sock)
		do_packet(new PLAY_CB_SET_TIME_STOP(0, global.timeStop), _t)
	}
}
ds_map_add(global.packet_registry, 64, PLAY_SB_SET_TIME_STOP)

function PLAY_CB_SET_TIME_STOP(CAN_CLIENT_MOVE_IN_TIMESTOP = 0, TIMESTOP = 0) constructor {
	self.__id = 65
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_CB_SET_TIME_STOP",
		packet_size: -1
	}
	
	self.can_move = CAN_CLIENT_MOVE_IN_TIMESTOP
	self.timestop = TIMESTOP
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.can_move = buffer_read_ext(buf)
		self.timestop = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_bool, self.can_move)
		buffer_write_ext(buf, buffer_vint, self.timestop)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// adjust client version of timestop
		global.timeStop = self.timestop
		global.timeStopCanMove = self.can_move
		play_se(se_tiktok)
	}
}
ds_map_add(global.packet_registry, 65, PLAY_CB_SET_TIME_STOP)

function PLAY_SB_INTERACT_AT(SOCK = -1, INTR_TYPE = "", X = 0, Y = 0, NEW_STATE = -4) constructor {
	self.__id = 66
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_SB_INTERACT_AT",
		packet_size: -1
	}
	
	self.sock = SOCK
	self.intr_type = INTR_TYPE
	self.x = X
	self.y = Y
	self.forced_state = NEW_STATE
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.intr_type = buffer_read_ext(buf)
		self.x = buffer_read_ext(buf)
		self.y = buffer_read_ext(buf)
		self.forced_state = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_string, self.intr_type)
		buffer_write_ext(buf, buffer_vint, self.x)
		buffer_write_ext(buf, buffer_vint, self.y)
		buffer_write_ext(buf, ((self.forced_state == -4) ? buffer_undefined : buffer_vint), self.forced_state)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// interact with thing on server side
		var _intr = instance_nearest(self.x, self.y, obj_interactable)
		var _plr = sock_to_inst(self.sock)
		var _hidebox = (self.intr_type == "hidebox")
	
		if (!instance_exists(_intr) && !_hidebox) || !instance_exists(_plr) {
			packetLog("Interacted w/ obj not found or dont exist OR player doesnt exist", logType.warning.def)
			exit;
		}
		
		with (_plr) {
			if (distance_to_object(_intr) > 50) && !_hidebox {
				other.packetLog("Tried to interact w/ obj that's too far from player!", logType.warning.def)
				exit;
			}
		}
		
		if !(_hidebox) && (_intr.type != self.intr_type) {
			packetLog("Interacted w/ obj type doesnt match provided intr_type! Cancelling!", logType.warning.def)
			exit;
		}
		
		switch (self.intr_type) {
			case "portal": {
				packetLog("SOCK " + string(self.sock) + " Interacted w/ portal!")
				play_se_at(_intr.se, _intr.x, _intr.y)
				
				// add tracers if needed
				var _disable_ai_dur = 300
				if (instance_number(obj_p_mob) > 0 && (!global.timeStop))
				{
					packetLog("SOCK " + string(self.sock) + " gonna add tracer for portal interaction, and disable mob ai for " + string(_disable_ai_dur) + " frames (60/sec)")
					with (obj_p_mob)
					{
						if (doTrack) && (current_target == _plr) {
							mob_add_trace()
							mob_disable_ai(_disable_ai_dur)
						}
					}
					baldi_add_tracer()
				} else {
					packetLog("SOCK " + string(self.sock) + " not adding tracer?")	
				}
				
				// get all entities on same floor and send them to player so it is seamless
				var _player_floor = get_floor(sock_to_inst(self.sock).y)
				var _entities = struct_get_names(obj_multiplayer.network.entities)
				for (var i = 0; i < array_length(_entities); i++) {
					with (eid_to_inst(_entities[i])) {
						var _flr = get_floor(y)	
						if (_player_floor == _flr) {
							other.packetLog("SOCK " + string(other.sock) + " Floor updated, sending '" + string(object_get_name(object_index)) + "' move packet so seamless!")
							var _s = variable_instance_exists(id, "state") ? state : 0
							do_packet(new PLAY_CB_MOVE_ENTITY_POS(entity_id, x, dx, y, dir, _s, object_index), other.sock)	
						}
					}
				}
				break;
			}
			case "hidespot": {
				packetLog("SOCK " + string(self.sock) + " Interacted w/ hidespot! forced_state: '" + string(self.forced_state) + "'")
	            play_se_at(_intr.se_in, _intr.x, _intr.y)
	            _intr.shake = (20)
				_intr.passenger = _plr
				_plr.hiding = (self.forced_state == -4) ? (!_plr.hiding) : (self.forced_state > 0)
				_intr.locked = _plr.hiding
				_plr.x = _intr.x
				
				with (obj_p_mob)
                {
                    if doTrack
                    {
                        if (((!target_is_near()) || distance_to_object(current_target) > 700)) && (current_target == _plr)
                            lostTarget = 1
                    }
                }
				break;
			}
			case "itemspot": {
				packetLog("SOCK " + string(self.sock) + " Interacted w/ itemspot! forced_state: '" + string(self.forced_state) + "'")
				play_se_at(_intr.se, _intr.x, _intr.y)
				if (_intr.x == self.x) && (_intr.y == self.y) // must be in same exact pos
					instance_destroy(_intr.id)
				break;
			}
			case "figure": {
				packetLog("SOCK " + string(self.sock) + " Interacted w/ figure! forced_state: '" + string(self.forced_state) + "'")
				packetLog("Figure Interaction Handling is not integrated yet...", logType.warning.def)
				break;
			}
			case "piano": {
				packetLog("SOCK " + string(self.sock) + " Interacted w/ piano! forced_state: '" + string(self.forced_state) + "'")
	            play_se(_intr.se, 1)
	            instance_destroy(_intr.id)
				break;
			}
			case "hidebox": {
				packetLog("SOCK " + string(self.sock) + " Interacted w/ hidebox! forced_state: '" + string(self.forced_state) + "'")
				if (_plr.hidebox == -4) {
					_plr.hidebox = instance_create_depth(_plr.x, _plr.y, 0, obj_intr_hidebox)
					play_se_at(_plr.hidebox.se_in, _plr.x, _plr.y)
			        _plr.hidebox.shake = 20
					_plr.hidebox.locked = 1
					_plr.hidebox.passenger = _plr
			        _plr.hiding = 1
				} else {
					instance_destroy(_plr.hidebox)
					_plr.hidebox = -4
					_plr.hiding = 0
				}
			}
		}
			
		// replicate to other clients
		if (server_player_count() > 1) {
			var _t = array_without(struct_get_names(obj_multiplayer.server.clients), self.sock)
			do_packet(new PLAY_CB_INTERACT_AT(_plr.entity_id, self.intr_type, self.x, self.y, 0, self.forced_state), _t)
		}
	}
}
ds_map_add(global.packet_registry, 66, PLAY_SB_INTERACT_AT)

function PLAY_CB_INTERACT_AT(PID = -1, INTR_TYPE = "", X = 0, Y = 0, AS_TARGET_CLIENT = 0, NEW_STATE = -4) constructor {
	self.__id = 67
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_CB_INTERACT_AT",
		packet_size: -1
	}
	
	self.pid = PID
	self.intr_type = INTR_TYPE
	self.x = X
	self.y = Y
	self.as_target_client = AS_TARGET_CLIENT
	self.forced_state = NEW_STATE
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.pid = buffer_read_ext(buf)
		self.intr_type = buffer_read_ext(buf)
		self.x = buffer_read_ext(buf)
		self.y = buffer_read_ext(buf)
		self.as_target_client = buffer_read_ext(buf)
		self.forced_state = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_vint, self.pid)
		buffer_write_ext(buf, buffer_string, self.intr_type)
		buffer_write_ext(buf, buffer_vint, self.x)
		buffer_write_ext(buf, buffer_vint, self.y)
		buffer_write_ext(buf, buffer_bool, self.as_target_client)
		buffer_write_ext(buf, ((self.forced_state == -4) ? buffer_undefined : buffer_vint), self.forced_state)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// interact with thing on client side
		var _intr = instance_nearest(self.x, self.y, obj_interactable)
		var _plr = (self.as_target_client) ? obj_pkun : pid_to_inst(self.pid)
		var _hidebox = (self.intr_type == "hidebox")
		
		if (!instance_exists(_intr) && !_hidebox) || !instance_exists(_plr) {
			packetLog("Interacted w/ obj not found or dont exist OR player doesnt exist", logType.warning.def)
			exit;
		}
		
		with (_plr) {
			if (distance_to_object(_intr) > 50) && !_hidebox	 {
				other.packetLog("Tried to interact w/ obj that's too far from player!", logType.warning.def)
				exit;
			}
		}
		
		if !(_hidebox) && (_intr.type != self.intr_type) {
			packetLog("Interacted w/ obj type doesnt match provided intr_type! Cancelling!")
			exit;
		}
		
		switch (self.intr_type) {
			case "portal": {
				packetLog("PID " + string(self.pid) + " Interacted w/ portal! forced_state: '" + string(self.forced_state) + "'")
				play_se_at(_intr.se, _intr.x, _intr.y)
				break;
			}
			case "hidespot": {
				packetLog("PID " + string(self.pid) + " Interacted w/ hidespot! forced_state: '" + string(self.forced_state) + "'")
	            play_se_at(_intr.se_in, _intr.x, _intr.y)
	            _intr.shake = (20)
				_plr.hiding = (self.forced_state == -4) ? (!_plr.hiding) : (self.forced_state > 0)
				_intr.locked = _plr.hiding
				_plr.x = _intr.x
				break;
			}
			case "itemspot": {
				packetLog("PID " + string(self.pid) + " Interacted w/ itemspot! forced_state: '" + string(self.forced_state) + "'")
				play_se_at(_intr.se, _intr.x, _intr.y)
				if (_intr.x == self.x) && (_intr.y == self.y) // must be in same exact pos
					instance_destroy(_intr.id)
				break;
			}
			case "figure": {
				packetLog("PID " + string(self.pid) + " Interacted w/ figure! forced_state: '" + string(self.forced_state) + "'")
				packetLog("Figure Interaction Handling is not integrated yet...")
				break;
			}
			case "piano": {
				packetLog("PID " + string(self.pid) + " Interacted w/ piano! forced_state: '" + string(self.forced_state) + "'")
	            play_se(_intr.se, 1)
	            instance_destroy(_intr.id)
				break;
			}
			case "hidebox": {
				packetLog("PID " + string(self.pid) + " Interacted w/ hidebox! forced_state: '" + string(self.forced_state) + "'")
				if (_plr.hidebox == -4) {
					_plr.hidebox = instance_create_depth(_plr.x, _plr.y, 0, obj_intr_hidebox)
					play_se_at(_plr.hidebox.se_in, _plr.x, _plr.y)
			        _plr.hidebox.shake = 20
					_plr.hidebox.locked = 1
			        _plr.hiding = 1
				} else {
					instance_destroy(_plr.hidebox)
					_plr.hidebox = -4
					_plr.hiding = 0
				}
			}
		}
	}
}
ds_map_add(global.packet_registry, 67, PLAY_CB_INTERACT_AT)

function PLAY_SB_SYNC_MINI_MSG(SOCK = -1, MINI_MSG = "", MINI_TMR = 0) constructor {
	self.__id = 68
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_SB_SYNC_MINI_MSG",
		packet_size: -1
	}
	
	self.sock = SOCK
	self.mini_msg = MINI_MSG
	self.mini_tmr = MINI_TMR
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.mini_msg = buffer_read_ext(buf)
		self.mini_tmr = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_string, self.mini_msg)
		buffer_write_ext(buf, buffer_vint, self.mini_tmr)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// adjust server version of object
		with (sock_to_inst(self.sock)) {
			miniMsgStr = other.mini_msg
			miniMsgTmr = other.mini_tmr
			other.packetLog("Updated mini msg for sock " + string(other.sock) + ", mini_msg = " + string(other.mini_msg) + ", mini_tmr = " + string(other.mini_tmr))
			
			// replicate to other clients
			var _t = array_without(struct_get_names(obj_multiplayer.server.clients), other.sock)
			do_packet(new PLAY_CB_SYNC_MINI_MSG(entity_id, other.mini_msg, other.mini_tmr), _t)
		}
	}
}
ds_map_add(global.packet_registry, 68, PLAY_SB_SYNC_MINI_MSG)

function PLAY_CB_SYNC_MINI_MSG(PID = -1, MINI_MSG = "", MINI_TMR = 0) constructor {
	self.__id = 69
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_CB_SYNC_MINI_MSG",
		packet_size: -1
	}
	
	self.pid = PID
	self.mini_msg = MINI_MSG
	self.mini_tmr = MINI_TMR
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.pid = buffer_read_ext(buf)
		self.mini_msg = buffer_read_ext(buf)
		self.mini_tmr = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_vint, self.pid)
		buffer_write_ext(buf, buffer_string, self.mini_msg)
		buffer_write_ext(buf, buffer_vint, self.mini_tmr)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// adjust server version of object
		with (pid_to_inst(self.pid)) {
			miniMsgStr = other.mini_msg
			miniMsgTmr = other.mini_tmr
			other.packetLog("Updated mini msg for pid " + string(other.pid) + ", mini_msg = " + string(other.mini_msg) + ", mini_tmr = " + string(other.mini_tmr))
		}
	}
}
ds_map_add(global.packet_registry, 69, PLAY_CB_SYNC_MINI_MSG)

function PLAY_SB_DISCONNECT(SOCK = -1, REASON = "notProvided") constructor {
	self.__id = 70
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_SB_DISCONNECT",
		packet_size: -1
	}
	
	self.sock = SOCK
	self.reason = REASON
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.reason = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_string, self.reason)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// adjust server version of object
		with (obj_pkun) {
			miniMsgStr = ("Client " + string(other.sock) + " Disconnected. Reason: " + string(other.reason))	
			miniMsgTmr = 300
		}
	}
}
ds_map_add(global.packet_registry, 70, PLAY_SB_DISCONNECT)

function PLAY_CB_DISCONNECT(REASON = "notProvided") constructor {
	self.__id = 71
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_CB_DISCONNECT",
		packet_size: -1
	}
	
	self.reason = REASON
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.reason = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_string, self.reason)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// adjust server version of object
		leave_server(other.reason)
		with (obj_pkun) { 
			miniMsgStr = ("You have been kicked. Reason: " + string(other.reason))	
			miniMsgTmr = 300
		}
	}
}
ds_map_add(global.packet_registry, 71, PLAY_CB_DISCONNECT)

//function PLAY_SB_SET_PKUN_MINI_MSG(SOCK = -1, MINI_MSG = "", MINI_TMR = 0) constructor {
//	self.__id = 72
//	self.sock = SOCK
//	self.mini_msg = MINI_MSG
//	self.mini_tmr = MINI_TMR
//	readPacketData = function(buf) {
//		buffer_seek(buf, buffer_seek_start, 0)
//		self.__id = buffer_read_ext(buf)
//		self.mini_msg = buffer_read_ext(buf)
//		self.mini_tmr = buffer_read_ext(buf)
//	}
//	writePacketData = function() {
//		var buf = buffer_create(1, buffer_grow, 1)
//		buffer_seek(buf, buffer_seek_start, 0)
//		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
//		buffer_write_ext(buf, buffer_string, self.mini_msg)
//		buffer_write_ext(buf, buffer_vint, self.mini_tmr)
//		self.__options.packet_size = buffer_tell(buf); return buf
//	}
//	processPacket = function() {
//		// adjust server version of object
//		with (sock_to_inst(self.sock)) {
//			miniMsgStr = other.mini_msg
//			miniMsgTmr = other.mini_tmr
//			show_debug_message("PLAY_SB_SYNC_MINI_MSG: Updated mini msg for sock " + string(other.sock) + ", mini_msg = " + string(other.mini_msg) + ", mini_tmr = " + string(other.mini_tmr))
			
//			// replicate to other clients
//			var _t = array_without(struct_get_names(obj_multiplayer.server.clients), other.sock)
//			do_packet(new PLAY_CB_SYNC_MINI_MSG(entity_id, other.mini_msg, other.mini_tmr), _t)
//		}
//	}
//}
//ds_map_add(global.packet_registry, 72, PLAY_SB_SYNC_MINI_MSG)

function PLAY_CB_SET_PKUN_MINI_MSG(MINI_MSG = "", MINI_TMR = 0) constructor {
	self.__id = 73
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_CB_SET_PKUN_MINI_MSG",
		packet_size: -1
	}
	
	self.mini_msg = MINI_MSG
	self.mini_tmr = MINI_TMR
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.mini_msg = buffer_read_ext(buf)
		self.mini_tmr = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_string, self.mini_msg)
		buffer_write_ext(buf, buffer_vint, self.mini_tmr)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// adjust client version of object
		with (obj_pkun) {
			miniMsgStr = other.mini_msg
			miniMsgTmr = other.mini_tmr
			other.packetLog("Updated mini msg, mini_msg = " + string(other.mini_msg) + ", mini_tmr = " + string(other.mini_tmr))
		}
	}
}
ds_map_add(global.packet_registry, 73, PLAY_CB_SET_PKUN_MINI_MSG)

//function PLAY_SB_UPDATE_USERNAME(SOCK = -1, NEW_USERNAME = "unsetNewUsername") constructor {
//	self.__id = 74
//	self.__options = {
//		connection_state: CONNECTION_STATE.PLAY,
//		packet_title: "PLAY_SB_UPDATE_USERNAME"
//	}
	
//	self.sock = SOCK
//	self.username = NEW_USERNAME
//	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
//	readPacketData = function(buf) {
//		buffer_seek(buf, buffer_seek_start, 0)
//		self.__id = buffer_read_ext(buf)
//		self.username = buffer_read_ext(buf)
//	}
//	writePacketData = function() {
//		var buf = buffer_create(1, buffer_grow, 1)
//		buffer_seek(buf, buffer_seek_start, 0)
//		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
//		buffer_write_ext(buf, buffer_string, self.username)
//		self.__options.packet_size = buffer_tell(buf); return buf
//	}
//	processPacket = function() {
//		// adjust server version of object
//		var _old_username = obj_multiplayer.server.clients[$ self.sock]
//		var _pid = obj_multiplayer.network.players[$ _old_username]
		
//		packetLog("Changing username '" + string(_old_username) + "' to '" + string(self.username) + "' (EID: '" + string(_pid) + "')")
		
//		struct_set(obj_multiplayer.server.clients, self.sock, self.username)
//		struct_remove(obj_multiplayer.network.players, _old_username) // clear old uuid
//		struct_set(obj_multiplayer.network.players, self.username, _pid)
	
//		with (username_to_inst(self.username)) {
//			if (nametag == _old_username) // change it if it was old username
//				nametag = other.username	
//		}
	
//		do_packet(new PLAY_CB_UPDATE_USERNAME(_old_username, self.username), array_without(struct_get_names(obj_multiplayer.server.clients), self.sock))
//	}
//}
//ds_map_add(global.packet_registry, 74, PLAY_SB_UPDATE_USERNAME)

//function PLAY_CB_UPDATE_USERNAME(OLD_USERNAME, NEW_USERNAME = "unsetNewUsername") constructor {
//	self.__id = 75
//	self.__options = {
//		connection_state: CONNECTION_STATE.PLAY,
//		packet_title: "PLAY_CB_UPDATE_USERNAME"
//	}
	
//	self.old_username = OLD_USERNAME
//	self.username = NEW_USERNAME
//	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
//	readPacketData = function(buf) {
//		buffer_seek(buf, buffer_seek_start, 0)
//		self.__id = buffer_read_ext(buf)
//		self.old_username = buffer_read_ext(buf)
//		self.username = buffer_read_ext(buf)
//	}
//	writePacketData = function() {
//		var buf = buffer_create(1, buffer_grow, 1)
//		buffer_seek(buf, buffer_seek_start, 0)
//		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
//		buffer_write_ext(buf, buffer_string, self.old_username)
//		buffer_write_ext(buf, buffer_string, self.username)
//		self.__options.packet_size = buffer_tell(buf); return buf
//	}
//	processPacket = function() {
//		// adjust server version of object
//		var _pid = obj_multiplayer.network.players[$ self.old_username]
		
//		packetLog("Changing username '" + string(self.old_username) + "' to '" + string(self.username) + "' (EID: '" + string(_pid) + "')")
		
//		struct_remove(obj_multiplayer.network.players, self.old_username) // clear old uuid
//		struct_set(obj_multiplayer.network.players, self.username, _pid)
		
//		with (username_to_inst(self.username)) {
//			if (nametag == other.old_username) // change it if it was old username
//				nametag = other.username	
//		}
//	}
//}
//ds_map_add(global.packet_registry, 75, PLAY_CB_UPDATE_USERNAME)

function PLAY_SB_KEEP_ALIVE(SOCK = -1) constructor {
	self.__id = 76
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_SB_KEEP_ALIVE",
		packet_size: -1
	}
	
	self.sock = SOCK
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		packetLog("Got sock (" + string(self.sock) + ") KEEP_ALIVE")
		var _tn = (string(self.sock) + "_SEND_KEEPALIVE_TIMER")
		if struct_exists(obj_multiplayer.network.timers, _tn) {
			obj_multiplayer.network.timers[$ _tn].curr = obj_multiplayer.network.timers[$ _tn].duration
			packetLog("Reset '" + _tn + "' timer.")
		} else {
			packetLog("No '" + _tn + "' timer to reset?", "WARNING")
		}
	}
}
ds_map_add(global.packet_registry, 76, PLAY_SB_KEEP_ALIVE)

function PLAY_CB_KEEP_ALIVE() constructor {
	self.__id = 77
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_CB_KEEP_ALIVE",
		packet_size: -1
	}

	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// client
		packetLog("Got server (" + string(obj_multiplayer.network.server.connection) + ") KEEP_ALIVE")
		var _tn = "SERVER_PLAY_KEEPALIVE_TIMEOUT"
		if struct_exists(obj_multiplayer.network.timers, _tn) {
			obj_multiplayer.network.timers[$ _tn].curr = obj_multiplayer.network.timers[$ _tn].duration
			packetLog("Reset '" + _tn + "' timer.")
		} else {
			packetLog("No '" + _tn + "' timer to reset?", "WARNING")
		}
	}
}
ds_map_add(global.packet_registry, 77, PLAY_CB_KEEP_ALIVE)

//function PLAY_CB_PLAYER_JOINED(USERNAME = "playerJoinedUnsetUsername", X = -4, DX = 0, Y = -4, DIR = 1, PID = -1, FLASH = 1, HIDING = 0) constructor {
//	// generate player array ([ username, x, dx, y, dir, pid, flash, hiding])
//	self.__id = 78
//	self.__options = {
//		connection_state: CONNECTION_STATE.PLAY,
//		packet_title: "PLAY_CB_PLAYER_JOINED"
//	}

//	self.username = USERNAME
//	self.pos = [X, DX, Y, DIR]
//	self.pid = PID
//	self.flash = FLASH
//	self.hiding = HIDING
//	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
//	readPacketData = function(buf) {
//		buffer_seek(buf, buffer_seek_start, 0)
//		self.__id = buffer_read_ext(buf)
//		self.username = buffer_read_ext(buf)
//		self.pos = buffer_read_ext(buf)
//		self.pid = buffer_read_ext(buf)
//		self.flash = buffer_read_ext(buf)
//		self.hiding = buffer_read_ext(buf)
//	}
//	writePacketData = function() {
//		var buf = buffer_create(1, buffer_grow, 1)
//		buffer_seek(buf, buffer_seek_start, 0)
//		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
//		buffer_write_ext(buf, buffer_string, self.username)
//		buffer_write_ext(buf, buffer_position, self.pos)
//		buffer_write_ext(buf, buffer_vint, self.pid)
//		buffer_write_ext(buf, buffer_bool, self.flash)
//		buffer_write_ext(buf, buffer_bool, self.hiding)
//		self.__options.packet_size = buffer_tell(buf); return buf
//	}
//	processPacket = function() {
//		// client
//		packetLog("Player joined!")
//		var _tn = "SERVER_PLAY_KEEPALIVE_TIMEOUT"
//		if struct_exists(obj_multiplayer.network.timers, _tn) {
//			obj_multiplayer.network.timers[$ _tn].curr = obj_multiplayer.network.timers[$ _tn].duration
//			packetLog("Reset '" + _tn + "' timer.")
//		} else {
//			packetLog("No '" + _tn + "' timer to reset?", "WARNING")
//		}
//	}
//}
//ds_map_add(global.packet_registry, 78, PLAY_CB_PLAYER_JOINED)

function PLAY_CB_SET_MARY_LOCATION(LOC = "", TIMER = 0, WAIT = 0, LIFESPAN = 3) constructor {
	self.__id = 79
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_CB_SET_MARY_LOCATION",
		packet_size: -1
	}

	self.loc = LOC
	self.timer = TIMER
	self.wait = WAIT
	self.lifespan = LIFESPAN
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.loc = buffer_read_ext(buf)
		self.timer = buffer_read_ext(buf)
		self.wait = buffer_read_ext(buf)
		self.lifespan = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_string, self.loc)
		buffer_write_ext(buf, buffer_vint, self.timer)
		buffer_write_ext(buf, buffer_vint, self.wait)
		buffer_write_ext(buf, buffer_vint, self.lifespan)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// client
		packetLog("Got server (" + string(obj_multiplayer.network.server.connection) + ") PLAY_CB_SET_MARY_LOCATION: " + string(self.loc))
		if !instance_exists(obj_mary) {
			packetLog("mary inst doesnt exist, creating")
			var _ent = new entity(0, 0, 1, obj_mary, -3)
			_ent.create()
		}
		
		with (obj_mary) {
			loc = other.loc	
            timer = other.timer
            wait = other.wait
			lifespan = other.lifespan
		}
		
		if ((global.language == (0)))
			global.mini_dialog_line = ((((getText("mary_front") + "「$ffff00") + loc) + "$ffffff」") + getText("mary_back"))
        else
			global.mini_dialog_line = ((((getText("mary_front") + "'$ffff00") + loc) + "$ffffff'") + getText("mary_back"))
	}
}
ds_map_add(global.packet_registry, 79, PLAY_CB_SET_MARY_LOCATION)

function PLAY_CB_PLAY_SE_AT(SE = -4, X = 0, Y = 0) constructor {
	self.__id = 80
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_CB_PLAY_SE_AT",
		packet_size: -1
	}

	self.se = SE
	self.x = X
	self.y = Y
//	self.vol = VOL
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.se = buffer_read_ext(buf)
		self.x = buffer_read_ext(buf)
		self.y = buffer_read_ext(buf)
//		self.vol = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_vint, self.se)
		buffer_write_ext(buf, buffer_vint, self.x)
		buffer_write_ext(buf, buffer_vint, self.y)
//		buffer_write_ext(buf, buffer_vint, self.vol)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// client
		packetLog("Got server (" + string(obj_multiplayer.network.server.connection) + ") PLAY_CB_PLAY_SE_AT: " + string(self.se))
		play_se_at(self.se, self.x, self.y)
	}
}
ds_map_add(global.packet_registry, 80, PLAY_CB_PLAY_SE_AT)

function PLAY_SB_PLAY_SE_AT(SOCK = -1, SE = -4, X = 0, Y = 0) constructor {
	self.__id = 81
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_SB_PLAY_SE_AT",
		packet_size: -1
	}

	self.sock = SOCK
	self.se = SE
	self.x = X
	self.y = Y
//	self.vol = VOL
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.se = buffer_read_ext(buf)
		self.x = buffer_read_ext(buf)
		self.y = buffer_read_ext(buf)
//		self.vol = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_vint, self.se)
		buffer_write_ext(buf, buffer_vint, self.x)
		buffer_write_ext(buf, buffer_vint, self.y)
//		buffer_write_ext(buf, buffer_vint, self.vol)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// server
		packetLog("Got client (" + string(self.sock) + ") PLAY_SB_PLAY_SE_AT: " + string(self.se))
		play_se_at(self.se, self.x, self.y)
	}
}
ds_map_add(global.packet_registry, 81, PLAY_SB_PLAY_SE_AT)

function PLAY_SB_DO_ENTITY_EVENT(SOCK = -1, EVENT_ID = -1, OBJ_INDEX = -4, DATA = undefined) constructor {
	self.__id = 82
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_SB_DO_ENTITY_EVENT",
		packet_size: -1
	}

	self.sock = SOCK
	self.object_index = OBJ_INDEX
	self.event_id = EVENT_ID
	self.data = DATA
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.object_index = buffer_read_ext(buf)
		self.event_id = buffer_read_ext(buf)
		var _data = buffer_read_ext(buf)
		self.data = (is_undefined(_data)) ? undefined : _data
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_vint, self.object_index)
		buffer_write_ext(buf, buffer_vint, self.event_id)
		buffer_write_ext(buf, ((self.data != undefined) ? value_to_datatype(self.data) : buffer_undefined), self.data)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// server
		packetLog("Got client (" + string(self.sock) + ") PLAY_SB_DO_ENTITY_EVENT: " + string(self.object_index))
		run_entity_event(self.event_id, self.object_index, self.data)
	}
}
ds_map_add(global.packet_registry, 82, PLAY_SB_DO_ENTITY_EVENT)

function PLAY_CB_DO_ENTITY_EVENT(EVENT_ID = -1, OBJ_INDEX = -4, DATA = undefined) constructor {
	self.__id = 83
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_CB_DO_ENTITY_EVENT",
		packet_size: -1
	}

	self.object_index = OBJ_INDEX
	self.event_id = EVENT_ID
	self.data = DATA
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.object_index = buffer_read_ext(buf)
		self.event_id = buffer_read_ext(buf)
		var _data = buffer_read_ext(buf)
		self.data = (is_undefined(_data)) ? undefined : _data

	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_vint, self.object_index)
		buffer_write_ext(buf, buffer_vint, self.event_id)
		buffer_write_ext(buf, ((self.data != undefined) ? value_to_datatype(self.data) : buffer_undefined), self.data)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// client
		packetLog("Got server (" + string(obj_multiplayer.network.server.connection) + ") PLAY_CB_DO_ENTITY_EVENT: " + string(self.object_index))
		run_entity_event(self.event_id, self.object_index, self.data)
	}
}
ds_map_add(global.packet_registry, 83, PLAY_CB_DO_ENTITY_EVENT)

function PLAY_CB_SET_TIME(HR, MIN, TK, TK_SPD) constructor {
	self.__id = 84
	self.__options = {
		connection_state: CONNECTION_STATE.PLAY,
		packet_title: "PLAY_CB_SET_TIME",
		packet_size: -1
	}

	self.hr = HR
	self.min = MIN
	self.tk = TK
	self.tk_spd = TK_SPD
	packetLog = function(msg, type = logType.info.def, packet_func = "processPacket") {log(msg, type, "PKT/" + string(self.__options.packet_title) + "/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.__id = buffer_read_ext(buf)
		self.hr = buffer_read_ext(buf)
		self.min = buffer_read_ext(buf)
		self.tk = buffer_read_ext(buf)
		self.tk_spd = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
 		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.__id)
		buffer_write_ext(buf, buffer_vint, self.hr)
		buffer_write_ext(buf, buffer_vint, self.min)
		buffer_write_ext(buf, buffer_vint, self.tk)
		buffer_write_ext(buf, buffer_vint, self.tk_spd)
		self.__options.packet_size = buffer_tell(buf); return buf
	}
	processPacket = function() {
		// client
		packetLog("Got server (" + string(obj_multiplayer.network.server.connection) + ") PLAY_CB_SET_TIME")
		global.clock_hr = self.hr
		global.clock_min = self.min
		global.clock_tk = self.tk
		global.clock_tk_spd = self.tk_spd
	}
}
ds_map_add(global.packet_registry, 84, PLAY_CB_SET_TIME)



/// @function do_packet
/// @param {struct} pkt Constructed packet to send
/// @param {any} target_socks Socks to send pkt to
/// @description Sends a constructed packet.
function do_packet(pkt, target_socks) {
	var pktbuf = pkt.writePacketData()
	multiplayer_queue_packet(target_socks, pktbuf)
}

// packet sending functions
function sync_pkun_event() {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/sync_pkun_event")}
	__log("Ran deprecated syncing function!", logType.warning.deprecated)
}

/// @function _cb_sync_pkun
/// @param {string} uuid Entity EID of pkun/network object
/// @param {number} tx X position
/// @param {number} tdx MoveSpeed (pkun is 4 for walking, 12 for running)
/// @param {number} ty Y position
/// @param {number} tdir DIR
/// @param {number} src_sock Source sock
/// @description Sends pkun sync packet to all clients. Leave params blank and it will send server's own pkun update packet.
function _cb_sync_pkun(uuid = "", tx = -4, tdx = -4, ty = -4, tdir = -4, thiding = -4, src_sock = -1) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/_cb_sync_pkun")}
	__log("Ran deprecated syncing function!", logType.warning.deprecated)
	exit;
	
	if (!check_is_server() || !instance_exists(obj_pkun) || room = rm_intro || room = rm_title) {
		exit; // only run as server and if we have moved
	}
	
	var provided_pid = !(uuid == "")
	
	var entityEID = provided_pid ? uuid : obj_multiplayer.server.player.pid; 
	var tX = provided_pid ? tx : obj_pkun.x
	var tDX = provided_pid ? tdx : obj_pkun.move_speed
	var tY = provided_pid ? ty : obj_pkun.y
	var tDIR = provided_pid ? tdir : obj_pkun.dir
	var tHIDING = provided_pid ? thiding : obj_pkun.hiding
	var last_pos = global.multiplayer_pkun_sync_hist
	
	if (!provided_pid) {
		if (last_pos[0] == tX) && (last_pos[1] == tY) && (last_pos[2] == tDIR) && (last_pos[10] == tHIDING) {
			if global.multiplayer_check_sent_last_pkun_pos { // we did do the last update
				exit;
			} else {
				global.multiplayer_check_sent_last_pkun_pos = 1
			}
		} else {
			global.multiplayer_check_sent_last_pkun_pos = 0 // pos changed	
		}
		global.multiplayer_pkun_sync_hist[0] = tX
		global.multiplayer_pkun_sync_hist[1] = tY
		global.multiplayer_pkun_sync_hist[2] = tDIR
		global.multiplayer_pkun_sync_hist[10] = tHIDING
		
		obj_pkun.last_move_speed = obj_pkun.move_speed
	}
	
	var target_socks = array_without(struct_get_names(obj_multiplayer.server.clients), src_sock)
//	do_packet(new PLAY_CB_MOVE_PLAYER_POS(entityEID, tX, tDX, tY, tDIR, tHIDING), target_socks) //, tTW, tFO)
//	__log("Sent Server to Client Pkun Sync Packet (" + string(src_sock) + " -> " + string(target_socks) + ")")
}

function sync_flashlight_event() {
	if !is_multiplayer()
		exit;
	
	// check if we already sent flashlight update
	var hist = global.multiplayer_pkun_sync_hist
	var last_flash = hist[6]
	var check = hist[7]
	
	if (global.flashOn == last_flash) { // same 
		if check // already sent last update packet
			exit;
		check = 1	
	} else {
		check = 0	
	}
	
	hist[6] = global.flashOn
	hist[7] = check;
	
	if (check_is_server() || (obj_multiplayer.network.server.connection < 0)) {
		if check_is_server() {
			// redirect to server to client shit
			// this will only fire when it is the SERVER's pkun updating his flashlight
			_cb_sync_flashlight(obj_multiplayer.server.player.pid, global.flashOn)
		}
		exit; // only run as client
	}
		
	do_packet(new PLAY_SB_TOGGLE_FLASHLIGHT(-1, global.flashOn), obj_multiplayer.network.server.connection)
}

function _cb_sync_flashlight(pid, flash) {
	if (!check_is_server()) {
		exit; // only run as server
	}
	
	var target_socks = struct_get_names(obj_multiplayer.server.clients)
	if !(pid == obj_multiplayer.server.player.pid) // avoid cannot find pid warning
		target_socks = array_without(target_socks, string(pid_to_sock(pid)))
	do_packet(new PLAY_CB_TOGGLE_FLASHLIGHT(pid, flash), target_socks)
}

function _cb_sync_mobs() {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/_cb_sync_mobs")}
	__log("Ran deprecated syncing function!", logType.warning.deprecated)
	with (obj_p_mob) {
		_cb_sync_mob()
	}	
}

function _cb_sync_mob() {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/_cb_sync_mob")}
	__log("Ran deprecated syncing function!", logType.warning.deprecated)
}

function sync_hscene_event(se = undefined) {
	if (room == rm_intro || room == rm_title || !is_multiplayer()) {
		exit; // only run as server and not in title or anything
	}
	
	var hist = global.multiplayer_pkun_sync_hist
	
	// X, Y, DIR, HS_MOB_ID, HS_STP, HS_CHECK
	var last_hscene_mob_id = hist[3]
	var last_hscene_stp = hist[4]
	var hscene_check = hist[5]
	
	var msg = ""
	
	if (last_hscene_mob_id == obj_pkun.hs_mob_id) && (last_hscene_stp == obj_pkun.hs_stp) {
		if hscene_check { // we did do the last update
//			show_debug_message("SKIPPING HSCENE UPDATE, ALREADY SENT LAST UPDATE PACKET")
			exit;
		} else {
//			show_debug_message("SENDING LAST HSCENE UPDATE PACKET, DIDNT CHANGE THO")
			hscene_check = 1
		}
	} else {
		hscene_check = 0 // pos changed	
		
		if !(last_hscene_mob_id == obj_pkun.hs_mob_id)
			msg+= "\Hscene hs_mob_id Changed"
		if !(last_hscene_stp == obj_pkun.hs_stp)
			msg+= "\nHscene Stp Changed"
			
//		show_debug_message("sync_hscene_event HSCENE CHANGED, differences:" + msg)
	}
	
	show_debug_message("SENDING HSCENE UPDATE PACKET")
	global.multiplayer_pkun_sync_hist[3] = obj_pkun.hs_mob_id
	global.multiplayer_pkun_sync_hist[4] = obj_pkun.hs_stp
	global.multiplayer_pkun_sync_hist[5] = hscene_check
	
	if check_is_server() {
		var target_socks = struct_get_names(obj_multiplayer.server.clients)
		do_packet(new PLAY_CB_SET_HSCENE(obj_multiplayer.server.player.pid, obj_pkun.hs_mob_id, obj_pkun.hs_stp, se), target_socks)
	} else {
		do_packet(new PLAY_SB_SET_HSCENE(-1, obj_pkun.hs_mob_id, obj_pkun.hs_stp, se), obj_multiplayer.network.server.connection)
	}
}

function _cb_create_entity(EID, X, DX, Y, DIR, OBJ_INDEX) {
	if (!check_is_server()) { // || (server_player_count() <= 1) || (instance_number(obj_p_syncable) == 0) {
		exit; // only run as server
	}
	
	show_debug_message("_cb_create_entity " + string(object_get_name(OBJ_INDEX)) + " (" + string(EID) + ")")
	
	if !struct_exists(obj_multiplayer.network.entities, EID) {
		show_debug_message("_cb_create_entity " + string(object_get_name(OBJ_INDEX)) + " (" + string(EID) + ") FAILED! EID doesnt exist in serverside network.entities!")
		exit;
	}
	
	var target_socks = struct_get_names(obj_multiplayer.server.clients)
	do_packet(new PLAY_CB_CREATE_ENTITY(entity_id, x, dx, y, dir, object_index) , target_socks)
}

function _cb_destroy_entity(EID) {
	if (!check_is_server()) { // || (server_player_count() <= 1) || (instance_number(obj_p_syncable) == 0) {
		exit; // only run as server
	}
	
	show_debug_message("_cb_destroy_entity (" + string(EID) + ")")
	do_packet(new PLAY_CB_DESTROY_ENTITY(entity_id), struct_get_names(obj_multiplayer.server.clients))
}

function _cb_destroy_object(object_index) {
	if (!check_is_server()) { // || (server_player_count() <= 1) || (instance_number(obj_p_syncable) == 0) {
		exit; // only run as server
	}
	
	show_debug_message("_cb_destroy_object (" + string(object_index) + ", " + string(object_get_name(object_index)) + ")")
	do_packet(new PLAY_CB_DESTROY_OBJECT(object_index), struct_get_names(obj_multiplayer.server.clients))
}

function timestop_change_event() {
	show_debug_message("RUNNING TIMESTOP SET EVENT")
	if is_multiplayer() {
		if check_is_server()
			do_packet(new PLAY_CB_SET_TIME_STOP(0, global.timeStop), struct_get_names(obj_multiplayer.server.clients))
		else
			do_packet(new PLAY_SB_SET_TIME_STOP(-1, global.timeStop), obj_multiplayer.network.server.connection)
	}
}

function interact_event() {
	show_debug_message("RUNNING INTERACT MULTIPLAYER EVENT")
	if is_multiplayer() {
		if !instance_exists(intrTarget)
			exit;

		var _intr_type = (intrTarget.object_index == obj_intr_hidebox) ? "hidebox" : intrTarget.type
		var _new_state = (_intr_type == "hidespot") ? intrTarget.locked : -4
		show_debug_message("RUNNING INTERACT MULTIPLAYER EVENT, INTRTYPE IS " + string(_intr_type))
		if check_is_server() {
			do_packet(new PLAY_CB_INTERACT_AT(obj_multiplayer.server.player.pid, _intr_type, intrTarget.x, intrTarget.y, 0, obj_pkun.hiding), struct_get_names(obj_multiplayer.server.clients))	
		} else {
			do_packet(new PLAY_SB_INTERACT_AT(-1, _intr_type, intrTarget.x, intrTarget.y, obj_pkun.hiding), obj_multiplayer.network.server.connection)	
		}
	}
}

function update_pkun_mini_msg_event() {
	if !is_multiplayer()
		exit;
	
	// check if we already sent mini_msg update
	var hist = global.multiplayer_pkun_sync_hist
	var last_msg = hist[8]
	var check = hist[9]
	
	if (miniMsgStr == last_msg) { // same 
		if check // already sent last update packet
			exit;
		check = 1	
	} else {
		check = 0	
	}
	
	hist[8] = miniMsgStr
	hist[9] = check;
	
	if check_is_server() {
		do_packet(new PLAY_CB_SYNC_MINI_MSG(obj_multiplayer.server.player.pid, miniMsgStr, miniMsgTmr), struct_get_names(obj_multiplayer.server.clients))	
	} else {
		do_packet(new PLAY_SB_SYNC_MINI_MSG(-1, miniMsgStr, miniMsgTmr), obj_multiplayer.network.server.connection)	
	}
}

function generate_game_state_packet(sock) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/generate_game_state_packet")}
	__log("Starting Game State Packet Generation... (For sock " + string(sock) + ")")
	var GSA = [] // game state array
	var IA = [] // interactables array
	var PA = [] // players array
	var EA = [] // mobs array
	var CI = [] // client info
	var SI = [] // server info
	
	// generate game state array ([ GLOBAL_VAR_NAME, VAL, ... ])
	__log("Generating Game State Array...")
	var _globals = obj_multiplayer.server.settings.game.globals_to_sync
	for (var i = 0; i < array_length(_globals); i++) {
		var _name = _globals[i]
		array_push(GSA, _name)
		array_push(GSA, struct_get(global, _name))
	}
	__log("Generated Game State Array! GSA: " + string(GSA))
	
	// generate interactables array ([ pos, type, passenger, locked ])
	__log("Generating Interactables Array...")
	with (obj_interactable) {
		var _inst = [[x, 0, y, 1]] // pos
		array_push(_inst, variable_instance_exists(id, "type") ? type : 0)
		array_push(_inst, variable_instance_exists(id, "passenger") ? passenger : 0) // uuid
		array_push(_inst, variable_instance_exists(id, "locked") ? locked : 0)
		array_push(IA, _inst)
	}
	__log("Generated Interactables Array! IA: " + string(IA))
	
	// generate player array ([ username, x, dx, y, dir, pid, flash, hiding])
	__log("Generating Players Array...")
	var _players = struct_get_names(obj_multiplayer.network.players)
	
		// add server pkun if needed
	if !(struct_exists(obj_multiplayer.network.players, obj_multiplayer.server.player.pid)) {
		var __pid = obj_multiplayer.server.player.pid
		var _username = string(obj_multiplayer.server.player.username)
		var _inst = [_username, 0, 0, 0, 1, __pid, 1, 0]
		array_push(PA, _inst)
		__log(" - (server obj_pkun doesn't exist yet) Added '" + _username + "' (" + string(__pid) + ") -- inst: " + string(_inst))
	}
	
	for (var i = 0; i < array_length(_players); i++) {
		var __pid = _players[i]
		var __plr = obj_multiplayer.network.players[$ __pid]
		
		var _inst = [string(__plr.username), __plr.__x, 0, __plr.__y, __plr.dir, __pid, 1, 0]
		with (pid_to_inst(__pid)) {
			_inst[1] = x
			_inst[2] = abs(dx)
			_inst[3] = y
			_inst[4] = dir
			if (variable_instance_exists(id, "flashOn"))
				_inst[6] = flashOn
			if (variable_instance_exists(id, "hiding"))
				_inst[7] = hiding
		}
		array_push(PA, _inst)
		__log(" - Added '" + string(__plr.username) + "' (" + string(__pid) + ") -- inst: " + string(_inst))
	}
	__log("Generated Players Array! PA: " + string(PA))
	
	// generate entities array ([ eid, x, dx, y, dir, state, obj_index ])
	__log("Generating Entities Array...")
	var _entities = struct_get_names(obj_multiplayer.network.entities)
	for (var i = 0; i < array_length(_players); i++) {
		var __eid = _players[i]
		var __entitiy = obj_multiplayer.network.entities[$ __eid]
		var _inst = [__eid, -4, 0, -4, 1, 0, -4]
		with (eid_to_inst(__eid)) {
			_inst[1] = x
			_inst[2] = abs(dx)
			_inst[3] = y
			_inst[4] = dir
			if (variable_instance_exists(id, "state"))
				_inst[5] = state
			_inst[6] = object_index
		}
		array_push(EA, _inst)
		__log(" - Added '" + string(object_get_name(_inst[6])) + "' (" + string(__eid) + ") -- inst: " + string(_inst))
	}
	__log("Generated Entities Array! EA: " + string(EA))
	
	// generate client info
	__log("Generating Client Info...")
	array_push(CI, sock_get(sock, "pid")) // sock to pid
	__log("Generated Client Info! CI: " + string(CI))
	
	// generate server info
	__log("Generating Server Info...")
	array_push(SI, obj_multiplayer.server.player.username) // server's client username
	array_push(SI, obj_multiplayer.server.player.pid) // server's client uuid
	__log("Generated Server Info! SI: " + string(CI))
	
	return new LOAD_GAME_CB_GAME_STATE(GSA, IA, PA, EA, CI, SI)
}

function play_se_event(_se, _x, _y) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/play_se_event")}
	if !is_multiplayer() {
		exit;
	} else if check_is_server() {
		__log("Sending play sound at packet to clients")
		do_packet(new PLAY_CB_PLAY_SE_AT(_se, _x, _y), struct_get_names(obj_multiplayer.server.clients))
	} else {
		__log("Sending play sound at packet to server")
		do_packet(new PLAY_SB_PLAY_SE_AT(-1, _se, _x, _y), obj_multiplayer.network.server.connection)
	}
}

function entity_event_sync(event_id, obj_index = -4, data = undefined) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/entity_event_sync")}
	if !is_multiplayer() {
		exit;
	} else if check_is_server() {
		__log("Sending do entity event packet to clients")
		do_packet(new PLAY_CB_DO_ENTITY_EVENT(event_id, obj_index, data), struct_get_names(obj_multiplayer.server.clients))
	} else {
		__log("Sending do entity event packet to server")
		do_packet(new PLAY_SB_DO_ENTITY_EVENT(-1, event_id, obj_index, data), obj_multiplayer.network.server.connection)
	}
}

function sync_time() {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/entity_event_sync")}
	var g = global
	if !is_multiplayer() {
		exit;
	} else if check_is_server() {
		__log("Sending set time packet to clients " + string(g.clock_hr + g.clock_min + g.clock_tk + g.clock_tk_spd))
		do_packet(new PLAY_CB_SET_TIME(g.clock_hr, g.clock_min, g.clock_tk, g.clock_tk_spd), struct_get_names(obj_multiplayer.server.clients))
	} else {
		__log("Tried to sync time as client to server", logType.warning.server_action_as_client)
	}
}