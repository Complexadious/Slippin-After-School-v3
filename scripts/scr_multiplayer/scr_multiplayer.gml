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
//		show_debug_message("multiplayer_send_packet: Sent packet out! (" + string(sockets[i] + ")"))
	}
}

function multiplayer_handle_packet(sock, buffer) {
	buffer_seek(buffer, buffer_seek_relative, 0)
	var packet_id = buffer_read_ext(buffer)
//	show_debug_message("*** GOT PACKET! ID IS " + string(packet_id))
	buffer_seek(buffer, buffer_seek_relative, 0)
	
	var pkt = undefined
	
	if ds_map_exists(global.packet_registry, packet_id) {
//		show_debug_message("*** PACKET ID IS FOUND IN REGISTRY!!")	
		pkt = new global.packet_registry[? packet_id]()
		pkt.readPacketData(buffer)
		pkt.processPacket()
	} else {
//		show_debug_message("*** PACKET ID IS NOT FOUND IN REGISTRY!!")	
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
		var buf = buffer_create(2, buffer_fixed, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_vint, self.rid)
		return buf
	}
	processPacket = function() {
//		var _rbuf = writePacketData()
	}
}
ds_map_add(global.packet_registry, 5, CONNECT_SB_PING_REQUEST)

function CONNECT_CB_PONG_RESPONSE(RID = -1) constructor {
	self.id = 6
	self.rid = RID
	readPacketData = function(buf) {
		self.id = buffer_read_ext(buf)
		self.rid = buffer_read_ext(buf, buffer_vint, undefined, 1)
	}
	writePacketData = function() {
		var buf = buffer_create(2, buffer_fixed, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
		buffer_write_ext(buf, buffer_vint, self.rid)
		return buf
	}
	processPacket = function() {
//		var _rbuf = writePacketData()
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
function LOADGAME_SB_PING_REQUEST() constructor {
	self.id = 31
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
ds_map_add(global.packet_registry, 31, LOADGAME_SB_PING_REQUEST)

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

function PLAY_SB_MOVE_PLAYER_POS(X = 0, Y = 0, DIR = 0, TOUCHING_WALL = 0, FLASHLIGHT_ON = 0) constructor {
	self.id = 51
	self.pos = [X, Y, DIR, TOUCHING_WALL, FLASHLIGHT_ON]
	readPacketData = function(buf) {
		buffer_seek(buf, buffer_seek_start, 0)
		self.id = buffer_read_ext(buf)
		self.pos = buffer_read_ext(buf)
//		show_debug_message("PLAY_SB_MOVE_PLAYER_POS: READ: POS = " + string(self.pos))
	}
	writePacketData = function() {
		var buf = buffer_create(32, buffer_fixed, 1)
		buffer_seek(buf, buffer_seek_start, 0)
		buffer_write_ext(buf, BUFFER_DT_ID_TYPE, self.id)
//		show_debug_message("PLAY_SB_MOVE_PLAYER_POS: WRITE: POS = " + string(self.pos))
		buffer_write_ext(buf, buffer_position, self.pos)
		return buf
	}
	processPacket = function() {
		if !instance_exists(obj_network_object) {
			instance_create_depth(self.pos[0], self.pos[1], 0, obj_network_object)
		}
		with (obj_network_object) {
			network_obj_type = "player"
			
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
ds_map_add(global.packet_registry, 51, PLAY_SB_MOVE_PLAYER_POS)

function _testfunc() {
	tX = 0; tY = 0; tDIR = 0; tTW = 0; tFO = 0
	with (obj_pkun) {
		other.tX = x; other.tY = y; other.tDIR = dir; other.tFO = flashOn
	}
	
	var pkt = new PLAY_SB_MOVE_PLAYER_POS(tX, tY, tDIR, tTW, tFO)
	var pktbuf = pkt.writePacketData()
	multiplayer_send_packet(struct_get_names(server.clients), pktbuf)
	buffer_delete(pktbuf)
}