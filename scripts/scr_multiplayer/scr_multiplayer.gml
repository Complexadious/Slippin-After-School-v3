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

function start_server() {
	var __log = function(msg, type = "INFO") {log(msg, type, "FUNC/start_server")}
	
	if !instance_exists(obj_multiplayer) {
		instance_create_depth(0, 0, 999, obj_multiplayer)
		__log("Created 'obj_multiplayer' instance since it didn't exist.")
	}
	
	with (obj_multiplayer) {
		if (network.server.socket > 0) {
			__log("Tried to start already running server. NETWORK_SOCKET_ID: " + string(network.server.socket), "WARNING")	
		}
		
		// Create server
		network.server.socket = network_create_server(network_socket_tcp, SERVER_PORT, MAX_CLIENTS)
		network.server.connected = 1
		network.role = NETWORK_ROLE.SERVER
		network.connection_state = CONNECTION_STATE.HOSTING
		struct_set(network.statistics, "network_server_created_at", current_time)
		_log("Created server! NETWORK_SOCKET_ID: " + string(network.server.socket))
	}
}

function join_server(username = "TESTUSER", ip = "127.0.0.1", port = SERVER_PORT) {
	var _log = function(msg, type = "INFO") {log(msg, type, "FUNC/join_server")}
	
	_log("Starting join process for server '" + string(ip) + ":" + string(port) + "'")
	
	with (obj_multiplayer) {
		network.server.socket = network_create_socket(network_socket_tcp)
		network.server.connection = network_connect(network.server.socket, ip, port)
		_log("Awaiting confirmation from server...")
	}
}

function close_server() {
	var __log = function(msg, type = "INFO") {log(msg, type, "FUNC/start_server")}
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
			
			_log("Server is closed. (Socket destroyed!)")
			instance_destroy();
		}
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

function parse_multiplayer_packet(packet_type, state, buffer) {
	var _data = {}
	with (obj_multiplayer) {
		// state exists
		if !variable_instance_exists(id, state)
			exit;
		// packet type exists
		if !struct_exists(state, packet_type)
			exit;
			
		var _loc = self[$ state][$ packet_type]
		var _packet_args = struct_get_names(_loc)
	
		for (var i = 0; i < array_length(_packet_args); i++) {
			var _pa = _packet_args[i]
			var _dt = _loc[$ _pa]
			struct_set(_data, _pa, parse_multiplayer_data_type(buffer, _dt))
		}
	}
	return _data
}

function multiplayer_send_packet(sockets, buffer) {
	for (var i = 0; i < array_length(sockets); i++)
		network_send_packet(sockets[i], buffer, buffer_get_size(buffer))
}

function multiplayer_handle_packet(sock, buffer) {
	buffer_seek(buffer, buffer_seek_relative, 0)
	var packet_id = buffer_read(buffer, buffer_u8)
	var packet_name;
	
	switch (obj_multiplayer.network.connection_state) {
		case (CONNECTION_STATE.OFFLINE): {
			break;	
		}
		case (CONNECTION_STATE.CONNECT): {
			if (obj_multiplayer.network.role == NETWORK_ROLE.CLIENT) {
				// Recieved packet, server is legit!
				obj_multiplayer.network.connection_state++
			} else {
				// Recieved ping request, send in the pong!
				
			}
			break;	
		}
		case (CONNECTION_STATE.CONFIGURATION): {
			break;	
		}
		case (CONNECTION_STATE.LOAD_GAME): {
			break;	
		}		
		case (CONNECTION_STATE.PLAY): {
			break;	
		}
		case (CONNECTION_STATE.HOSTING): {
			break;	
		}
	}
}

////
//// PACKETS
////

global.packet_registry = ds_map_create()

/* base */
function BASE_PACKET(_id = -1) constructor {
	self.id = _id
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

/* CONNECT (ID 50-100) */
function CONNECT_SB_PING_REQUEST(RID) constructor {
	self.id = 50
	self.rid = RID
	readPacketData = function(buf) {
		self.id = buffer_read_ext(buf, buffer_vint)
		self.rid = buffer_read_ext(buf, buffer_vint, undefined, 1)
	}
	writePacketData = function() {
		var buf = buffer_create(2, buffer_fixed, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, buffer_vint, self.id)
		buffer_write_ext(buf, buffer_vint, self.rid)
		return buf
	}
	processPacket = function() {
//		var _rbuf = writePacketData()
	}
}
ds_map_add(global.packet_registry, 50, CONNECT_SB_PING_REQUEST)

function CONNECT_CB_PONG_RESPONSE(RID) constructor {
	self.id = 51
	self.rid = RID
	readPacketData = function(buf) {
		self.id = buffer_read_ext(buf, buffer_vint)
		self.rid = buffer_read_ext(buf, buffer_vint, undefined, 1)
	}
	writePacketData = function() {
		var buf = buffer_create(2, buffer_fixed, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, buffer_vint, self.id)
		buffer_write_ext(buf, buffer_vint, self.rid)
		return buf
	}
	processPacket = function() {
//		var _rbuf = writePacketData()
	}
}
ds_map_add(global.packet_registry, 51, CONNECT_CB_PONG_RESPONSE)

/* CONFIGURATION (ID 101-200) */
function CONFIG_CB_PING_RESPONSE() constructor {
	self.id = 101
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
ds_map_add(global.packet_registry, 101, CONFIG_CB_PING_RESPONSE)

/* LOAD_GAME (ID 201-300) */
function LOADGAME_SB_PING_REQUEST() constructor {
	self.id = 201
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
ds_map_add(global.packet_registry, 201, LOADGAME_SB_PING_REQUEST)

/* PLAY (ID 301-400) */
function PLAY_SB_MOVE_PLAYER_POS(X, Y, DIR, TOUCHING_WALL) constructor {
	self.id = 301
	self.pos = [X, Y, DIR, TOUCHING_WALL]
	readPacketData = function(buf) {
		self.id = buffer_read_ext(buf, buffer_vint)
		self.pos = buffer_read_ext(buf, buffer_position, undefined, 1)
	}
	writePacketData = function() {
		var buf = buffer_create(5, buffer_fixed, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, buffer_vint, self.id)
		buffer_write_ext(buf, buffer_position, self.pos)
		return buf
	}
	processPacket = function() {
		if !instance_exists(obj_network_object) {
			instance_create_depth(self.pos[0], self.pos[1], 0, obj_network_object)
		}
		with (obj_network_object) {
			network_obj_type = "player"
			dir = self.pos[2]
		}
	}
}
ds_map_add(global.packet_registry, 301, PLAY_SB_MOVE_PLAYER_POS)