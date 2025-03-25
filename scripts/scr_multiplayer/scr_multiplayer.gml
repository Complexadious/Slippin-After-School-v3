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
//		show_debug_message("PLAY_SB_MOVE_PLAYER_POS: READ: POS = " + string(self.pos))
	}
	writePacketData = function() {
		var buf = buffer_create(1, buffer_grow, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
//		show_debug_message("PLAY_SB_MOVE_PLAYER_POS: WRITE: POS = " + string(self.pos))
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
			struct_set(obj_multiplayer.network.players, self.sock, no.entity_uuid)
			no.nametag = self.sock
		}
		
		// adjust server version of pkun
		with (sock_to_inst(self.sock)) {
			array_push(posxq, other.pos[0]);
			array_shift(posxq)
			
			x = other.pos[0] // -= adjust_to_fps((x - other.pos[0]) / 2);
			y = other.pos[2] //-= adjust_to_fps((y - other.pos[2]) / 2);
			array_push(posyq, other.pos[2]);
			array_shift(posyq)
			
			// make the flashOn an array, so we can cycle the stuff, if indexes arent the same, it changed.
//			array_push(flashOn, other.pos[4]);
//			array_shift(flashOn)
			
//			dx = (posxq[1] - posxq[0]) / (60 / (obj_multiplayer.client.settings.game.tick_rate))
			dir = other.pos[3]
			dx = (other.pos[1] * dir)
			
			// replicate update to all client version of source pkuns whatever
			if (player_count() > 2) { // only need to replicate changes to other clients if its more than server and 1 client.
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
			var no = instance_create_depth(self.pos[0], self.pos[2], 0, obj_network_object)
			no.network_obj_type = "player"
			no.entity_uuid = self.uuid
//			struct_set(obj_multiplayer.network.players, self.sock, no.entity_uuid)
			no.nametag = self.uuid
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

function PLAY_CB_MOVE_ENTITY_POS(ENTITY_UUID = "", X = 0, DX = 0, Y = 0, DIR = 0, OBJECT_INDEX = -4) constructor {
	self.id = 53
	self.uuid = ENTITY_UUID
	self.pos = [X, DX, Y, DIR] //[X, Y, DIR, TOUCHING_WALL, FLASHLIGHT_ON]
	self.object_index = OBJECT_INDEX
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
		}
	}
}
ds_map_add(global.packet_registry, 53, PLAY_CB_MOVE_ENTITY_POS)

function PLAY_CB_UPDATE_ENTITY_VAR(ENTITY_UUID = "", VAR_AND_VAL_ARRAY = [], OBJECT_INDEX = -4) constructor {
	self.id = 54
	self.uuid = ENTITY_UUID
	self.var_and_val_array = VAR_AND_VAL_ARRAY
//	self.val_array = VAL_ARRAY
	self.object_index = OBJECT_INDEX
	readPacketData = function(buf) {
//		buffer_seek(buf, buffer_seek_start, 0)
//		self.id = buffer_read_ext(buf)
//		self.uuid = buffer_read_ext(buf)
//		self.var_and_val_array = buffer_read_ext(buf)
////		self.val_array = buffer_read_ext(buf)
//		self.object_index = buffer_read_ext(buf)
		show_debug_message("READING UPDATE ENTITY VAR!")
	}
	writePacketData = function() {
		var buf = buffer_create(32, buffer_grow, 1)
//		buffer_seek(buf, buffer_seek_start, 0)
//		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
////		buffer_write_ext(buf, buffer_uuid, self.uuid)
////		buffer_write_ext(buf, buffer_array, self.var_and_val_array)
//////		buffer_write_ext(buf, buffer_array, self.val_array)
////		buffer_write_ext(buf, buffer_vint, self.object_index)
		return buf
	}
	processPacket = function() {
		if (self.uuid == "") {
			show_debug_message("PLAY_CB_UPDATE_ENTITY_VAR: Couldn't create or edit entity with empty uuid!")
			exit;
		}
		
		show_debug_message("YOO! GOT MOB PACKET! MOB IS " + string(object_get_name(self.object_index) + ", ARRAY IS " + string(self.var_and_val_array)))
//		if !(array_length(self.var_array) == array_length(self.val_array)) {
//			show_debug_message("PLAY_CB_UPDATE_ENTITY_VAR: Var and Val arrays are different sizes! Cancelling!")
//			exit;	
//		}
		
		//if (entity_uuid_to_inst(self.uuid) == noone) {
		//	var inst = instance_create_depth(self.pos[0], self.pos[2], -3, self.object_index)
		//	inst.entity_uuid = self.uuid
		//	struct_set(obj_multiplayer.network.network_objects, inst.entity_uuid, inst.id)
		//}
	
		//// adjust client version of object
		//with (entity_uuid_to_inst(self.uuid)) {
		//	for (var i = 0; i < (array_length(other.var_and_val_array) - 1); i+= 2) {
		//		var variable = other.var_and_val_array[i]
		//		var value = other.var_and_val_array[i + 1]
		//		show_debug_message("PLAY_CB_UPDATE_ENTITY_VAR, setting '" + string(variable) + "' to '" + string(value) + "'")
		//		variable_instance_set(id, variable, value)
		//	}
		//}
	}
}
ds_map_add(global.packet_registry, 54, PLAY_CB_UPDATE_ENTITY_VAR)

function PLAY_SB_TOGGLE_FLASHLIGHT(SOCK = -1, FLASH = 0) constructor {
	self.id = 55
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
			if (player_count() > 2) {
				_cb_sync_flashlight(entity_uuid, other.flash)
			}
		}
	}
}
ds_map_add(global.packet_registry, 55, PLAY_SB_TOGGLE_FLASHLIGHT)

function PLAY_CB_TOGGLE_FLASHLIGHT(UUID = "", FLASH = 0) constructor {
	self.id = 56
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
ds_map_add(global.packet_registry, 56, PLAY_CB_TOGGLE_FLASHLIGHT)

/// @function do_packet
/// @description Constructs and sends a packet. Argument1 is packet_id, rest of arguments are packet data (packet args for packet constructor)
function do_packet() {
	if (argument_count < 1)
		exit; // no id or nun
	
	if !ds_map_exists(global.packet_registry, packet_id)
		exit; // packet dont exist
	
	var _pktc = global.packet_registry[? packet_id]
	
	var pkt = new PLAY_SB_MOVE_PLAYER_POS(-1, tX, tDX, tY, tDIR) //, tTW, tFO)
	var pktbuf = pkt.writePacketData()
	multiplayer_send_packet(network.server.connection, pktbuf)
	buffer_delete(pktbuf)
}

// packet sending functions
function sync_pkun_event() {
	var __log = function(msg, type = "INFO") {log(msg, type, "FUNC/sync_pkun_event")}
	if !is_multiplayer()
		exit;
	
	if (check_is_server() || (obj_multiplayer.network.server.connection < 0) || !instance_exists(obj_pkun) || room = rm_intro || room = rm_title) {
//		show_debug_message("SKIPPED PKUN UPDATE")
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
	var last_pos = global.multiplayer_last_sent_pkun_pos
	
	if (last_pos[0] == tX) && (last_pos[1] == tY) && (last_pos[2] == tDIR) {
		if global.multiplayer_check_sent_last_pkun_pos { // we did do the last update
//			show_debug_message("SKIPPING PKUN UPDATE, ALREADY SENT LAST UPDATE PACKET")
			exit;
		} else {
//			show_debug_message("SENDING LAST PKUN UPDATE PACKET, DIDNT MOVE THO")
			global.multiplayer_check_sent_last_pkun_pos = 1
		}
	} else {
		global.multiplayer_check_sent_last_pkun_pos = 0 // pos changed	
	}
	
	global.multiplayer_last_sent_pkun_pos = [tX, tY, tDIR]
//	show_debug_message("DID PKUN UPDATE, LAST SENT PKUN POS = " + string(global.multiplayer_last_sent_pkun_pos))
	
	var pkt = new PLAY_SB_MOVE_PLAYER_POS(-1, tX, tDX, tY, tDIR) //, tTW, tFO)
	var pktbuf = pkt.writePacketData()
	multiplayer_send_packet(obj_multiplayer.network.server.connection, pktbuf)
	buffer_delete(pktbuf)
	
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
//	var __log = function(msg, type = "INFO") {log(msg, type, "FUNC/_cb_sync_pkun")}
	if (!check_is_server() || !instance_exists(obj_pkun) || room = rm_intro || room = rm_title) {
		exit; // only run as server and if we have moved
	}
	
	var provided_uuid = !(uuid == "")
	
	var entityUUID = provided_uuid ? uuid : obj_multiplayer.server.player.entity_uuid; 
	var tX = provided_uuid ? tx : obj_pkun.x
	var tDX = provided_uuid ? tdx : obj_pkun.move_speed
	var tY = provided_uuid ? ty : obj_pkun.y
	var tDIR = provided_uuid ? tdir : obj_pkun.dir
	var last_pos = global.multiplayer_last_sent_pkun_pos
	
	if (!provided_uuid) {
		if (last_pos[0] == tX) && (last_pos[1] == tY) && (last_pos[2] == tDIR) {
			if global.multiplayer_check_sent_last_pkun_pos { // we did do the last update
	//			show_debug_message("SKIPPING PKUN UPDATE, ALREADY SENT LAST UPDATE PACKET")
				exit;
			} else {
	//			show_debug_message("SENDING LAST PKUN UPDATE PACKET, DIDNT MOVE THO")
				global.multiplayer_check_sent_last_pkun_pos = 1
			}
		} else {
			global.multiplayer_check_sent_last_pkun_pos = 0 // pos changed	
		}
		global.multiplayer_last_sent_pkun_pos = [tX, tY, tDIR]
		obj_pkun.last_move_speed = obj_pkun.move_speed
	}
	
//	show_debug_message("DID PKUN UPDATE, LAST SENT PKUN POS = " + string(global.multiplayer_last_sent_pkun_pos))
	var pkt = new PLAY_CB_MOVE_PLAYER_POS(entityUUID, tX, tDX, tY, tDIR) //, tTW, tFO)
	var pktbuf = pkt.writePacketData()
	var target_socks = array_without(struct_get_names(obj_multiplayer.network.players), src_sock)
	
	multiplayer_send_packet(target_socks, pktbuf)
	buffer_delete(pktbuf)

//	__log("Sent Server to Client Pkun Sync Packet")
}

function sync_flashlight_event() {
	if (check_is_server() || (obj_multiplayer.network.server.connection < 0)) {
		if check_is_server() {
			// redirect to server to client shit
			// this will only fire when it is the SERVER's pkun updating his flashlight
			_cb_sync_flashlight(obj_multiplayer.server.player.entity_uuid, global.flashOn)
		}
		exit; // only run as client
	}
		
	var pkt = new PLAY_SB_TOGGLE_FLASHLIGHT(-1, global.flashOn) //, tTW, tFO)
	var pktbuf = pkt.writePacketData()
	multiplayer_send_packet(obj_multiplayer.network.server.connection, pktbuf)
	buffer_delete(pktbuf)
}

function _cb_sync_flashlight(source_sock_or_uuid, flash) {
	if (!check_is_server()) {
		exit; // only run as server
	}

	source_sock_or_uuid = string(source_sock_or_uuid)
	var uuid = (string_length(source_sock_or_uuid) == 36) ? source_sock_or_uuid : obj_multiplayer.network.players[$ source_sock_or_uuid]
	var pkt = new PLAY_CB_TOGGLE_FLASHLIGHT(uuid, flash) //, tTW, tFO)
	var pktbuf = pkt.writePacketData()
	var target_socks = array_without(struct_get_names(obj_multiplayer.network.players), source_sock_or_uuid)
	
	multiplayer_send_packet(target_socks, pktbuf)
	buffer_delete(pktbuf)
}

function _cb_sync_mobs() {
	if (!check_is_server()) { // || (player_count() <= 1) || (instance_number(obj_p_syncable) == 0) {
		exit; // only run as server
	}
	
	show_debug_message("CB_SYNC_MOBS RAN!")

	with (obj_p_syncable) {
		if (diff_vars_and_vals != []) {
			show_debug_message("INSIDE MOB: " + string(object_get_name(object_index)) + ", diff = " + string(diff_vars_and_vals))
			var pkt = new PLAY_CB_UPDATE_ENTITY_VAR(entity_uuid, diff_vars_and_vals, object_index) //, tTW, tFO)
			var pktbuf = pkt.writePacketData()
	
			multiplayer_send_packet(obj_multiplayer.network.players, pktbuf)
			buffer_delete(pktbuf)
		}
	}
}