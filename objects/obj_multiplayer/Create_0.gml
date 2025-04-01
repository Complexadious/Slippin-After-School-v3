#macro logInfoType "INFO"
#macro logWarningType "WARNING"
#macro logErrorType "ERROR"

#macro BUFFER_SEGMENT_BITS 0x7F
#macro BUFFER_CONTINUE_BIT 0x80
#macro buffer_custom_datatype_start 32
//#macro buffer_vint 492
//#macro buffer_vlong 493
//#macro buffer_s64 494
//#macro buffer_jstring 495
//#macro buffer_position 496
//#macro buffer_uuid 497
//#macro buffer_array 498
#macro buffer_vint buffer_custom_datatype_start + 1
#macro buffer_vlong buffer_custom_datatype_start + 2
#macro buffer_s64 buffer_custom_datatype_start + 3
#macro buffer_jstring buffer_custom_datatype_start + 4
#macro buffer_position buffer_custom_datatype_start + 5
#macro buffer_uuid buffer_custom_datatype_start + 6
#macro buffer_array buffer_custom_datatype_start + 7

#macro buffer_undefined buffer_custom_datatype_start + 8
#macro buffer_inf buffer_custom_datatype_start + 9
#macro buffer_pi buffer_custom_datatype_start + 10
#macro buffer_nan buffer_custom_datatype_start + 11


#macro BUFFER_DT_ID_TYPE buffer_u8
#macro BUFFER_DT_ID_TYPE_BYTES 1

// X: 15 bits, Y: 15 bits, DIR: 1 bit, AGAINST_WALL: 1 bit
#macro BP_BDT buffer_u32
#macro BP_X_ALLOCATION 14
#macro BP_DX_ALLOCATION 4
#macro BP_Y_ALLOCATION 13
#macro BP_DIR_ALLOCATION 1
//#macro BP_AW_ALLOCATION 1
//#macro BP_FLASH_ALLOCATION 1

// settings
#macro MAX_CLIENTS 5
#macro SERVER_PORT 25565
#macro MAX_PACKET_SIZE 32768
#macro MAX_PACKETS_PER_SECOND = 120

// Network Roles
enum NETWORK_ROLE {
	SERVER,
	CLIENT
}

// Connection States
enum CONNECTION_STATE {
	OFFLINE,
	CONNECT,
	CONFIGURATION,
	LOAD_GAME,
	PLAY,
	HOSTING
}

/*
// Packets
CONNECT_PACKET = {
	SB_PING_REQUEST: {
		ID: data_type.int
	},
	CB_PONG_RESPONSE: {
		ID: data_type.int
	},
}

CONFIGURATION_PACKET = {
	SB_KEEP_ALIVE: {KEEP_ALIVE_ID: DATA_TYPE.LONG},
	CB_KEEP_ALIVE: {KEEP_ALIVE_ID: DATA_TYPE.LONG},
	SB_CLIENT_INFO: {USERNAME: DATA_TYPE.STRING},
	CB_SERVER_INFO: {},
	SB_SERVER_INFO_ACK: {},
	CB_DISCONNECT: {REASON: DATA_TYPE.STRING},
}

LOAD_GAME_PACKET = {
	SB_KEEP_ALIVE: {KEEP_ALIVE_ID: DATA_TYPE.LONG}, // Make sure server is alive
	CB_KEEP_ALIVE: {KEEP_ALIVE_ID: DATA_TYPE.LONG}, // Make sure client is alive
	CB_ROOM_DATA: {}, // Current room data (instances)
	SB_ROOM_LOADED: {}, // Tell the server we loaded the room and are good to go
}

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

// Network Data
network = {
	role: NETWORK_ROLE.CLIENT,
	connection_state: CONNECTION_STATE.OFFLINE,
	connection_state_data: {
		connect_rid: -1	
	},
	server: {
		socket: -1,
		connection: -1,
		connected: 0
	},
	timers: {
//		pkt: {},
	},
//	client: {},
	statistics: {},
	entities: {
		// entity_id (EID) -> entity constructor
	},
	players: {
		/* player_id (PID) -> player constructor {
			username: "sigma",
			entity: entity constructor
		} */
	}
}

// Server Data
server = {
	clients: {}, // sock -> {pid, connection_state, role}
	settings: {
		game: {
			tick_rate: 10, // Game tick rate per second
			globals_to_sync: ["clock_hr", "clock_tk", "clock_tk_spd", "clock_min"] // Global variables to sync from server to client (server overwrites client)
		}
	},
	game: {
		mobs: {}
	},
	player: {
		pid: 0,
		entity_uuid: generate_uuid4_string(),
		username: "unsetServerUsername"
	}
}

// Client Data
client = {
	server: {},
	settings: {
		game: {
			tick_rate: 10 // Game tick rate per second
		},
	},
	game: {},
	player: {
		pid: -1,
		entity_uuid: "",
		username: ""
	}
}

_log = function(msg = "??EMPTY_MESSAGE??", type = logInfoType, show_on_screen = 0) {
	log("[" + ((network.role == NETWORK_ROLE.SERVER) ? "SERVER" : "CLIENT") + "]: " + msg, type)
}

add_timer("MULTIPLAYER_LOG_TMR", adjust_to_fps(1), 60, undefined, 1, 0)

// actual game shit
// client
//add_timer("SB_CLIENT_PKUN_UPDATE", adjust_to_fps(1), 60, [sync_pkun_event, []], 1, 0)

// Server
//add_timer("CB_CLIENT_PKUN_UPDATE", adjust_to_fps(1), (60 / client.settings.game.tick_rate), [_cb_sync_pkun, []], 1, 0)
//add_timer("CB_MOB_INST_VARS_UPDATE", adjust_to_fps(1), (60 / server.settings.game.tick_rate), [_cb_sync_mobs, []], 1, 0)





//var tmr = new multiplayer_timer(adjust_to_fps(1), 300, [sys_game_restart, []])
//var tmr_uuid = generate_uuid4_string()
////struct_set(network.timers.loc, tmr_uuid, tmr)
//struct_set(network.timers.paths, tmr_uuid, tmr)


//is_server = false;
//role_str = "client"
//server_socket = -1;
//server_connection = -1;

//global.sync_hearts = 0
//global.sync_hscene = 0

//global.m_intr_uuid_len = 3

//log = function(msg) {
//	var role = (is_server) ? "SERVER" : "CLIENT"
	
//	global.mini_dialog_line = ("[" + role + "]: " + string(msg))
//	obj_sys.mini_dialog_timer = 300
	
//	show_debug_message(log_msg_prefix() + "[OBJ obj_multiplayer_networking] (" + role + "): " + string(msg))
//}

//// packet timers
//player_packet_timeout_dur = (adjust_to_fps(1) * 600)
//server_packet_timeout_dur = (adjust_to_fps(1) * 600)

//process_packet = { // what role processes what packets. If it isnt here, it will skip processing it
//	"server": ["pkun_data", "interact_request", "player_join_room"],
//	"client": ["pkun_data", "mob_data", "game_state_data", "room_data", "q_room_data", "interact_request"]
//}

//timers = {
//	server: { // if struct must have curr, loop, dur, func
//		player_packet_timeouts: {},
//		packets: {
//			mob_data: {dur: adjust_to_fps(10), loop: 1, curr: 0, func: send_mob_data_packet},
//			game_state_data: {dur: adjust_to_fps(30), loop: 1, curr: 0, func: send_global_game_state_packet},
////			init_room_data: {dur: adjust_to_fps(60), loop: 1, curr: 0, func: send_room_init_packet_to_client},
////			quick_room_data: {dur: adjust_to_fps(10), loop: 1, curr: 0, func: send_room_quick_packet_to_client}
//		}
//	},
//	client: {
//		server_packet_timeouts: {},
//		packets: {}
//	},
//	both: {
//		per_step_logging: {
//			general_info: {dur: adjust_to_fps(60), loop: 1, curr:0, func: undefined}
//		},
//		packets: {
////			test: {dur: adjust_to_fps(60), loop: 1, curr: adjust_to_fps(60), func: test_send_packet}
//			pkun_info: {dur: adjust_to_fps(1), loop: 1, curr: 0, func: send_pkun_data_packet}
//		}
//	}
//}

//// Server state
//connected_clients = {} // socket to player_id
//client_ids = {} // player_id = [username, socket]

//server = -1

//// Client stuff
//self_player_id = -1
//other_players = {}
//username = generate_uuid4_string()

//client_authenticated = 0
//client_waiting_for_authentication = 1

//// other
//global_game_state_variables = ["clock_hr", "clock_min", "menu_mode"]

//packets_sent = 0
//packets_recieved = 0
//sent_packet_ids = []

//// sync shit
//network_object_instances = {} // is CLIENT_SOCK: {"obj_pkun": ID}

//targettable_objects = [
//	obj_pkun,
//	obj_network_object
//]
//object_sync_categories = {
//	"mob": [obj_p_mob]
//}
//object_var_names_to_sync = {
//	obj_pkun: ["sprite_index", "image_index", "dir", "x", "y", "immortal", "hscene_target", "hs_spr", "hs_ind", "hs_spd", "hiding", "flashOn", "running", "lp", "np", "intrTarget", "noclip", "intrDone", "intrNeed", "pressing_interact", "lifeloss_t", "lifeCur", "lifeMax", "charmed", "itemSlot"],
//	obj_p_mob: ["dir", "x", "y", "state", "doTrack", "target_x", "lost_pkun", "alp", "trace_x", "trace_y"]
//}

//has_complied_interact_instances = 0
//compiled_interactable_instances = {}
//occupied_hide_spots = []