function server_add_client(sock, username, status, data = {}) {
	var client = new _client(sock, username, status, data)
	
	struct_set(obj_multiplayer.server.clients, sock, client)
}

function _client(_sock, _username, _status, _data = {}) constructor {
	sock = _sock
	username = _username
	status = _status
}

function remove_timer(uuid, run_expiration_func = 0) {
	if struct_exists(obj_multiplayer.network.timers.path, uuid)	{
		if (run_expiration_func)
			obj_multiplayer.network.timers.path[$ uuid].curr = 0
		else 
			struct_remove(obj_multiplayer.network.timers.path, uuid)
	}
}

function add_timer(uuid, _decrease_amt, _dur, _func = undefined, _loop = 0, _remove_on_expiration = 1) {
	var tmr = new multiplayer_timer(_decrease_amt, _dur, _func, _loop, _remove_on_expiration)
	struct_set(obj_multiplayer.network.timers, uuid, tmr)
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
	var __log = function(msg, type = logInfoType) {log(msg, type, "FUNC/start_server")}
	
	if !instance_exists(obj_multiplayer) {
		instance_create_depth(0, 0, 999, obj_multiplayer)
		__log("Created 'obj_multiplayer' instance since it didn't exist.")
	}
	
	with (obj_multiplayer) {
		if (network.server.socket > 0) {
			__log("Tried to start already running server. NETWORK_SOCKET_ID: " + string(network.server.socket), logWarningType)	
		}
		
		// Create server
		network.server.socket = network_create_server(network_socket_tcp, port, MAX_CLIENTS)
		network.server.connected = 1
		network.role = NETWORK_ROLE.SERVER
		network.connection_state = CONNECTION_STATE.HOSTING
		struct_set(network.statistics, "network_server_created_at", current_time)
		_log("Created server! NETWORK_SOCKET_ID: " + string(network.server.socket))
	}
}

function join_server(username = "joinserverUnsetUsername", ip = "127.0.0.1", port = SERVER_PORT) {
	var _log = function(msg, type = logInfoType) {log(msg, type, "FUNC/join_server")}
	
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
		}
		
		network.server.socket = network_create_socket(network_socket_tcp)
		network.server.connection = network_connect(network.server.socket, ip, port)
		_log("Joined, sending username")
		do_packet(new PLAY_SB_UPDATE_USERNAME(-1, username), network.server.connection)
	}
}

function leave_server(reason) {
	var _log = function(msg, type = logInfoType) {log(msg, type, "FUNC/leave_server")}
	
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

function server_remove_player_inst(sock) {
	var _log = function(msg, type = logInfoType) {log(msg, type, "FUNC/server_remove_player_inst")}
	var _username = string(obj_multiplayer.server.clients[$ sock])
	if !check_is_server()
		exit; // only as server dumbass
	
	_log("Removing player (" + string(sock) + ", '" + _username + "')")
	struct_remove(server.clients, string(sock))
	var _inst = sock_to_inst(string(sock))
	
	if ((_inst == noone) || (!instance_exists(_inst))) {
		_log("Tried to remove non-existant sock inst! (" + string(sock) + ")")
		exit;
	}
	
	// unhide if hiding in non-hidebox
	if ((_inst.hiding) && (_inst.hidebox == -4)) {
		var _intr_target = instance_nearest(_inst.x, _inst.y, obj_interactable)
		with (_intr_target) {
			if (distance_to_object(_inst) <= 50) {
				_log("Inst to remove is hiding. Nearest interactable is " + string(_intr_target))
				do_packet(new PLAY_CB_INTERACT_AT(obj_multiplayer.server.player.entity_uuid, _intr_target.type, _intr_target.x, _intr_target.y, 0), struct_get_names(obj_multiplayer.server.clients))
			} else {
				_log("Inst to remove is hiding. Nearest interactable is too far, skipping...")	
			}
		}
	}
	
	do_packet(new PLAY_CB_DESTROY_ENTITY(_inst.entity_uuid), struct_get_names(server.clients))
	if struct_exists(network.players, _username)
		instance_destroy(_inst)
}

function close_server() {
	var __log = function(msg, type = logInfoType) {log(msg, type, "FUNC/start_server")}
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
		entity_uuid = ""
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

function multiplayer_send_packet(sockets, buffer) {
	if !is_array(sockets) sockets = [sockets]
	for (var i = 0; i < array_length(sockets); i++) {
		network_send_packet(real(sockets[i]), buffer, buffer_get_size(buffer))
		global.multiplayer_packets_sent++
//		show_debug_message("multiplayer_send_packet: Sent packet out! (" + string(sockets[i]) + ")")
	}
}

function multiplayer_handle_packet(sock, buffer) {
	var __log = function(msg, type = logInfoType) {log(msg, type, "FUNC/multiplayer_handle_packet")}
	buffer_seek(buffer, buffer_seek_relative, 0)
	var packet_id = buffer_read_ext(buffer)
	buffer_seek(buffer, buffer_seek_relative, 0)
	if ds_map_exists(global.packet_registry, packet_id) {
		var pkt = new global.packet_registry[? packet_id](sock)
		if !(pkt.options.connection_state == obj_multiplayer.network.connection_state) {
			__log("Ignoring recieved packet, connection_state mismatch!", logWarningType)
		}
		pkt.readPacketData(buffer)
		pkt.processPacket()
	} else {
		__log("Packet ID not found in packet registry! (Packet ID: " + string(packet_id) + ")", logWarningType)
	}
}

function entity_uuid_to_inst(uuid) {
	if !is_multiplayer()
		return noone

	if !is_undefined(obj_multiplayer.network.entities[$ uuid])
		return obj_multiplayer.network.entities[$ uuid]
	
	with (obj_network_object) {
		if (entity_uuid == uuid) {
			struct_set(obj_multiplayer.network.entities, uuid, id)
			return id	
		}
	}
	
	return noone
}

function sock_to_inst(sock) {
	sock = string(sock)
	var _username = obj_multiplayer.server.clients[$ sock]
	var _uuid = obj_multiplayer.network.players[$ _username]
	return entity_uuid_to_inst(_uuid)
}

function username_to_inst(username) {
	var _uuid = obj_multiplayer.network.players[$ username]
	return entity_uuid_to_inst(_uuid)
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

// CONSTRUCTORS

function entity(X, Y, DIR, OBJECT_INDEX, DEPTH_OR_LAYER, VARIABLES_STRUCT = {}) constructor {
	var e = self
	e.entity_id = (instance_exists(obj_multiplayer)) ? struct_names_count(obj_multiplayer.network.entities) : 0
	e.x = X
	e.dx = 0
	e.y = Y
	e.dir = DIR
	e.instance = -4
	// "__" before variable means it wont applied to instance self on creation
	e.__object_index = OBJECT_INDEX
	e.__variables_struct = VARIABLES_STRUCT
	e.__depth_or_layer = DEPTH_OR_LAYER
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

	entityLog = function(msg, type = logInfoType, src_func = "unspecifiedFunc") {
		var e = self
		var _obj_name = object_get_name(e.__object_index)
		log(msg, type, "ENTITY/" + _obj_name + "/" + string(src_func))
	}
	create = function() {
		var e = self
		var __log = function (msg, type = logInfoType) {entityLog(msg, type, "create")}
		
		__log("Started creation process for '" + object_get_name(e.__object_index) + "' entity:")
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
		__log("Created '" + object_get_name(e.__object_index) + "' entity! (x" + string(e.instance.x) + ", y" + string(e.instance.y) + ")")
	}
	attach = function(id) {
		var e = self
		var __log = function (msg, type = logInfoType) {entityLog(msg, type, "attach")}
		
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
		__log("Attached to '" + object_get_name(e.__object_index) + "' entity! (x" + string(e.instance.x) + ", y" + string(e.instance.y) + ")")
	}
	destroy = function() {
		var e = self
		var __log = function (msg, type = logInfoType) {entityLog(msg, type, "destroy")}

		__log("Started destroy process for '" + object_get_name(e.__object_index) + "' entity:")
		__log("- Destroying '" + object_get_name(e.__object_index) + "' instance")
		instance_destroy(e.instance)
		if instance_exists(obj_multiplayer) {
			__log("- Removing entity from obj_multiplayer entities struct.")
			struct_remove(obj_multiplayer.network.entities, e.entity_id)
		} else {
			__log("- Cannot remove entity from entities struct, obj_multiplayer instance doesn't exist.", logWarningType)	
		}
		__log("Destroyed '" + object_get_name(e.__object_index) + "' entity!")
	}
	var __log = function (msg, type = logInfoType) {entityLog(msg, type, "structInit")}
	__log("Entity struct created! (" + object_get_name(e.__object_index) + ")")
}

function player_entity(USERNAME, X, Y, DIR, VARIABLES_STRUCT = {}, PLAYER_ID = undefined) constructor {
	var p = self
	p.player_id = (is_undefined(PLAYER_ID)) ? ((instance_exists(obj_multiplayer)) ? struct_names_count(obj_multiplayer.network.players) : 0) : real(PLAYER_ID)
	p.username = string(USERNAME)
	p.__x = X
	p.__y = Y
	p.dir = DIR
	p.__object_index = obj_network_object
	var _vs = {network_obj_type: "player", username: p.username, nametag: p.username}
	p.entity = new entity(p.__x, p.__y, p.dir, p.__object_index, 0, _vs)
	
	kick = function() {
		exit;
	}
	entityLog = function(msg, type = logInfoType, src_func = "unspecifiedFunc") {
		var p = self
		log(msg, type, "PLAYER_ENTITY/" + p.username + "/" + string(src_func))
	}
	create = function() {
		var p = self
		var __log = function (msg, type = logInfoType) {entityLog(msg, type, "create")}
		__log("Create ran for player entity, passthrough to entity.create")
		p.entity.create()
		struct_set(obj_multiplayer.network.players, p.player_id, self)
	}
	destroy = function() {
		var p = self
		var __log = function (msg, type = logInfoType) {entityLog(msg, type, "destroy")}
		__log("Destroy ran for player entity, passthrough to entity.destroy")
		p.entity.destroy()
		if instance_exists(obj_multiplayer) {
			__log("- Removing player from obj_multiplayer players struct.")
			struct_remove(obj_multiplayer.network.players, p.player_id)
		} else {
			__log("- Cannot remove entity from players struct, obj_multiplayer instance doesn't exist.", logWarningType)	
		}
	}
	var __log = function (msg, type = logInfoType) {entityLog(msg, type, "structInit")}
	__log("Player struct created! (" + p.username + ")")
}

//function player(SOCK, USERNAME) constructor {
//	self.sock = SOCK
//	self.username = USERNAME
//	self.network_object = instance_Create
//	self.entity_uuid = 
//}

////
//// PACKETS
////

global.packet_registry = ds_map_create()

/* base */
function BASE_PACKET(_id = -1) constructor {
	self.id = _id
	self.options = {
		connection_state: CONNECTION_STATE.CONNECT
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
function CONNECT_SB_PING_REQUEST(RID = -1) constructor {
	self.id = 5
	self.rid = RID
	self.options = {
		connection_state: CONNECTION_STATE.CONNECT
	}
	readPacketData = function(buf) {
		self.id = buffer_read_ext(buf)
		self.rid = buffer_read_ext(buf, buffer_vint, undefined, 1)
	}
	writePacketData = function() {
		var buf = buffer_create(2, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_vint, self.rid)
		return buf
	}
	processPacket = function() {
//		var _rbuf = writePacketData()
		exit;
	}
}
ds_map_add(global.packet_registry, 5, CONNECT_SB_PING_REQUEST)

function CONNECT_CB_CONFIRM_CONNECTION(SOCK = -1) constructor {
	self.id = 6
	self.sock = SOCK
	self.options = {
		connection_state: CONNECTION_STATE.CONNECT
	}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(32, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		return buf
	}
	processPacket = function() {
		if !instance_exists(obj_network_object) {
			var no = instance_create_depth(self.pos[0], self.pos[1], 0, obj_network_object)
			no.network_obj_type = "player"
		}
		with (obj_multiplayer) {
			// client
			_log("Connected to server! (Recieved CONNECT_CB_CONFIRM_CONNECTION on sock '" + string(other.sock) + "')")
		}
	}
}
ds_map_add(global.packet_registry, 51, PLAY_SB_MOVE_PLAYER_POS)

function CONNECT_CB_PONG_RESPONSE(RID = -1) constructor {
	self.id = 6
	self.options = {
		connection_state: CONNECTION_STATE.CONNECT
	}
	
	self.rid = RID
	readPacketData = function(buf) {
		self.id = buffer_read_ext(buf)
		self.rid = buffer_read_ext(buf, buffer_vint, undefined, 1)
	}
	writePacketData = function() {
		var buf = buffer_create(2, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_vint, self.rid)
		return buf
	}
	processPacket = function() {
//		var _rbuf = writePacketData()
		exit;
	}
}
ds_map_add(global.packet_registry, 6, CONNECT_CB_PONG_RESPONSE)

/* CONFIGURATION (ID 11-30) */
function CONFIG_CB_PING_RESPONSE() constructor {
	self.id = 11
	self.options = {
		connection_state: CONNECTION_STATE.CONFIGURATION
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
ds_map_add(global.packet_registry, 11, CONFIG_CB_PING_RESPONSE)

/* LOAD_GAME (ID 31-50) */
function CB_LOAD_GAME_STATE(GAME_STATE_ARRAY = [], INTERACTABLES_ARRAY = [], PLAYERS_ARRAY = [], MOBS_ARRAY = [], CLIENT_INFO = [], SERVER_INFO = []) constructor {
	// send over currently connected players, globals, really just a struct
	self.id = 50
	self.options = {
		connection_state: CONNECTION_STATE.LOAD_GAME
	}
	
	self.game_state_array = GAME_STATE_ARRAY
	self.interactables_array = INTERACTABLES_ARRAY
	self.players_array = PLAYERS_ARRAY
	self.mobs_array = MOBS_ARRAY
	self.client_info = CLIENT_INFO
	self.server_info = SERVER_INFO
	
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/CB_LOAD_GAME_STATE/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
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
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_array, self.game_state_array)
		buffer_write_ext(buf, buffer_array, self.interactables_array)
		buffer_write_ext(buf, buffer_array, self.players_array)
		buffer_write_ext(buf, buffer_array, self.mobs_array)
		buffer_write_ext(buf, buffer_array, self.client_info)
		buffer_write_ext(buf, buffer_array, self.server_info)
		packetLog("Wrote Packet. Size is: " + string(buffer_tell(buf)) + " bytes", logInfoType, "writePacketData")
		return buf
	}
	processPacket = function() {
		// apply stuff
		
		// apply client info
		packetLog("Applying Client Info...")
		packetLog("- Client UUID from server is '" + string(self.client_info[0]) + "'")
		obj_multiplayer.client.player.entity_uuid = self.client_info[0]
		packetLog("Applied Client Info!")
		
		// apply server info
		packetLog("Applying Server Info...")
		packetLog("- Server's client USERNAME from server is '" + string(self.server_info[0]) + "'")
		packetLog("- Server's client UUID from server is '" + string(self.server_info[1]) + "'")
		struct_set(obj_multiplayer.network.players, string(self.server_info[0]), string(self.server_info[1]))
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
	
		// apply player array ([ username, uuid, pos, hiding, flash ])
		packetLog("Applying Players Array...")
		var seen_plrs = []
		for (var i = 0; i < array_length(self.players_array); i++) {
			var _plr = self.players_array[i]
			packetLog("- Handling _plr: " + string(_plr))
			
		
			var _u = _plr[0]
			
			if array_contains(seen_plrs, _u) {
				packetLog("-- Skipping duplicate/seen _plr: " + string(_plr), logWarningType)
				continue;
			}
			if (_u == obj_multiplayer.client.player.entity_uuid) {
				packetLog("-- Skipping _plr with our Client's UUID (That's us!)", logWarningType)
				continue;
			}
			array_push(seen_plrs, _u)
			
			var _uuid = _plr[1]
			var _pos = _plr[2]
			var _hiding = _plr[3]
			var _flash = _plr[4]
			
			if (entity_uuid_to_inst(_uuid) == noone) {
				packetLog("-- Player INST doesn't exist. Creating it. (USERNAME: " + string(_u) + ", UUID: " + string(_uuid) + ")")
				var no = instance_create_depth(_pos[0], _pos[2], 0, obj_network_object)
				no.network_obj_type = "player"
				no.entity_uuid = _uuid
				struct_set(obj_multiplayer.network.entities, _uuid, no.id)
				struct_set(obj_multiplayer.network.players, _u, _uuid)
				no.nametag = _u // self.sock
			}
		
			// adjust client version of pkun
			with (entity_uuid_to_inst(_uuid)) {
				other.packetLog("- Applying X, DX, Y, DIR, HIDING, & FLASH")
				x = _pos[0] // -= adjust_to_fps((x - other.pos[0]) / 2);
				array_push(posxq, _pos[0]);
				array_shift(posxq)
				y = _pos[2] //-= adjust_to_fps((y - other.pos[2]) / 2);
				array_push(posyq, _pos[2]);
				array_shift(posyq)
			
				dir = _pos[3]
				dx = (_pos[1] * dir)
				hiding = _hiding
				flashOn = _flash
			}
			packetLog("-- COMPLETED PROCESSING THIS PLAYER (" + string(_u) + ")")
		}
		packetLog("Applied Players Array!")
	
		// apply mobs array ([ uuid, pos, state, obj_index ])
		packetLog("Applying Mobs Array...")
		for (var i = 0; i < array_length(self.mobs_array); i++) {
			var _mob = self.mobs_array[i]
			packetLog("- Handling _mob: " + string(_mob))
			
		
			var _uuid = _mob[0]
			if ((_uuid == "" ) || is_undefined(_uuid)) {
				packetLog("-- Skipping mob, UUID is invalid or empty! (UUID: " + string(_uuid) + ")", logWarningType)
				continue;	
			}
			var _pos = _mob[1]
			var _state = _mob[2]
			var _object_index = real(_mob[3])
			
			if (entity_uuid_to_inst(_uuid) == noone) {
				packetLog("-- Mob INST doesn't exist. Creating it. (OBJECT_NAME: " + string(object_get_name(_object_index)) + ", UUID: " + string(_uuid) + ")")
				var inst = instance_create_depth(_pos[0], _pos[2], -3, _object_index)
				inst.entity_uuid = _uuid
				struct_set(obj_multiplayer.network.entities, inst.entity_uuid, inst.id)
			}
		
			// adjust client version of pkun
			with (entity_uuid_to_inst(_uuid)) {
				other.packetLog("- Applying X, DX, Y, DIR, HIDING, & FLASH")
				x = _pos[0] // -= adjust_to_fps((x - other.pos[0]) / 2);
				y = _pos[2] //-= adjust_to_fps((y - other.pos[2]) / 2);
			
				dir = _pos[3]
				dx = (_pos[1] * dir)
				state = _state
			}
			packetLog("-- COMPLETED PROCESSING THIS MOB (" + string(_uuid) + ")")
		}
		packetLog("Applied Mobs Array!")
	}
}
ds_map_add(global.packet_registry, 50, CB_LOAD_GAME_STATE)

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
		ENTITY_UUID: DATA_TYPE.UUID,
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
	CB_INTERACT: {ENTITY_UUID: DATA_TYPE.UUID, INTERACTOR: DATA_TYPE.UUID}, // Makes client obj interact with object (Ex. other player hiding or picking up item, etc.)
	CB_SET_TIME: { // Set client game clock time
		LEVEL_AGE: DATA_TYPE.LONG,
		CLOCK_HR: DATA_TYPE.BYTE,
		CLOCK_MIN: DATA_TYPE.UBYTE,
		CLOCK_TK: DATA_TYPE.VARINT,
		CLOCK_TK_SPD: DATA_TYPE.FSHORT
	},
	CB_SET_INST_DATA: {ENTITY_UUID: DATA_TYPE.UUID, DATA: DATA_TYPE.PREFIXED_ARRAY_OF_X(STRING, USHORT)}, // Set client object instance data (x, y, dir, doTrack, lostTarget, sprite, etc...) (struct)
	CB_UPDATE_INST_DATA: {}, // Tells client to update object instance data with deltas (like x momentum and stuff) (struct)
	CB_ADD_INST: { // Tells client to add object instance with data
		OBJ_ID: DATA_TYPE.VARINT,
		ENTITY_UUID: DATA_TYPE.UUID,
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
		ENTITY_UUID: DATA_TYPE.UUID,
		SE: DATA_TYPE.VARINT,
		LOOP: DATA_TYPE.VARINT
	},
	CB_STOP_SE: {SE: DATA_TYPE.VARINT}, // stops an se on client if playing
	CB_STOP_ALL_AUDIO: {}, // runs audio_stop_app on a client
}
*/

function PLAY_SB_MOVE_PLAYER_POS(SOCK = -1, X = 0, DX = 0, Y = 0, DIR = 0, HIDING = 0) constructor {
	self.id = 51
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.sock = SOCK
	self.pos = [X, DX, Y, DIR]
	self.hiding = HIDING
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_SB_MOVE_PLAYER_POS/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.pos = buffer_read_ext(buf)
		self.hiding = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_position, self.pos)
		buffer_write_ext(buf, buffer_bool, self.hiding)
		return buf
	}
	processPacket = function() {
		var _username = obj_multiplayer.server.clients[$ string(self.sock)]
//		packetLog("process packet ran from username " + string(_username), "TEST1")
		
		if !is_array(self.pos) {
			packetLog("self.pos IS NOT ARRAY! self.pos = '" + string(self.pos) + "'", logErrorType)	
			exit;
		}

		//if !instance_exists(obj_network_object) {
		if (sock_to_inst(self.sock) == noone) {
			packetLog("Sock to INST is 'noone', creating new INST for sock " + string(self.sock))
			var no = instance_create_depth(self.pos[0], self.pos[2], 0, obj_network_object)
			no.network_obj_type = "player"
			no.entity_uuid = obj_multiplayer.network.players[$ _username]
//			struct_set(obj_multiplayer.network.players, self.sock, no.entity_uuid)
			struct_set(obj_multiplayer.network.entities, no.entity_uuid, no.id)
			no.nametag = _username
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
			if (player_count() > 1) { // only need to replicate changes to other clients if its more than server and 1 client.
//				packetLog("Replicating client changes to other clients! (no.entity_uuid = " + string(entity_uuid) + ")")
				_cb_sync_pkun(entity_uuid, other.pos[0], other.pos[1], other.pos[2], other.pos[3], other.hiding, other.sock)
			}
		}
	}
}
ds_map_add(global.packet_registry, 51, PLAY_SB_MOVE_PLAYER_POS)

function entity_uuid_to_username(uuid) {
	var _entity = entity_uuid_to_inst(uuid)
	return (instance_exists(_entity)) ? _entity.nametag : "unknownEntityUUIDtoUsername??"
}

function PLAY_CB_MOVE_PLAYER_POS(ENTITY_UUID = "", X = 0, DX = 0, Y = 0, DIR = 0, HIDING = 0) constructor {
	self.id = 52
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}	
	
	self.uuid = ENTITY_UUID
	self.pos = [X, DX, Y, DIR] //[X, Y, DIR, TOUCHING_WALL, FLASHLIGHT_ON]
	self.hiding = HIDING
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_CB_MOVE_PLAYER_POS/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.uuid = buffer_read_ext(buf)
		self.pos = buffer_read_ext(buf)
		self.hiding = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_uuid, self.uuid)
		buffer_write_ext(buf, buffer_position, self.pos)
		buffer_write_ext(buf, buffer_bool, self.hiding)
		return buf
	}
	processPacket = function() {
		var _username = entity_uuid_to_username(self.uuid)
		if (self.uuid == "") {
			packetLog("Couldn't create or edit entity with empty uuid!", logWarningType)
			exit;
		}
		
		if (entity_uuid_to_inst(self.uuid) == noone) {
			packetLog("Creating new obj_network_obj with uuid " + string(self.uuid))
			var no = instance_create_depth(self.pos[0], self.pos[2], 0, obj_network_object)
			no.network_obj_type = "player"
			no.entity_uuid = self.uuid
			struct_set(obj_multiplayer.network.entities, self.uuid, no.id)
			no.nametag = _username // self.sock
		}
		
		// adjust client version of pkun
		with (entity_uuid_to_inst(self.uuid)) {
			x = other.pos[0] // -= adjust_to_fps((x - other.pos[0]) / 2);
			array_push(posxq, other.pos[0]);
			array_shift(posxq)
			y = other.pos[2] //-= adjust_to_fps((y - other.pos[2]) / 2);
			array_push(posyq, other.pos[2]);
			array_shift(posyq)
			
			dir = other.pos[3]
			dx = (other.pos[1] * dir)
			hiding = other.hiding
		}
	}
}
ds_map_add(global.packet_registry, 52, PLAY_CB_MOVE_PLAYER_POS)

function PLAY_CB_MOVE_ENTITY_POS(ENTITY_UUID = "", X = 0, DX = 0, Y = 0, DIR = 0, STATE = 0, OBJECT_INDEX = -4) constructor {
	self.id = 53
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.uuid = ENTITY_UUID
	self.pos = [X, DX, Y, DIR] //[X, Y, DIR, TOUCHING_WALL, FLASHLIGHT_ON]
	self.state = STATE
	self.object_index = OBJECT_INDEX
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_CB_MOVE_ENTITY_POS/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.uuid = buffer_read_ext(buf)
		self.pos = buffer_read_ext(buf)
		self.state = buffer_read_ext(buf)
		self.object_index = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_uuid, self.uuid)
		buffer_write_ext(buf, buffer_position, self.pos)
		buffer_write_ext(buf, buffer_vint, self.state)
		buffer_write_ext(buf, buffer_vint, self.object_index)
		return buf
	}
	processPacket = function() {
		if (self.uuid == "") {
			packetLog("Couldn't create or edit entity with empty uuid!", logErrorType)
			exit;
		}
		
		if (entity_uuid_to_inst(self.uuid) == noone) {
			packetLog("Creating new '" + string(object_get_name(self.object_index)) + "' with uuid '" + string(self.uuid) + "'")
			var inst = instance_create_depth(self.pos[0], self.pos[2], -3, self.object_index)
			inst.entity_uuid = self.uuid
			struct_set(obj_multiplayer.network.entities, inst.entity_uuid, inst.id)
		}
	
		// adjust client version of object
		with (entity_uuid_to_inst(self.uuid)) {
			x = other.pos[0] // -= adjust_to_fps((x - other.pos[0]) / 2);
			y = other.pos[2] //-= adjust_to_fps((y - other.pos[2]) / 2);
			
			dir = other.pos[3]
			dx = (other.pos[1] * dir)
			state = other.state
		}
	}
}
ds_map_add(global.packet_registry, 53, PLAY_CB_MOVE_ENTITY_POS)

function PLAY_CB_CREATE_ENTITY(ENTITY_UUID = "", X = 0, DX = 0, Y = 0, DIR = 0, OBJECT_INDEX = -4) constructor {
	self.id = 54
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.uuid = ENTITY_UUID
	self.pos = [X, DX, Y, DIR] //[X, Y, DIR, TOUCHING_WALL, FLASHLIGHT_ON]
	self.object_index = OBJECT_INDEX
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_CB_CREATE_ENTITY/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.uuid = buffer_read_ext(buf)
		self.pos = buffer_read_ext(buf)
		self.object_index = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_uuid, self.uuid)
		buffer_write_ext(buf, buffer_position, self.pos)
		buffer_write_ext(buf, buffer_vint, self.object_index)
		return buf
	}
	processPacket = function() {
		if (self.uuid == "") {
			packetLog("Couldn't create entity with empty uuid!", logErrorType)
			exit;
		}
		
		// remove entity if has same uuid but different obj index
		var _ent = entity_uuid_to_inst(self.uuid)
		if !(_ent == noone) {
			if (_ent[$ "object_index"] != self.object_index) {
				packetLog("Removing pre-existing entity sharing UUID, because it is a different object type.")
				struct_remove(obj_multiplayer.network.entities, self.uuid)
				instance_destroy(_ent)
			}
		}
		
		if (entity_uuid_to_inst(self.uuid) == noone) { // check if entity doesn't exists
			packetLog("Creating new '" + string(object_get_name(self.object_index)) + "' with uuid '" + string(self.uuid) + "'")
			var inst = instance_create_depth(self.pos[0], self.pos[2], -3, self.object_index)
			inst.entity_uuid = self.uuid
			inst.dir = self.pos[3]
			struct_set(obj_multiplayer.network.entities, self.uuid, inst.id)
		}
	}
}
ds_map_add(global.packet_registry, 54, PLAY_CB_CREATE_ENTITY)

function PLAY_CB_CREATE_ENTITIES(ENTITIES = []) constructor {
	self.id = 55
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.entities = ENTITIES // [UUID, X, DX, Y, DIR, OBJ_INDEX]
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_CB_CREATE_ENTITIES/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.entities = buffer_read_ext(buf)
		show_debug_message("PLAY_CB_CREATE_ENTITIES: Read, Entities: " + string(self.entities))
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_array, self.entities)
		return buf
	}
	processPacket = function() {
		if (array_length(self.entities) <= 0) {
			packetLog("Couldn't create entity with empty entities array!", logWarningType)
			exit;
		}
		
		for (var i = 0; i < array_length(self.entities); i++) {
			var _e = self.entities[i]
			packetLog("- Applying entity: " + string(_e))	
			
			if (array_length(_e) < 6) {
				packetLog("-- Couldnt create entity, entity_array doesn't have enough indexes.", logErrorType)	
			}
				
			var _temp_packet = new PLAY_CB_CREATE_ENTITY(_e[0], _e[1], _e[2], _e[3], _e[4], _e[5])
			_temp_packet.processPacket()
		}
	}
}
ds_map_add(global.packet_registry, 55, PLAY_CB_CREATE_ENTITIES)

function PLAY_CB_DESTROY_ENTITY(ENTITY_UUID = "") constructor {
	self.id = 56
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.uuid = ENTITY_UUID
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_CB_DESTROY_ENTITY/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.uuid = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_uuid, self.uuid)
		return buf
	}
	processPacket = function() {
		if (self.uuid == "") {
			packetLog("Couldn't destroy entity with empty uuid!", logErrorType)
			exit;
		}
		
		with (entity_uuid_to_inst(self.uuid)) {
			struct_remove(obj_multiplayer.network.entities, entity_uuid)
			instance_destroy();
		}
	}
}
ds_map_add(global.packet_registry, 56, PLAY_CB_DESTROY_ENTITY)

function PLAY_CB_DESTROY_OBJECT(OBJECT_INDEX = -4) constructor {
	self.id = 57
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.object_index = OBJECT_INDEX
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_CB_DESTROY_OBJECT/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.object_index = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_vint, self.object_index)
		return buf
	}
	processPacket = function() {
		if (self.object_index == -4) {
			packetLog("Couldn't destroy object with empty object index!", logErrorType)
			exit;
		}
		
		with (self.object_index) {
			instance_destroy()
		}
		packetLog("Destroyed all instances of " + string(object_get_name(self.object_index)))
	}
}
ds_map_add(global.packet_registry, 57, PLAY_CB_DESTROY_OBJECT)

//function PLAY_CB_UPDATE_ENTITY_VAR(ENTITY_UUID = "", VAR_AND_VAL_ARRAY = [], OBJECT_INDEX = -4) constructor {
//	self.id = 54
//	self.uuid = ENTITY_UUID
//	self.var_and_val_array = VAR_AND_VAL_ARRAY
////	self.val_array = VAL_ARRAY
//	self.object_index = OBJECT_INDEX
//	readPacketData = function(buf) {
////		buffer_seek(buf, buffer_seek_start, 0)
////		self.id = buffer_read_ext(buf)
////		self.uuid = buffer_read_ext(buf)
////		self.var_and_val_array = buffer_read_ext(buf)
//////		self.val_array = buffer_read_ext(buf)
////		self.object_index = buffer_read_ext(buf)
//		show_debug_message("READING UPDATE ENTITY VAR!")
//	}
//	writePacketData = function() {
//		var buf = buffer_create(32, buffer_grow, 1)
////		buffer_seek(buf, buffer_seek_start, 0)
////		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
//////		buffer_write_ext(buf, buffer_uuid, self.uuid)
//////		buffer_write_ext(buf, buffer_array, self.var_and_val_array)
////////		buffer_write_ext(buf, buffer_array, self.val_array)
//////		buffer_write_ext(buf, buffer_vint, self.object_index)
//		return buf
//	}
//	processPacket = function() {
//		if (self.uuid == "") {
//			show_debug_message("PLAY_CB_UPDATE_ENTITY_VAR: Couldn't create or edit entity with empty uuid!")
//			exit;
//		}
		
//		show_debug_message("YOO! GOT MOB PACKET! MOB IS " + string(object_get_name(self.object_index) + ", ARRAY IS " + string(self.var_and_val_array)))
////		if !(array_length(self.var_array) == array_length(self.val_array)) {
////			show_debug_message("PLAY_CB_UPDATE_ENTITY_VAR: Var and Val arrays are different sizes! Cancelling!")
////			exit;	
////		}
		
//		//if (entity_uuid_to_inst(self.uuid) == noone) {
//		//	var inst = instance_create_depth(self.pos[0], self.pos[2], -3, self.object_index)
//		//	inst.entity_uuid = self.uuid
//		//	struct_set(obj_multiplayer.network.entities, inst.entity_uuid, inst.id)
//		//}
	
//		//// adjust client version of object
//		//with (entity_uuid_to_inst(self.uuid)) {
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
	self.id = 58
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.sock = SOCK
	self.flash = FLASH
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_SB_TOGGLE_FLASHLIGHT/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.flash = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_bool, self.flash)
		return buf
	}
	processPacket = function() {
		// adjust server version of pkun
		with (sock_to_inst(self.sock)) {
			flashOn = other.flash
			play_se(se_flash)
			
			// replicate flashlight event to all other clients
			if (player_count() > 1) {
				_cb_sync_flashlight(entity_uuid, other.flash)
			}
		}
	}
}
ds_map_add(global.packet_registry, 58, PLAY_SB_TOGGLE_FLASHLIGHT)

function PLAY_CB_TOGGLE_FLASHLIGHT(UUID = "", FLASH = 0) constructor {
	self.id = 59
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.uuid = UUID
	self.flash = FLASH
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_CB_TOGGLE_FLASHLIGHT/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.uuid = buffer_read_ext(buf)
		self.flash = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_uuid, self.uuid)
		buffer_write_ext(buf, buffer_bool, self.flash)
		return buf
	}
	processPacket = function() {
		// adjust server version of pkun
		with (entity_uuid_to_inst(self.uuid)) {
			flashOn = other.flash
			play_se(se_flash)
		}
	}
}
ds_map_add(global.packet_registry, 59, PLAY_CB_TOGGLE_FLASHLIGHT)

function PLAY_SB_SET_HSCENE(SOCK = -1, MOB_ID, HS_STP) constructor {
	self.id = 60
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.sock = SOCK
	self.mob_id = MOB_ID
	self.hs_stp = HS_STP
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_SB_SET_HSCENE/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.mob_id = buffer_read_ext(buf)
		self.hs_stp = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_vint, self.mob_id)
		buffer_write_ext(buf, buffer_vint, self.hs_stp)
		return buf
	}
	processPacket = function() {
		// adjust server version of object
		packetLog("Adjusting HSCENE for Sock " + string(self.sock))
		with (sock_to_inst(self.sock)) {
			hs_mob_id = other.mob_id
			hs_stp = other.hs_stp
			
			// replicate update to all client version of source pkuns whatever
			if (player_count() > 1) {
				var _ts = array_without(struct_get_names(obj_multiplayer.server.clients), other.sock) 
				do_packet(new PLAY_CB_SET_HSCENE(entity_uuid, hs_mob_id, hs_stp), _ts)
			}
		}

	}
}
ds_map_add(global.packet_registry, 60, PLAY_SB_SET_HSCENE)

function PLAY_CB_SET_HSCENE(ENTITY_UUID, MOB_ID, HS_STP) constructor {
	self.id = 61
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.uuid = ENTITY_UUID
	self.mob_id = MOB_ID
	self.hs_stp = HS_STP
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_CB_SET_HSCENE/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.uuid = buffer_read_ext(buf)
		self.mob_id = buffer_read_ext(buf)
		self.hs_stp = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_uuid, self.uuid)
		buffer_write_ext(buf, buffer_vint, self.mob_id)
		buffer_write_ext(buf, buffer_vint, self.hs_stp)
		return buf
	}
	processPacket = function() {
		// adjust client version of object
		packetLog("Adjusting HSCENE for UUID " + string(self.uuid))
		with (entity_uuid_to_inst(self.uuid)) {
			hs_mob_id = other.mob_id
			hs_stp = other.hs_stp
		}
	}
}
ds_map_add(global.packet_registry, 61, PLAY_CB_SET_HSCENE)

function PLAY_SB_SET_ENTITY_CONTROL(SOCK = -1, ENTITY_UUID_TO_CONTROL = "", CONTROL = 0) constructor {
	self.id = 62
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.sock = SOCK
	self.uuid = ENTITY_UUID_TO_CONTROL
	self.control = CONTROL
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_SB_SET_ENTITY_CONTROL/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.uuid = buffer_read_ext(buf)
		self.control = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_uuid, self.uuid)
		buffer_write_ext(buf, buffer_bool, self.control)
		return buf
	}
	processPacket = function() {
		// adjust client version of object
		packetLog("Adjusting controller for UUID " + string(self.uuid) + ", controller Sock is " + string(self.sock))
		with (entity_uuid_to_inst(self.uuid)) {
			var _temp = controlled
			controlled = (other.control) ? other.sock : 0 //(other.control) ? other.sock : 0
			other.packetLog("- CONTROLLER WAS " + string(_temp) + ", NOW IS " + string(controlled))
			dx = 0
			exit;
		}
		packetLog("NO ENTITY FOUND FOR UUID " + string(self.uuid) + ", CONTROLLER SOCK IS " + string(self.sock), logErrorType)
	}
}
ds_map_add(global.packet_registry, 62, PLAY_SB_SET_ENTITY_CONTROL)

function PLAY_SB_MOVE_ENTITY_POS(SOCK = -1, ENTITY_UUID = "", X = 0, DX = 0, Y = 0, DIR = 0, STATE = 0) constructor {
	// THIS REQUIRES THAT THE ENTITY HAS CONTROLLER VARIABLE SET TO CLIENT SOCK
	self.id = 63
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.sock = SOCK
	self.uuid = ENTITY_UUID
	self.pos = [X, abs(DX), Y, DIR] //[X, Y, DIR, TOUCHING_WALL, FLASHLIGHT_ON]
	self.state = STATE
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_SB_MOVE_ENTITY_POS/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.uuid = buffer_read_ext(buf)
		self.pos = buffer_read_ext(buf)
		self.state = buffer_read_ext(buf)
		self.object_index = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_uuid, self.uuid)
		buffer_write_ext(buf, buffer_position, self.pos)
		buffer_write_ext(buf, buffer_vint, self.state)
		return buf
	}
	processPacket = function() {
		if (self.uuid == "") {
			packetLog("Couldn't create or edit entity with empty uuid!", logErrorType)
			exit;
		}
		
		if (entity_uuid_to_inst(self.uuid) == noone) {
			packetLog("Couldn't move entity on server from client request, client provided entity_uuid doesn't exist.", logErrorType)
			exit;
		}
	
		// adjust server version of object
		with (entity_uuid_to_inst(self.uuid)) {
			// check if being controlled, and if it is from right sock
			if !(controlled == other.sock) {
				other.packetLog("Illegal attempt from client to move entity '" + string(other.uuid) + "' (offender sock = " + string(other.sock) + ", entity.controlled = " + string(controlled) + ", client provided entity_uuid = " + string(other.uuid) + ")", logWarningType)
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
	self.id = 64
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.sock = SOCK
	self.timestop = TIMESTOP
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_SB_SET_TIME_STOP/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.timestop = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_vint, self.timestop)
		return buf
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
	self.id = 65
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.can_move = CAN_CLIENT_MOVE_IN_TIMESTOP
	self.timestop = TIMESTOP
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_CB_SET_TIME_STOP/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.can_move = buffer_read_ext(buf)
		self.timestop = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_bool, self.can_move)
		buffer_write_ext(buf, buffer_vint, self.timestop)
		return buf
	}
	processPacket = function() {
		// adjust client version of timestop
		global.timeStop = self.timestop
		global.timeStopCanMove = self.can_move
		play_se(se_tiktok)
	}
}
ds_map_add(global.packet_registry, 65, PLAY_CB_SET_TIME_STOP)

function PLAY_SB_INTERACT_AT(SOCK = -1, INTR_TYPE = "", X = 0, Y = 0) constructor {
	self.id = 66
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.sock = SOCK
	self.intr_type = INTR_TYPE
	self.x = X
	self.y = Y
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_SB_INTERACT_AT/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.intr_type = buffer_read_ext(buf)
		self.x = buffer_read_ext(buf)
		self.y = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_string, self.intr_type)
		buffer_write_ext(buf, buffer_vint, self.x)
		buffer_write_ext(buf, buffer_vint, self.y)
		return buf
	}
	processPacket = function() {
		// interact with thing on server side
		var _intr = instance_nearest(self.x, self.y, obj_interactable)
		var _plr = sock_to_inst(self.sock)
		var _hidebox = (self.intr_type == "hidebox")
		
		if (!instance_exists(_intr) && !_hidebox) || !instance_exists(_plr) {
			packetLog("Interacted w/ obj not found or dont exist OR player doesnt exist", logWarningType)
			exit;
		}
		
		with (_plr) {
			if (distance_to_object(_intr) > 50) && !_hidebox {
				other.packetLog("Tried to interact w/ obj that's too far from player!", logWarningType)
				exit;
			}
		}
		
		if !(_hidebox) && (_intr.type != self.intr_type) {
			packetLog("Interacted w/ obj type doesnt match provided intr_type! Cancelling!", logWarningType)
			exit;
		}
		
		switch (self.intr_type) {
			case "portal": {
				packetLog("SOCK " + string(self.sock) + " Interacted w/ portal!")
				play_se_at(_intr.se, _intr.x, _intr.y)
				break;
			}
			case "hidespot": {
				packetLog("SOCK " + string(self.sock) + " Interacted w/ hidespot!")
	            play_se_at(_intr.se_in, _intr.x, _intr.y)
	            _intr.shake = (20)
	            _intr.locked = !_intr.locked
				_intr.passenger = _plr
				_plr.hiding = !_plr.hiding
				_plr.x = _intr.x
				break;
			}
			case "itemspot": {
				packetLog("SOCK " + string(self.sock) + " Interacted w/ itemspot!")
				play_se_at(_intr.se, _intr.x, _intr.y)
				if (_intr.x == self.x) && (_intr.y == self.y) // must be in same exact pos
					instance_destroy(_intr.id)
				break;
			}
			case "figure": {
				packetLog("SOCK " + string(self.sock) + " Interacted w/ figure!")
				packetLog("Figure Interaction Handling is not integrated yet...", logWarningType)
				break;
			}
			case "piano": {
				packetLog("SOCK " + string(self.sock) + " Interacted w/ piano!")
	            play_se(_intr.se, 1)
	            instance_destroy(_intr.id)
				break;
			}
			case "hidebox": {
				packetLog("SOCK " + string(self.sock) + " Interacted w/ hidebox!")
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
		if (player_count > 1) {
			var _t = array_without(struct_get_names(obj_multiplayer.server.clients), self.sock)
			do_packet(new PLAY_CB_INTERACT_AT(_plr.entity_uuid, self.intr_type, self.x, self.y), _t)
		}
	}
}
ds_map_add(global.packet_registry, 66, PLAY_SB_INTERACT_AT)

function PLAY_CB_INTERACT_AT(ENTITY_UUID = "", INTR_TYPE = "", X = 0, Y = 0, AS_TARGET_CLIENT = 0) constructor {
	self.id = 67
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.uuid = ENTITY_UUID
	self.intr_type = INTR_TYPE
	self.x = X
	self.y = Y
	self.as_target_client = AS_TARGET_CLIENT
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_CB_INTERACT_AT/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.uuid = buffer_read_ext(buf)
		self.intr_type = buffer_read_ext(buf)
		self.x = buffer_read_ext(buf)
		self.y = buffer_read_ext(buf)
		self.as_target_client = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_uuid, self.uuid)
		buffer_write_ext(buf, buffer_string, self.intr_type)
		buffer_write_ext(buf, buffer_vint, self.x)
		buffer_write_ext(buf, buffer_vint, self.y)
		buffer_write_ext(buf, buffer_bool, self.as_target_client)
		return buf
	}
	processPacket = function() {
		// interact with thing on client side
		var _intr = instance_nearest(self.x, self.y, obj_interactable)
		var _plr = (self.as_target_client) ? obj_pkun : entity_uuid_to_inst(self.uuid)
		var _hidebox = (self.intr_type == "hidebox")
		
		if (!instance_exists(_intr) && !_hidebox) || !instance_exists(_plr) {
			packetLog("Interacted w/ obj not found or dont exist OR player doesnt exist", logWarningType)
			exit;
		}
		
		with (_plr) {
			if (distance_to_object(_intr) > 50) && !_hidebox	 {
				other.packetLog("Tried to interact w/ obj that's too far from player!", logWarningType)
				exit;
			}
		}
		
		if !(_hidebox) && (_intr.type != self.intr_type) {
			packetLog("Interacted w/ obj type doesnt match provided intr_type! Cancelling!")
			exit;
		}
		
		switch (self.intr_type) {
			case "portal": {
				packetLog("UUID " + string(self.uuid) + " Interacted w/ portal!")
				play_se_at(_intr.se, _intr.x, _intr.y)
				break;
			}
			case "hidespot": {
				packetLog("UUID " + string(self.uuid) + " Interacted w/ hidespot!")
	            play_se_at(_intr.se_in, _intr.x, _intr.y)
	            _intr.shake = (20)
				_intr.locked = !_intr.locked
				_plr.hiding = !_plr.hiding
				_plr.x = _intr.x
				break;
			}
			case "itemspot": {
				packetLog("UUID " + string(self.uuid) + " Interacted w/ itemspot!")
				play_se_at(_intr.se, _intr.x, _intr.y)
				if (_intr.x == self.x) && (_intr.y == self.y) // must be in same exact pos
					instance_destroy(_intr.id)
				break;
			}
			case "figure": {
				packetLog("UUID " + string(self.uuid) + " Interacted w/ figure!")
				packetLog("Figure Interaction Handling is not integrated yet...")
				break;
			}
			case "piano": {
				packetLog("UUID " + string(self.uuid) + " Interacted w/ piano!")
	            play_se(_intr.se, 1)
	            instance_destroy(_intr.id)
				break;
			}
			case "hidebox": {
				packetLog("UUID " + string(self.uuid) + " Interacted w/ hidebox!")
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
	self.id = 68
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.sock = SOCK
	self.mini_msg = MINI_MSG
	self.mini_tmr = MINI_TMR
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_SB_SYNC_MINI_MSG/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.mini_msg = buffer_read_ext(buf)
		self.mini_tmr = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_string, self.mini_msg)
		buffer_write_ext(buf, buffer_vint, self.mini_tmr)
		return buf
	}
	processPacket = function() {
		// adjust server version of object
		with (sock_to_inst(self.sock)) {
			miniMsgStr = other.mini_msg
			miniMsgTmr = other.mini_tmr
			other.packetLog("Updated mini msg for sock " + string(other.sock) + ", mini_msg = " + string(other.mini_msg) + ", mini_tmr = " + string(other.mini_tmr))
			
			// replicate to other clients
			var _t = array_without(struct_get_names(obj_multiplayer.server.clients), other.sock)
			do_packet(new PLAY_CB_SYNC_MINI_MSG(entity_uuid, other.mini_msg, other.mini_tmr), _t)
		}
	}
}
ds_map_add(global.packet_registry, 68, PLAY_SB_SYNC_MINI_MSG)

function PLAY_CB_SYNC_MINI_MSG(ENTITY_UUID = "", MINI_MSG = "", MINI_TMR = 0) constructor {
	self.id = 69
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.uuid = ENTITY_UUID
	self.mini_msg = MINI_MSG
	self.mini_tmr = MINI_TMR
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_CB_SYNC_MINI_MSG/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.uuid = buffer_read_ext(buf)
		self.mini_msg = buffer_read_ext(buf)
		self.mini_tmr = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_uuid, self.uuid)
		buffer_write_ext(buf, buffer_string, self.mini_msg)
		buffer_write_ext(buf, buffer_vint, self.mini_tmr)
		return buf
	}
	processPacket = function() {
		// adjust server version of object
		with (entity_uuid_to_inst(self.uuid)) {
			miniMsgStr = other.mini_msg
			miniMsgTmr = other.mini_tmr
			other.packetLog("Updated mini msg for uuid " + string(other.uuid) + ", mini_msg = " + string(other.mini_msg) + ", mini_tmr = " + string(other.mini_tmr))
		}
	}
}
ds_map_add(global.packet_registry, 69, PLAY_CB_SYNC_MINI_MSG)

function PLAY_SB_DISCONNECT(SOCK = -1, REASON = "notProvided") constructor {
	self.id = 70
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.sock = SOCK
	self.reason = REASON
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_SB_DISCONNECT/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.reason = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_string, self.reason)
		return buf
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
	self.id = 71
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.reason = REASON
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_CB_DISCONNECT/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.reason = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_string, self.reason)
		return buf
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
//	self.id = 72
//	self.sock = SOCK
//	self.mini_msg = MINI_MSG
//	self.mini_tmr = MINI_TMR
//	readPacketData = function(buf) {
//		buffer_seek(buf, buffer_seek_start, 0)
//		self.id = buffer_read_ext(buf)
//		self.mini_msg = buffer_read_ext(buf)
//		self.mini_tmr = buffer_read_ext(buf)
//	}
//	writePacketData = function() {
//		var buf = buffer_create(1, buffer_grow, 1)
//		buffer_seek(buf, buffer_seek_start, 0)
//		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
//		buffer_write_ext(buf, buffer_string, self.mini_msg)
//		buffer_write_ext(buf, buffer_vint, self.mini_tmr)
//		return buf
//	}
//	processPacket = function() {
//		// adjust server version of object
//		with (sock_to_inst(self.sock)) {
//			miniMsgStr = other.mini_msg
//			miniMsgTmr = other.mini_tmr
//			show_debug_message("PLAY_SB_SYNC_MINI_MSG: Updated mini msg for sock " + string(other.sock) + ", mini_msg = " + string(other.mini_msg) + ", mini_tmr = " + string(other.mini_tmr))
			
//			// replicate to other clients
//			var _t = array_without(struct_get_names(obj_multiplayer.server.clients), other.sock)
//			do_packet(new PLAY_CB_SYNC_MINI_MSG(entity_uuid, other.mini_msg, other.mini_tmr), _t)
//		}
//	}
//}
//ds_map_add(global.packet_registry, 72, PLAY_SB_SYNC_MINI_MSG)

function PLAY_CB_SET_PKUN_MINI_MSG(MINI_MSG = "", MINI_TMR = 0) constructor {
	self.id = 73
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.mini_msg = MINI_MSG
	self.mini_tmr = MINI_TMR
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_CB_SET_PKUN_MINI_MSG/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.mini_msg = buffer_read_ext(buf)
		self.mini_tmr = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_string, self.mini_msg)
		buffer_write_ext(buf, buffer_vint, self.mini_tmr)
		return buf
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

function PLAY_SB_UPDATE_USERNAME(SOCK = -1, NEW_USERNAME = "unsetNewUsername") constructor {
	self.id = 74
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.sock = SOCK
	self.username = NEW_USERNAME
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_SB_UPDATE_USERNAME/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.username = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_string, self.username)
		return buf
	}
	processPacket = function() {
		// adjust server version of object
		var _old_username = obj_multiplayer.server.clients[$ self.sock]
		var _uuid = obj_multiplayer.network.players[$ _old_username]
		
		packetLog("Changing username '" + string(_old_username) + "' to '" + string(self.username) + "' (UUID: '" + string(_uuid) + "')")
		
		struct_set(obj_multiplayer.server.clients, self.sock, self.username)
		struct_remove(obj_multiplayer.network.players, _old_username) // clear old uuid
		struct_set(obj_multiplayer.network.players, self.username, _uuid)
	
		with (username_to_inst(self.username)) {
			if (nametag == _old_username) // change it if it was old username
				nametag = other.username	
		}
	
		do_packet(new PLAY_CB_UPDATE_USERNAME(_old_username, self.username), array_without(struct_get_names(obj_multiplayer.server.clients), self.sock))
	}
}
ds_map_add(global.packet_registry, 74, PLAY_SB_UPDATE_USERNAME)

function PLAY_CB_UPDATE_USERNAME(OLD_USERNAME, NEW_USERNAME = "unsetNewUsername") constructor {
	self.id = 75
	self.options = {
		connection_state: CONNECTION_STATE.PLAY
	}
	
	self.old_username = OLD_USERNAME
	self.username = NEW_USERNAME
	packetLog = function(msg, type = logInfoType, packet_func = "processPacket") {log(msg, type, "PKT/PLAY_CB_UPDATE_USERNAME/" + string(packet_func))}
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.old_username = buffer_read_ext(buf)
		self.username = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_string, self.old_username)
		buffer_write_ext(buf, buffer_string, self.username)
		return buf
	}
	processPacket = function() {
		// adjust server version of object
		var _uuid = obj_multiplayer.network.players[$ self.old_username]
		
		packetLog("Changing username '" + string(self.old_username) + "' to '" + string(self.username) + "' (UUID: '" + string(_uuid) + "')")
		
		struct_remove(obj_multiplayer.network.players, self.old_username) // clear old uuid
		struct_set(obj_multiplayer.network.players, self.username, _uuid)
		
		with (username_to_inst(self.username)) {
			if (nametag == other.old_username) // change it if it was old username
				nametag = other.username	
		}
	}
}
ds_map_add(global.packet_registry, 75, PLAY_CB_UPDATE_USERNAME)





/// @function do_packet
/// @description Constructs and sends a packet. Argument1 is packet_id, rest of arguments are packet data (packet args for packet constructor)
function do_packet(pkt, target_socks) {
	var pktbuf = pkt.writePacketData()
	multiplayer_send_packet(target_socks, pktbuf)
	buffer_delete(pktbuf)
}

// packet sending functions
function sync_pkun_event() {
	exit;
	
	var __log = function(msg, type = logInfoType) {log(msg, type, "FUNC/sync_pkun_event")}
	if !is_multiplayer()
		exit;
	
	if (check_is_server() || (obj_multiplayer.network.server.connection < 0) || !instance_exists(obj_pkun) || room = rm_intro || room = rm_title) {
		if check_is_server() {
			// redirect if server? update clients?
			_cb_sync_pkun()
		}
		exit; // only run as client and if we have moved
	}
	
	var tX = obj_pkun.x
	var tDX = (global.menu_mode = 1) ? 0 : obj_pkun.move_speed
	var tY = obj_pkun.y
	var tDIR = obj_pkun.dir
	var last_pos = global.multiplayer_pkun_sync_hist
	
	if (last_pos[0] == tX) && (last_pos[1] == tY) && (last_pos[2] == tDIR) {
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

	do_packet(new PLAY_SB_MOVE_PLAYER_POS(-1, tX, tDX, tY, tDIR), obj_multiplayer.network.server.connection) //, tTW, tFO)
	
	obj_pkun.last_move_speed = obj_pkun.move_speed
	__log("Sent Pkun Sync Packet")
}

/// @function _cb_sync_pkun
/// @param {string} uuid Entity UUID of pkun/network object
/// @param {number} tx X position
/// @param {number} tdx MoveSpeed (pkun is 4 for walking, 12 for running)
/// @param {number} ty Y position
/// @param {number} tdir DIR
/// @param {number} src_sock Source sock
/// @description Sends pkun sync packet to all clients. Leave params blank and it will send server's own pkun update packet.
function _cb_sync_pkun(uuid = "", tx = -4, tdx = -4, ty = -4, tdir = -4, thiding = -4, src_sock = -1) {
	var __log = function(msg, type = logInfoType) {log(msg, type, "FUNC/_cb_sync_pkun")}
	if (!check_is_server() || !instance_exists(obj_pkun) || room = rm_intro || room = rm_title) {
		exit; // only run as server and if we have moved
	}
	
	var provided_uuid = !(uuid == "")
	
	var entityUUID = provided_uuid ? uuid : obj_multiplayer.server.player.entity_uuid; 
	var tX = provided_uuid ? tx : obj_pkun.x
	var tDX = provided_uuid ? tdx : obj_pkun.move_speed
	var tY = provided_uuid ? ty : obj_pkun.y
	var tDIR = provided_uuid ? tdir : obj_pkun.dir
	var tHIDING = provided_uuid ? thiding : obj_pkun.hiding
	var last_pos = global.multiplayer_pkun_sync_hist
	
	if (!provided_uuid) {
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
	do_packet(new PLAY_CB_MOVE_PLAYER_POS(entityUUID, tX, tDX, tY, tDIR, tHIDING), target_socks) //, tTW, tFO)
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
			_cb_sync_flashlight(obj_multiplayer.server.player.entity_uuid, global.flashOn)
		}
		exit; // only run as client
	}
		
	do_packet(new PLAY_SB_TOGGLE_FLASHLIGHT(-1, global.flashOn), obj_multiplayer.network.server.connection)
}

function _cb_sync_flashlight(source_sock_or_uuid, flash) {
	if (!check_is_server()) {
		exit; // only run as server
	}

	source_sock_or_uuid = string(source_sock_or_uuid)
	var uuid = (string_length(source_sock_or_uuid) == 36) ? source_sock_or_uuid : obj_multiplayer.network.players[$ obj_multiplayer.server.clients[$ source_sock_or_uuid]]
	var target_socks = array_without(struct_get_names(obj_multiplayer.server.clients), source_sock_or_uuid)
	do_packet(new PLAY_CB_TOGGLE_FLASHLIGHT(uuid, flash), target_socks)
}

function _cb_sync_mobs() {
	with (obj_p_mob) {
		_cb_sync_mob()
	}	
}

function _cb_sync_mob() {
	var hist = global.multiplayer_entity_sync_hist
	
	if (((controlled == 0) && (!check_is_server())) || room = rm_intro || room = rm_title) {
//		show_debug_message("_cb_sync_mob: Didn't send since is client or in wrong room.")
		exit; // only run as server and not in title or anything
	}
	if (is_undefined(self[$ "entity_uuid"]) || is_undefined(self[$ "dir"])) {
		exit;
	}
	if is_undefined(hist[$ entity_uuid]) && (entity_uuid != "" ){
		struct_set(hist, entity_uuid, [-4, 0, -4, 1, 0, 0])	
	}
	
//	show_debug_message("CB_SYNC_MOB INSIDE INSTANCE " + string(id))
	if !is_array(hist[$ entity_uuid])
		exit;
	var last_x = hist[$ entity_uuid][0]
	var last_dx = hist[$ entity_uuid][1]
	var last_y = hist[$ entity_uuid][2]
	var last_dir = hist[$ entity_uuid][3]
	var last_state = hist[$ entity_uuid][4]
	var check = hist[$ entity_uuid][5]
	
	var msg = ""
	
	// x doesnt matter here since we apply dx and stuff, we will sync x on packet updates regardless
	if (last_state == state) && (last_y == y) && (last_dir == dir) && (last_dx == dx) {
		if !(last_state == state)
			msg+= "\nState Changed"
		if !(last_y == y)
			msg+= "\nY Changed"
		if !(last_dir == dir)
			msg+= "\nDIR Changed"
		if !(last_dx == dx)
			msg+= "\nDX Changed"
			
//		show_debug_message("_cb_sync_mob (mob: " + string(object_get_name(object_index)) + "), differences:" + msg)
		
		if check { // we did do the last update
//			show_debug_message("SKIPPING MOB UPDATE, ALREADY SENT LAST UPDATE PACKET (" + string(object_get_name(object_index)) + ")")
			exit;
		} else {
//			show_debug_message("SENDING LAST MOB UPDATE PACKET, DIDNT MOVE THO (" + string(object_get_name(object_index)) + ")")
			check = 1
		}
	} else {
		check = 0 // pos changed	
	}
	
	struct_set(global.multiplayer_entity_sync_hist, entity_uuid, [x, dx, y, dir, state, check])	
	self.last_move_speed = self.move_speed
	
	if check_is_server() {
//		show_debug_message("SENDING MOB POS UPDATE PACKET (SERVER TO CLIENT) (" + string(object_get_name(object_index)) + ")")
		var target_socks = struct_get_names(obj_multiplayer.server.clients)
		if !(controlled == 0) // dont send it to controller, causes issues
			target_socks = array_without(target_socks, controlled)
		do_packet(new PLAY_CB_MOVE_ENTITY_POS(entity_uuid, x, abs(dx), y, dir, state, object_index), target_socks)
	} else {
//		show_debug_message("SENDING MOB POS UPDATE PACKET (CLIENT TO SERVER) (" + string(object_get_name(object_index)) + ")")
		do_packet(new PLAY_SB_MOVE_ENTITY_POS(-1, entity_uuid, x, abs(dx), y, dir, state), obj_multiplayer.network.server.connection)	
	}
	_pcnt++
}

function sync_hscene_event() {
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
		do_packet(new PLAY_CB_SET_HSCENE(obj_multiplayer.server.player.entity_uuid, obj_pkun.hs_mob_id, obj_pkun.hs_stp), target_socks)
	} else {
		do_packet(new PLAY_SB_SET_HSCENE(-1, obj_pkun.hs_mob_id, obj_pkun.hs_stp), obj_multiplayer.network.server.connection)
	}
}

function _cb_create_entity(UUID, X, DX, Y, DIR, OBJ_INDEX) {
	if (!check_is_server()) { // || (player_count() <= 1) || (instance_number(obj_p_syncable) == 0) {
		exit; // only run as server
	}
	
	show_debug_message("_cb_create_entity " + string(object_get_name(OBJ_INDEX)) + " (" + string(UUID) + ")")
	
	if !struct_exists(obj_multiplayer.network.entities, UUID) {
		show_debug_message("_cb_create_entity " + string(object_get_name(OBJ_INDEX)) + " (" + string(UUID) + ") FAILED! UUID doesnt exist in serverside network.entities!")
		exit;
	}
	
	var target_socks = struct_get_names(obj_multiplayer.server.clients)
	do_packet(new PLAY_CB_CREATE_ENTITY(entity_uuid, x, dx, y, dir, object_index) , target_socks)
}

function _cb_destroy_entity(UUID) {
	if (!check_is_server()) { // || (player_count() <= 1) || (instance_number(obj_p_syncable) == 0) {
		exit; // only run as server
	}
	
	show_debug_message("_cb_destroy_entity (" + string(UUID) + ")")
	do_packet(new PLAY_CB_DESTROY_ENTITY(entity_uuid), struct_get_names(obj_multiplayer.server.clients))
}

function _cb_destroy_object(object_index) {
	if (!check_is_server()) { // || (player_count() <= 1) || (instance_number(obj_p_syncable) == 0) {
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
		show_debug_message("RUNNING INTERACT MULTIPLAYER EVENT, INTRTYPE IS " + string(_intr_type))
		if check_is_server() {
			do_packet(new PLAY_CB_INTERACT_AT(obj_multiplayer.server.player.entity_uuid, _intr_type, intrTarget.x, intrTarget.y, 0), struct_get_names(obj_multiplayer.server.clients))	
		} else {
			do_packet(new PLAY_SB_INTERACT_AT(-1, _intr_type, intrTarget.x, intrTarget.y), obj_multiplayer.network.server.connection)	
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
		do_packet(new PLAY_CB_SYNC_MINI_MSG(obj_multiplayer.server.player.entity_uuid, miniMsgStr, miniMsgTmr), struct_get_names(obj_multiplayer.server.clients))	
	} else {
		do_packet(new PLAY_SB_SYNC_MINI_MSG(-1, miniMsgStr, miniMsgTmr), obj_multiplayer.network.server.connection)	
	}
}

function generate_game_state_packet(sock) {
	var __log = function(msg, type = logInfoType) {log(msg, type, "FUNC/generate_game_state_packet")}
	__log("Starting Game State Packet Generation... (For sock " + string(sock) + ")")
	var GSA = [] // game state array
	var IA = [] // interactables array
	var PA = [] // players array
	var MA = [] // mobs array
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
	
	// generate player array ([ username, uuid, pos, hiding, flash ])
	__log("Generating Players Array...")
	var _clients = struct_get_names(obj_multiplayer.server.clients)
	var _network_objs = obj_multiplayer.network.entities
	for (var i = 0; i < array_length(_clients); i++) {
		var __client = _clients[i]
		if (__client == string(sock))
			continue;
		var _inst = []
		var _u = "unsetUsername_GGSA_" + string(__client)
		var _uuid = obj_multiplayer.network.players[$ __client]
		var _pos = [-4, 0, -4, 1]
		var _hiding = 0
		var _flash = 0
		with (sock_to_inst(__client)) {
			_u = nametag
			_uuid = entity_uuid		
			_pos = [x, dx, y, dir]
			_hiding = hiding
			_flash = flashOn
		}
		
		array_push(_inst, _u)
		array_push(_inst, _uuid)
		array_push(_inst, _pos)
		array_push(_inst, _hiding)
		array_push(_inst, _flash)
		array_push(PA, _inst)
	}
		// add server pkun
	var _inst = []
	array_push(_inst, obj_multiplayer.server.player.username)
	array_push(_inst, obj_multiplayer.server.player.entity_uuid)
	array_push(_inst, [obj_pkun.x, obj_pkun.dx, obj_pkun.y, obj_pkun.dir])
	array_push(_inst, obj_pkun.hiding)
	array_push(_inst, global.flashOn)
	array_push(PA, _inst)
	__log("Generated Players Array! PA: " + string(PA))
	
	// generate mobs array ([ uuid, pos, state, obj_index ])
	__log("Generating Mobs Array...")
	with (obj_p_mob) {
		var _inst = []
		array_push(_inst, variable_instance_exists(id, "entity_uuid") ? entity_uuid : "")
		array_push(_inst, [x, variable_instance_exists(id, "dx") ? dx : 0, y, dir])
		array_push(_inst, variable_instance_exists(id, "state") ? state : 0)
		array_push(_inst, object_index)
		array_push(MA, _inst)
	}
	__log("Generated Mobs Array! MA: " + string(MA))
	
	// generate client info
	__log("Generating Client Info...")
	array_push(CI, obj_multiplayer.network.players[$ obj_multiplayer.server.clients[$ string(sock)]])
	__log("Generated Client Info! CI: " + string(CI))
	
	// generate server info
	__log("Generating Server Info...")
	array_push(SI, obj_multiplayer.server.player.username) // server's client username
	array_push(SI, obj_multiplayer.server.player.entity_uuid) // server's client uuid
	__log("Generated Server Info! SI: " + string(CI))
	
	return new CB_LOAD_GAME_STATE(GSA, IA, PA, MA, CI, SI)
}