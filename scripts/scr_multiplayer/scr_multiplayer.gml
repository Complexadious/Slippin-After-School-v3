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
	
	if !instance_exists(obj_multiplayer) {
		instance_create_depth(0, 0, 999, obj_multiplayer)
		_log("Created 'obj_multiplayer' instance since it didn't exist.")
	}
	
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
	if !is_array(sockets) sockets = [sockets]
	for (var i = 0; i < array_length(sockets); i++) {
		network_send_packet(real(sockets[i]), buffer, buffer_get_size(buffer))
		global.multiplayer_packets_sent++
//		show_debug_message("multiplayer_send_packet: Sent packet out! (" + string(sockets[i]) + ")")
	}
}

function multiplayer_handle_packet(sock, buffer) {
	buffer_seek(buffer, buffer_seek_relative, 0)
	var packet_id = buffer_read_ext(buffer)
	buffer_seek(buffer, buffer_seek_relative, 0)
	
	var pkt = undefined
	
	if ds_map_exists(global.packet_registry, packet_id) {
//		show_debug_message("*** PACKET ID IS FOUND IN REGISTRY!!")	
		pkt = new global.packet_registry[? packet_id](sock)
		pkt.readPacketData(buffer)
		pkt.processPacket()
	} else {
		show_debug_message("*** PACKET ID (" + string(sock) + ") IS NOT FOUND IN REGISTRY!!")	
	}

/*	
	switch (obj_multiplayer.network.connection_state) {
		case (CONNECTION_STATE.OFFLINE): {
			break;
		}
		case (CONNECTION_STATE.CONNECT): {
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
*/
}

function entity_uuid_to_inst(uuid) {
	if !is_multiplayer()
		return noone

	if !is_undefined(obj_multiplayer.network.network_objects[$ uuid])
		return obj_multiplayer.network.network_objects[$ uuid]
	
	with (obj_network_object) {
		if (entity_uuid == uuid) {
			struct_set(obj_multiplayer.network.network_objects, uuid, id)
			return id	
		}
	}
	
	return noone
}

function sock_to_inst(sock) {
	sock = string(sock)
	return (obj_multiplayer.network.network_objects[$ obj_multiplayer.network.players[$ sock]])
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

function player_count() {
	if check_is_server()
		return struct_names_count(obj_multiplayer.server.clients)
	else if is_multiplayer()
		return struct_names_count(obj_multiplayer.network.network_objects)
	return 0
}

function entity(UUID, X, DX, Y, DIR, OBJECT_INDEX) constructor {
	entity_uuid = UUID
	x = X
	dx = DX
	y = Y
	dir = DIR
	object_index = OBJECT_INDEX
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
function CB_LOAD_GAME_STATE(game_state_array = [], players_array = [], mobs_array = []) constructor {
	// send over currently connected players, globals, really just a struct
	
	/* layout: 1. GAME_STATE (globals) 2. PLAYERS (array) 3. OTHER
	GAME_STATE:
	[
		global_var_name, value
	]
	
	PLAYERS:
	[
		uuid, position
	]
	
	MOBS:
	[
		uuid, object_index, position, 
	]
	*/

	self.id = 50
	self.game_state_array = game_state_array
	self.players_array = players_array
	self.mobs_array = mobs_array
	
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.game_state_array = game_state_array
		self.players_array = players_array
		self.mobs_array = mobs_array
//		show_debug_message("PLAY_SB_MOVE_PLAYER_POS: READ: POS = " + string(self.pos))
	}
	writePacketData = function() {
		var buf = buffer_create(32, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_array, self.game_state_array)
		buffer_write_ext(buf, buffer_array, self.players_array)
		buffer_write_ext(buf, buffer_array, self.mobs_array)
		return buf
	}
	processPacket = function() {
		//if !instance_exists(obj_network_object) {
		if is_undefined(sock_to_inst(self.sock)) {
			var no = instance_create_depth(self.pos[0], self.pos[1], 0, obj_network_object)
			no.network_obj_type = "player"
			struct_set(obj_multiplayer.network.players, self.sock, no.entity_uuid)
			no.nametag = self.sock
		}
		
		// adjust server version of pkun
		with (sock_to_inst(self.sock)) {
			x -= adjust_to_fps((x - other.pos[0]) / 2);
			array_push(posxq, other.pos[0]);
			array_shift(posxq)
			
			y -= adjust_to_fps((y - other.pos[1]) / 2);
			array_push(posyq, other.pos[1]);
			array_shift(posyq)
			
			// make the flashOn an array, so we can cycle the stuff, if indexes arent the same, it changed.
			array_push(flashOn, other.pos[4]);
			array_shift(flashOn)
			
			dx = (posxq[1] - posxq[0]) / (60 / (obj_multiplayer.client.settings.game.tick_rate))
			dy = (posyq[1] - posyq[0]) / (60 / (obj_multiplayer.client.settings.game.tick_rate))
			
			dir = other.pos[2]
		}
	}
}
ds_map_add(global.packet_registry, 50, PLAY_SB_MOVE_PLAYER_POS)

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

function PLAY_SB_MOVE_PLAYER_POS(SOCK = -1, X = 0, DX = 0, Y = 0, DIR = 0) constructor {
	self.id = 51
	self.sock = SOCK
	self.pos = [X, DX, Y, DIR]
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.pos = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_position, self.pos)
		return buf
	}
	processPacket = function() {
		if !is_array(self.pos) {
			show_debug_message("PLAY_SB_MOVE_PLAYER_POS ERROR! self.pos IS NOT ARRAY! self.pos = '" + string(self.pos) + "'")	
			exit;
		}

		//if !instance_exists(obj_network_object) {
		if is_undefined(sock_to_inst(self.sock)) {
			var no = instance_create_depth(self.pos[0], self.pos[2], 0, obj_network_object)
			no.network_obj_type = "player"
			no.entity_uuid = generate_uuid4_string()
			struct_set(obj_multiplayer.network.players, self.sock, no.entity_uuid)
			struct_set(obj_multiplayer.network.network_objects, no.entity_uuid, no.id)
			no.nametag = no.entity_uuid // self.sock
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
			
			// replicate update to all client version of source pkuns whatever
			if (player_count() > 1) { // only need to replicate changes to other clients if its more than server and 1 client.
				show_debug_message("PLAY_SB_MOVE_PLAYER_POS: Replicating client changes to other clients! (no.entity_uuid = " + string(entity_uuid) + ")")
				_cb_sync_pkun(entity_uuid, other.pos[0], other.pos[1], other.pos[2], other.pos[3], other.sock)
			}
		}
	}
}
ds_map_add(global.packet_registry, 51, PLAY_SB_MOVE_PLAYER_POS)

function PLAY_CB_MOVE_PLAYER_POS(ENTITY_UUID = "", X = 0, DX = 0, Y = 0, DIR = 0) constructor {
	self.id = 52
	self.uuid = ENTITY_UUID
	self.pos = [X, DX, Y, DIR] //[X, Y, DIR, TOUCHING_WALL, FLASHLIGHT_ON]
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.uuid = buffer_read_ext(buf)
		self.pos = buffer_read_ext(buf)
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_uuid, self.uuid)
		buffer_write_ext(buf, buffer_position, self.pos)
		return buf
	}
	processPacket = function() {
		if (self.uuid == "") {
			show_debug_message("PLAY_CB_MOVE_PLAYER_POS: Couldn't create or edit entity with empty uuid!")
			exit;
		}
		
		if (entity_uuid_to_inst(self.uuid) == noone) {
			show_debug_message("PLAY_CB_MOVE_PLAYER_POS: Creating new obj_network_obj with uuid " + string(self.uuid))
			var no = instance_create_depth(self.pos[0], self.pos[2], 0, obj_network_object)
			no.network_obj_type = "player"
			no.entity_uuid = self.uuid
			struct_set(obj_multiplayer.network.network_objects, self.uuid, no.id)
			no.nametag = self.uuid // self.sock
			show_debug_message("PLAY_CB_MOVE_PLAYER_POS: echo uuid " + string(self.uuid) + " = " + string(no.entity_uuid))
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
		}
	}
}
ds_map_add(global.packet_registry, 52, PLAY_CB_MOVE_PLAYER_POS)

function PLAY_CB_MOVE_ENTITY_POS(ENTITY_UUID = "", X = 0, DX = 0, Y = 0, DIR = 0, STATE = 0, OBJECT_INDEX = -4) constructor {
	self.id = 53
	self.uuid = ENTITY_UUID
	self.pos = [X, DX, Y, DIR] //[X, Y, DIR, TOUCHING_WALL, FLASHLIGHT_ON]
	self.state = STATE
	self.object_index = OBJECT_INDEX
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
			show_debug_message("PLAY_CB_MOVE_ENTITY_POS: Couldn't create or edit entity with empty uuid!")
			exit;
		}
		
		if (entity_uuid_to_inst(self.uuid) == noone) {
			var inst = instance_create_depth(self.pos[0], self.pos[2], -3, self.object_index)
			inst.entity_uuid = self.uuid
			struct_set(obj_multiplayer.network.network_objects, inst.entity_uuid, inst.id)
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
	self.uuid = ENTITY_UUID
	self.pos = [X, DX, Y, DIR] //[X, Y, DIR, TOUCHING_WALL, FLASHLIGHT_ON]
	self.object_index = OBJECT_INDEX
	show_debug_message("PLAY_CB_CREATE_ENTITY: pos = " + string(self.pos))
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
			show_debug_message("PLAY_CB_CREATE_ENTITY: Couldn't create entity with empty uuid!")
			exit;
		}
		
		// remove entity if has same uuid but different obj index
		var _ent = entity_uuid_to_inst(self.uuid)
		if !(_ent == noone) {
			if (_ent[$ "object_index"] != self.object_index) {
				struct_remove(obj_multiplayer.network.network_objects, self.uuid)
				instance_destroy(_ent)
			}
		}
		
		if (entity_uuid_to_inst(self.uuid) == noone) { // check if entity exists
			var inst = instance_create_depth(self.pos[0], self.pos[2], -3, self.object_index)
			inst.entity_uuid = self.uuid
			inst.dir = self.pos[3]
			struct_set(obj_multiplayer.network.network_objects, self.uuid, inst.id)
			show_debug_message("PLAY_CB_CREATE_ENTITY: echo uuid " + string(self.uuid) + " = " + string(inst.entity_uuid))
		}
	}
}
ds_map_add(global.packet_registry, 54, PLAY_CB_CREATE_ENTITY)

function PLAY_CB_CREATE_ENTITIES(ENTITIES = []) constructor {
	self.id = 55
	self.entities = ENTITIES // [UUID, X, DX, Y, DIR, OBJ_INDEX]
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
			show_debug_message("PLAY_CB_CREATE_ENTITIES: Couldn't create entity with empty entities array!")
			exit;
		}
		
		for (var i = 0; i < array_length(self.entities); i++) {
			var _e = self.entities[i]
			show_debug_message("PLAY_CB_CREATE_ENTITIES: Applying entity: " + string(_e))	
			
			if (array_length(_e) < 6) {
				show_debug_message("PLAY_CB_CREATE_ENTITIES: Couldnt create entity, entity_array doesn't have enough indexes.")	
			}
				
			var _temp_packet = new PLAY_CB_CREATE_ENTITY(_e[0], _e[1], _e[2], _e[3], _e[4], _e[5])
			_temp_packet.processPacket()
		}
	}
}
ds_map_add(global.packet_registry, 55, PLAY_CB_CREATE_ENTITIES)

function PLAY_CB_DESTROY_ENTITY(ENTITY_UUID = "") constructor {
	self.id = 56
	self.uuid = ENTITY_UUID
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
			show_debug_message("PLAY_CB_DESTROY_ENTITY: Couldn't destroy entity with empty uuid!")
			exit;
		}
		
		with (entity_uuid_to_inst(self.uuid)) {
			struct_remove(obj_multiplayer.network.network_objects, entity_uuid)
			instance_destroy();
		}
	}
}
ds_map_add(global.packet_registry, 56, PLAY_CB_DESTROY_ENTITY)

function PLAY_CB_DESTROY_OBJECT(OBJECT_INDEX = -4) constructor {
	self.id = 57
	self.object_index = OBJECT_INDEX
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
			show_debug_message("PLAY_CB_DESTROY_OBJECT: Couldn't destroy object with empty object index!")
			exit;
		}
		
		with (self.object_index) {
			instance_destroy()
		}
		show_debug_message("PLAY_CB_DESTROY_OBJECT: Destroyed all instances of " + string(object_get_name(self.object_index)))
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
//		//	struct_set(obj_multiplayer.network.network_objects, inst.entity_uuid, inst.id)
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
	self.sock = SOCK
	self.flash = FLASH
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
	self.uuid = UUID
	self.flash = FLASH
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
	self.sock = SOCK
	self.mob_id = MOB_ID
	self.hs_stp = HS_STP
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
		show_debug_message("ADJUSTING HSCENE FOR SOCK " + string(self.sock))
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
	self.uuid = ENTITY_UUID
	self.mob_id = MOB_ID
	self.hs_stp = HS_STP
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
		show_debug_message("ADJUSTING HSCENE FOR UUID " + string(self.uuid))
		with (entity_uuid_to_inst(self.uuid)) {
			hs_mob_id = other.mob_id
			hs_stp = other.hs_stp
		}
	}
}
ds_map_add(global.packet_registry, 61, PLAY_CB_SET_HSCENE)

function PLAY_SB_SET_ENTITY_CONTROL(SOCK = -1, ENTITY_UUID_TO_CONTROL = "", CONTROL = 0) constructor {
	self.id = 62
	self.sock = SOCK
	self.uuid = ENTITY_UUID_TO_CONTROL
	self.control = CONTROL
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
		show_debug_message("PLAY_SB_SET_ENTITY_CONTROL: ADJUSTING CONTROLLER FOR UUID " + string(self.uuid) + ", CONTROLLER SOCK IS " + string(self.sock))
		with (entity_uuid_to_inst(self.uuid)) {
			var _temp = controlled
			controlled = (other.control) ? other.sock : 0 //(other.control) ? other.sock : 0
			show_debug_message("PLAY_SB_SET_ENTITY_CONTROL: CONTROLLER WAS " + string(_temp) + ", NOW IS " + string(controlled))
			dx = 0
			exit;
		}
		show_debug_message("PLAY_SB_SET_ENTITY_CONTROL: NO ENTITY FOUND FOR UUID " + string(self.uuid) + ", CONTROLLER SOCK IS " + string(self.sock))
	}
}
ds_map_add(global.packet_registry, 62, PLAY_SB_SET_ENTITY_CONTROL)

function PLAY_SB_MOVE_ENTITY_POS(SOCK = -1, ENTITY_UUID = "", X = 0, DX = 0, Y = 0, DIR = 0, STATE = 0) constructor {
	// THIS REQUIRES THAT THE ENTITY HAS CONTROLLER VARIABLE SET TO CLIENT SOCK
	self.id = 63
	self.sock = SOCK
	self.uuid = ENTITY_UUID
	self.pos = [X, abs(DX), Y, DIR] //[X, Y, DIR, TOUCHING_WALL, FLASHLIGHT_ON]
	self.state = STATE
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
			show_debug_message("PLAY_SB_MOVE_ENTITY_POS: Couldn't create or edit entity with empty uuid!")
			exit;
		}
		
		if (entity_uuid_to_inst(self.uuid) == noone) {
			show_debug_message("PLAY_SB_MOVE_ENTITY_POS: Couldn't move entity on server from client request, client provided entity_uuid doesn't exist.")
			exit;
		}
	
		// adjust server version of object
		with (entity_uuid_to_inst(self.uuid)) {
			// check if being controlled, and if it is from right sock
			if !(controlled == other.sock) {
				show_debug_message("PLAY_SB_MOVE_ENTITY_POS: Illegal attempt from client to move entity '" + string(other.uuid) + "' (offender sock = " + string(other.sock) + ", entity.controlled = " + string(controlled) + ", client provided entity_uuid = " + string(other.uuid) + ")")
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
	self.sock = SOCK
	self.timestop = TIMESTOP
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
	self.can_move = CAN_CLIENT_MOVE_IN_TIMESTOP
	self.timestop = TIMESTOP
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
	self.sock = SOCK
	self.intr_type = INTR_TYPE
	self.x = X
	self.y = Y
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
			show_debug_message("PLAY_SB_INTERACT_AT: Interacted w/ obj not found or dont exist OR player doesnt exist")
			exit;
		}
		
		with (_plr) {
			if (distance_to_object(_intr) > 50) && !_hidebox {
				show_debug_message("PLAY_SB_INTERACT_AT: Tried to interact w/ obj that's too far from player!")
				exit;
			}
		}
		
		if !(_hidebox) && (_intr.type != self.intr_type) {
			show_debug_message("PLAY_SB_INTERACT_AT: Interacted w/ obj type doesnt match provided intr_type! Cancelling!")
			exit;
		}
		
		switch (self.intr_type) {
			case "portal": {
				show_debug_message("PLAY_SB_INTERACT_AT: SOCK " + string(self.sock) + " Interacted w/ portal!")
				play_se_at(_intr.se, _intr.x, _intr.y)
				break;
			}
			case "hidespot": {
				show_debug_message("PLAY_SB_INTERACT_AT: SOCK " + string(self.sock) + " Interacted w/ hidespot!")
	            play_se_at(_intr.se_in, _intr.x, _intr.y)
	            _intr.shake = (20)
	            _intr.locked = !_intr.locked
				_plr.hiding = !_plr.hiding
				_plr.x = _intr.x
				break;
			}
			case "itemspot": {
				show_debug_message("PLAY_SB_INTERACT_AT: SOCK " + string(self.sock) + " Interacted w/ itemspot!")
				play_se_at(_intr.se, _intr.x, _intr.y)
				if (_intr.x == self.x) && (intr.y == self.y) // must be in same exact pos
					instance_destroy(_intr.id)
				break;
			}
			case "figure": {
				show_debug_message("PLAY_SB_INTERACT_AT: SOCK " + string(self.sock) + " Interacted w/ figure!")
				show_debug_message("Figure Interaction Handling is not integrated yet...")
				break;
			}
			case "piano": {
				show_debug_message("PLAY_SB_INTERACT_AT: SOCK " + string(self.sock) + " Interacted w/ piano!")
	            play_se(_intr.se, 1)
	            instance_destroy(_intr.id)
				break;
			}
			case "hidebox": {
				show_debug_message("PLAY_SB_INTERACT_AT: SOCK " + string(self.sock) + " Interacted w/ hidebox!")
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
	self.uuid = ENTITY_UUID
	self.intr_type = INTR_TYPE
	self.x = X
	self.y = Y
	self.as_target_client = AS_TARGET_CLIENT
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
			show_debug_message("PLAY_CB_INTERACT_AT: Interacted w/ obj not found or dont exist OR player doesnt exist")
			exit;
		}
		
		with (_plr) {
			if (distance_to_object(_intr) > 50) && !_hidebox	 {
				show_debug_message("PLAY_CB_INTERACT_AT: Tried to interact w/ obj that's too far from player!")
				exit;
			}
		}
		
		if !(_hidebox) && (_intr.type != self.intr_type) {
			show_debug_message("PLAY_CB_INTERACT_AT: Interacted w/ obj type doesnt match provided intr_type! Cancelling!")
			exit;
		}
		
		switch (self.intr_type) {
			case "portal": {
				show_debug_message("PLAY_CB_INTERACT_AT: UUID " + string(self.uuid) + " Interacted w/ portal!")
				play_se_at(_intr.se, _intr.x, _intr.y)
				break;
			}
			case "hidespot": {
				show_debug_message("PLAY_CB_INTERACT_AT: UUID " + string(self.uuid) + " Interacted w/ hidespot!")
	            play_se_at(_intr.se_in, _intr.x, _intr.y)
	            _intr.shake = (20)
				_intr.locked = !_intr.locked
				_plr.hiding = !_plr.hiding
				_plr.x = _intr.x
				break;
			}
			case "itemspot": {
				show_debug_message("PLAY_CB_INTERACT_AT: UUID " + string(self.uuid) + " Interacted w/ itemspot!")
				play_se_at(_intr.se, _intr.x, _intr.y)
				if (_intr.x == self.x) && (intr.y == self.y) // must be in same exact pos
					instance_destroy(_intr.id)
				break;
			}
			case "figure": {
				show_debug_message("PLAY_CB_INTERACT_AT: UUID " + string(self.uuid) + " Interacted w/ figure!")
				show_debug_message("Figure Interaction Handling is not integrated yet...")
				break;
			}
			case "piano": {
				show_debug_message("PLAY_CB_INTERACT_AT: UUID " + string(self.uuid) + " Interacted w/ piano!")
	            play_se(_intr.se, 1)
	            instance_destroy(_intr.id)
				break;
			}
			case "hidebox": {
				show_debug_message("PLAY_CB_INTERACT_AT: UUID " + string(self.uuid) + " Interacted w/ hidebox!")
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

/// @function do_packet
/// @description Constructs and sends a packet. Argument1 is packet_id, rest of arguments are packet data (packet args for packet constructor)
function do_packet(pkt, target_socks) {
	var pktbuf = pkt.writePacketData()
	multiplayer_send_packet(target_socks, pktbuf)
	buffer_delete(pktbuf)
}

// packet sending functions
function sync_pkun_event() {
	var __log = function(msg, type = "INFO") {log(msg, type, "FUNC/sync_pkun_event")}
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
function _cb_sync_pkun(uuid = "", tx = -4, tdx = -4, ty = -4, tdir = -4, src_sock = -1) {
	var __log = function(msg, type = "INFO") {log(msg, type, "FUNC/_cb_sync_pkun")}
	if (!check_is_server() || !instance_exists(obj_pkun) || room = rm_intro || room = rm_title) {
		exit; // only run as server and if we have moved
	}
	
	var provided_uuid = !(uuid == "")
	
	var entityUUID = provided_uuid ? uuid : obj_multiplayer.server.player.entity_uuid; 
	var tX = provided_uuid ? tx : obj_pkun.x
	var tDX = provided_uuid ? tdx : obj_pkun.move_speed
	var tY = provided_uuid ? ty : obj_pkun.y
	var tDIR = provided_uuid ? tdir : obj_pkun.dir
	var last_pos = global.multiplayer_pkun_sync_hist
	
	if (!provided_uuid) {
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
		
		obj_pkun.last_move_speed = obj_pkun.move_speed
	}
	
	var target_socks = array_without(struct_get_names(obj_multiplayer.server.clients), src_sock)
	do_packet(new PLAY_CB_MOVE_PLAYER_POS(entityUUID, tX, tDX, tY, tDIR), target_socks) //, tTW, tFO)
	__log("Sent Server to Client Pkun Sync Packet (" + string(src_sock) + " -> " + string(target_socks) + ")")
}

function sync_flashlight_event() {
	if !is_multiplayer()
		exit;
	
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
	var uuid = (string_length(source_sock_or_uuid) == 36) ? source_sock_or_uuid : obj_multiplayer.network.players[$ source_sock_or_uuid]
	var target_socks = array_without(struct_get_names(obj_multiplayer.network.players), source_sock_or_uuid)
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
	
	show_debug_message("CB_SYNC_MOB INSIDE INSTANCE " + string(id))
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
			
		show_debug_message("_cb_sync_mob (mob: " + string(object_get_name(object_index)) + "), differences:" + msg)
		
		if check { // we did do the last update
			show_debug_message("SKIPPING MOB UPDATE, ALREADY SENT LAST UPDATE PACKET (" + string(object_get_name(object_index)) + ")")
			exit;
		} else {
			show_debug_message("SENDING LAST MOB UPDATE PACKET, DIDNT MOVE THO (" + string(object_get_name(object_index)) + ")")
			check = 1
		}
	} else {
		check = 0 // pos changed	
	}
	
	struct_set(global.multiplayer_entity_sync_hist, entity_uuid, [x, dx, y, dir, state, check])	
	self.last_move_speed = self.move_speed
	
	if check_is_server() {
		show_debug_message("SENDING MOB POS UPDATE PACKET (SERVER TO CLIENT) (" + string(object_get_name(object_index)) + ")")
		var target_socks = struct_get_names(obj_multiplayer.network.players)
		if !(controlled == 0) // dont send it to controller, causes issues
			target_socks = array_without(target_socks, controlled)
		do_packet(new PLAY_CB_MOVE_ENTITY_POS(entity_uuid, x, abs(dx), y, dir, state, object_index), target_socks)
	} else {
		show_debug_message("SENDING MOB POS UPDATE PACKET (CLIENT TO SERVER) (" + string(object_get_name(object_index)) + ")")
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
			show_debug_message("SKIPPING HSCENE UPDATE, ALREADY SENT LAST UPDATE PACKET")
			exit;
		} else {
			show_debug_message("SENDING LAST HSCENE UPDATE PACKET, DIDNT CHANGE THO")
			hscene_check = 1
		}
	} else {
		hscene_check = 0 // pos changed	
		
		if !(last_hscene_mob_id == obj_pkun.hs_mob_id)
			msg+= "\Hscene hs_mob_id Changed"
		if !(last_hscene_stp == obj_pkun.hs_stp)
			msg+= "\nHscene Stp Changed"
			
		show_debug_message("sync_hscene_event HSCENE CHANGED, differences:" + msg)
	}
	
	show_debug_message("SENDING HSCENE UPDATE PACKET")
	global.multiplayer_pkun_sync_hist[3] = obj_pkun.hs_mob_id
	global.multiplayer_pkun_sync_hist[4] = obj_pkun.hs_stp
	global.multiplayer_pkun_sync_hist[5] = hscene_check
	
	if check_is_server() {
		var target_socks = struct_get_names(obj_multiplayer.network.players)
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
	
	if !struct_exists(obj_multiplayer.network.network_objects, UUID) {
		show_debug_message("_cb_create_entity " + string(object_get_name(OBJ_INDEX)) + " (" + string(UUID) + ") FAILED! UUID doesnt exist in serverside network.network_objects!")
		exit;
	}
	
	var target_socks = struct_get_names(obj_multiplayer.network.players)
	do_packet(new PLAY_CB_CREATE_ENTITY(entity_uuid, x, dx, y, dir, object_index) , target_socks)
}

function _cb_destroy_entity(UUID) {
	if (!check_is_server()) { // || (player_count() <= 1) || (instance_number(obj_p_syncable) == 0) {
		exit; // only run as server
	}
	
	show_debug_message("_cb_destroy_entity (" + string(UUID) + ")")
	do_packet(new PLAY_CB_DESTROY_ENTITY(entity_uuid), struct_get_names(obj_multiplayer.network.players))
}

function _cb_destroy_object(object_index) {
	if (!check_is_server()) { // || (player_count() <= 1) || (instance_number(obj_p_syncable) == 0) {
		exit; // only run as server
	}
	
	show_debug_message("_cb_destroy_object (" + string(object_index) + ", " + string(object_get_name(object_index)) + ")")
	do_packet(new PLAY_CB_DESTROY_OBJECT(object_index), struct_get_names(obj_multiplayer.network.players))
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