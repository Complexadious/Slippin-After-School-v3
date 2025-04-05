globalvar logType;
logType = {
	info: {
		def :"INFO"
	},
	warning: {
		def: "WARNING",
		deprecated: "WARNING DEPRECATED",
		server_action_as_client: "WARNING SERVER_ACT_AS_CLIENT",
		not_multiplayer: "WARNING NOT_MULTIPLAYER"
	},
	error: {
		def: "ERROR",
		not_found: "ERROR NOT_FOUND"
	},
}
global.mob_sight_range = 4000
global.mob_reaction_time = 15
global.mob_force_switch_target_range = 2000
global.mob_updates_to_clients_on_different_floors = 1

global.last_synced = {
	clock_time: [-1, -1, -1, -1]
}
global.timeStop = 0
global.timeStopCanMove = 1

global_bstep = {}

global.multiplayer_packets_recieved = 0
global.multiplayer_packets_sent = 0
global.disable_game_keyboard_input = 0
global.draw_network_obj_hearts = 0

global.multiplayer_pkun_sync_hist = [0, 0, 1, 0, 0, 0, 0, 0, "", 0, 0] // X, Y, DIR, HS_MOB_ID, HS_STP, HS_CHECK, FLASH, FLASH_CHECK, MINI_MSG_STR, MINI_MSG_CHECK, HIDING
global.multiplayer_check_sent_last_pkun_pos = 0 // when we stop moving, send last update packet to make sure other pkun stops moving
global.skip_clock = 0

global.multiplayer_entity_sync_hist = {} // id: [x, y, dir, check_sent_last_pos]

// Network data types and data
var _dto = buffer_custom_datatype_start + 1
global.data_type = {
	boolean: {id: _dto, read: buffer_bool, write: buffer_bool},
	byte: {id: _dto + 1, read: buffer_s8, write: buffer_s8},
	ubyte: {id: _dto + 2, read: buffer_u8, write: buffer_u8},
	short: {id: _dto + 3, read: buffer_s16, write: buffer_s16},
	ushort: {id: _dto + 4, read: buffer_u16, write: buffer_u16},
	int: {id: _dto + 5, read: buffer_s32, write: buffer_s32},
	uint: {id: _dto + 6, read: buffer_u32, write: buffer_u32},
	long: {id: _dto + 7, read: buffer_s64, write: buffer_s64},
	ulong: {id: _dto + 8, read: buffer_u64, write: buffer_u64},
	fshort: {id: _dto + 9, read: buffer_f16, write: buffer_f16},
	fint: {id: _dto + 10, read: buffer_f32, write: buffer_f32},
	flong: {id: _dto + 11, read: buffer_f64, write: buffer_f64},
	varint: {id: _dto + 12, read: buffer_vint, write: buffer_vint},
	varlong: {id: _dto + 13, read: buffer_vlong, write: buffer_vlong},
	str: {id: _dto + 14, read: buffer_string, write: buffer_string},
	json_str: {id: _dto + 15, read: buffer_jstring, write: buffer_jstring},
	text: {id: _dto + 16, read: buffer_text, write: buffer_text},
	position: {id: _dto + 17, read: buffer_position, write: buffer_position},
	uuid: {id: _dto + 18, read: buffer_uuid, write: buffer_uuid},
	array: {id: _dto + 19, read: buffer_array, write: buffer_array},
	undefined: {id: _dto + 20, read: buffer_undefined, write: buffer_undefined},
	inf: {id: _dto + 21, read: buffer_inf, write: buffer_inf},
	pi: {id: _dto + 22, read: buffer_pi, write: buffer_pi},
	nan: {id: _dto + 23, read: buffer_nan, write: buffer_nan},
	struct: {id: _dto + 24, read: buffer_struct, write: buffer_struct},
}

// generate data_type ID lookup table shit for quick access
log("Generating Data Type Lookup Table")
global.data_type_lookup = {}
var _dtypes = struct_get_names(global.data_type)
for (var i = 0; i < struct_names_count(global.data_type); i++) {
	var _dt = global.data_type[$ _dtypes[i]]
	struct_set(global.data_type_lookup, _dt.id, _dt.read)
	show_debug_message("- Read constant for '" + string(_dtypes[i]) + "' is '" + string(_dt.read) + "'")
}

log("Data Type Lookup Table = " + string(global.data_type_lookup))
log("Generated Data Type Lookup Table")

var _test_nums = [1, 2, 4, 8, 16, 32, 64, 128, 256, -1, -2, -4, -6, -8, -10, -100, -0, -100.232, -124.26634543, 1/4, "string", []]
for (var i = 0; i < array_length(_test_nums); i++) {
	var val = _test_nums[i]
	var type = value_to_datatype(val)
	
	var _tbuff = buffer_create(8, buffer_fixed, 1)
	buffer_write_ext(_tbuff, type, val)
	buffer_seek(_tbuff, buffer_seek_start, 0)
	var _wval = buffer_read_ext(_tbuff)
	buffer_delete(_tbuff)
	
	show_debug_message("recommended data_type for '" + string(val) + "' is '" + string(type) + ",' converted is '" + string(_wval) + "'")	
}

// other test
//var __num = undefined
//var vintbuf = buffer_create(16, buffer_fixed, 1) //buffer_create(16, buffer_fixed, 1)
//buffer_seek(vintbuf, buffer_seek_start, 0)
//buffer_write_ext(vintbuf, buffer_undefined, __num)
//buffer_seek(vintbuf, buffer_seek_start, 0)
//show_debug_message("OTHER IS " + string(__num))
//show_debug_message("OTHER FR " + string(buffer_read_ext(vintbuf)))//buffer_read_ext(uuidbuf, buffer_uuid)))
//buffer_delete(vintbuf)

// struct test
//var __struct = {"a": 1, "b": "string", "c": undefined}
//var structbuf = buffer_create(16, buffer_grow, 1) //buffer_create(16, buffer_fixed, 1)
//buffer_seek(structbuf, buffer_seek_start, 0)
//buffer_write_ext(structbuf, buffer_struct, __struct)
//buffer_seek(structbuf, buffer_seek_start, 0)
//show_debug_message("STRUCT IS " + string(__struct))
//show_debug_message("STRUCT FR " + string(buffer_read_ext(structbuf)))//buffer_read_ext(uuidbuf, buffer_uuid)))
//buffer_delete(structbuf)

// varint test
//var __num = 5012
//var vintbuf = buffer_create(32, buffer_fixed, 1) //buffer_create(16, buffer_fixed, 1)
//buffer_seek(vintbuf, buffer_seek_start, 0)
//buffer_write_ext(vintbuf, buffer_vint, __num)
//buffer_seek(vintbuf, buffer_seek_start, 0)
//show_debug_message("VINT IS " + string(__num))
//show_debug_message("VINT FR " + string(buffer_read_ext(vintbuf)))//buffer_read_ext(uuidbuf, buffer_uuid)))
//buffer_delete(vintbuf)

// uuid test
//var _uuid = generate_uuid4_string()
//var uuidbuf = buffer_create(32, buffer_fixed, 1) //buffer_create(16, buffer_fixed, 1)
//buffer_seek(uuidbuf, buffer_seek_start, 0)
//buffer_write_ext(uuidbuf, buffer_uuid, _uuid)
//buffer_seek(uuidbuf, buffer_seek_start, 0)
//show_debug_message("UUID IS " + _uuid)
//show_debug_message("UUID 16 " + string(buffer_read_ext(uuidbuf)))//buffer_read_ext(uuidbuf, buffer_uuid)))
//buffer_delete(uuidbuf)

//var pos = [32767, 32767, 1, 0]
//var posbuf = buffer_create(32, buffer_fixed, 1)
//buffer_seek(posbuf, buffer_seek_start, 0)
//buffer_write_ext(posbuf, buffer_position, pos)
//buffer_seek(posbuf, buffer_seek_start, 0)
//show_debug_message("POS IS " + string(pos))
//show_debug_message("POS 32 " + string(buffer_read_ext(posbuf)))
//buffer_delete(posbuf)

//var buffer_id = buffer_create(1024, buffer_fixed, 1);
//var original_array = [infinity, NaN, pi];
//buffer_write_ext(buffer_id, buffer_array, original_array)//, schema);
//buffer_seek(buffer_id, buffer_seek_start, 0);
//var read_array = buffer_read_ext(buffer_id) //buffer_read_ext(buffer_id, buffer_array, schema, 1)//, buffer_array, schema);
//show_debug_message("Original Array: " + string(original_array));
//show_debug_message("Read Array: " + string(read_array) + "size = " + string(buffer_tell(buffer_id)));
//buffer_delete(buffer_id);

// Multiplayer menu state
multiplayer_menu_open = false;
username = "";
server_ip = "";
server_port = "";
menu_focus = 0; // 0 = username, 1 = IP, 2 = Port

// Create the downloader object
instance_create_depth(0, 0, 0, obj_web_asset_manager);

//if !instance_exists(obj_multiplayer_networking)
//	instance_create_layer(x, y, layer, obj_multiplayer_networking)

if ((instance_number(obj_sys) > 1))
{
    var first = instance_find(obj_sys, 0)
    if ((id != first))
    {
        instance_destroy()
        return;
    }
}

replace_stuff_in_strings(["test_blah|VAR|sigma|VAR|", "|WHAT THE FUCK|"], {"VAR": "VAL"}, "|")

global.delete_temp_dir_on_game_close = 1

// web asset stuff
test_url1 = "https://i1.sndcdn.com/artworks-kzJEP4OeBnRvXDOl-pXIuIg-t1080x1080.png" //"https://i1.sndcdn.com/artworks-4EUlEuDoyQKICttU-nj9N2w-t240x240.jpg"

global.web_asset_data_settings = {}
web_asset_data_init()

global.web_assets_path = program_directory + "temp/"
if !directory_exists(global.web_assets_path)
	directory_create(global.web_assets_path)

//download_file(test_url1, global.web_assets_path + "testfile.png", ["overwrite_existing_file"])
//create_web_asset(test_url1, "asset_sprite", "sigma")

//var elevenlabs_test_struct = {model_id: "eleven_multilingual_v2", text: "THIS IS A TEST!!! AAHASKLDASKDJ", voice_id: "9BWtsMINqrJLrRacOk9x"}
//create_web_asset("https://assets.jacqb.com/sigma/boy.png", "asset_elevenlabs_sound", "ai_voice_test", elevenlabs_test_struct)

global.gui_current_menu = -4
global.gui_editor_enabled = 0
global.gui_menu_struct_format = [["type", "string"], ["version", "number"], ["menu_identifier", "string"], "menu_title", ["menu_options", "struct"], ["elements", "array"]]
global.gui_value_struct_format = [["type", "string"], ["value_type", "string"], ["source_type", "string"], ["source", "string"]]

global.gui_menu_struct_ex = {"type": "menu", "version": 1.0, "menu_identifier": "menu_example_identifier", "menu_title": "Sigma Sigma Boy Menu", "menu_options": {"show_title": 0}, "elements": []}
global.gui_value_struct_ex = {"type": "menu_value", "value_type": "sprite", "source_type": "sprite", "source": "spr_hachi_idle"}

gui_process_struct_value(global.gui_value_struct_ex)

global.keybinds = {
	"freecamToggle": vk_insert,
	"commandBarOpenCommand": 191,
	"commandBarOpenChat": ord("T"),
	"attemptMobControl": ord("C")
}

global.camera_hide_ui = 0

global.disable_game_keyboard_input = 1

global.command_bar_open = 0
global.command_bar_content = ""
global.command_bar_help_text = "Enter a Command"
global.command_bar_single_word_commands = [""]
global.command_bar_cleared = 0
global.command_bar_evaluate_invalid_code = "//*INVALID"
global.command_bar_history = []
command_bar_history_mv_index = -1
command_bar_cursor_offset = -1 //string_insert()
command_bar_txt_insert_pos = 0
command_bar_blinking_cursor_tmr = 30
command_bar_blinking_cursor_state = 0
command_bar_curr_text = ""
command_bar_backspace_tmr = 30
command_bar_backspace_tmr_timeout = 2
command_bar_block_key_input = 1

command_bar_last_char = -4
command_bar_hold_key_tmr = 30
command_bar_hold_key_tmr_timeout = 2

global.dialog_disable_acts = true
global.freecam_highlight_mobs = 1
global.freecam_highlight_color = c_green

global.apply_settings_on_change = 1
global.forest_raining = false
global.settings = []
global.stage_settings = [] // new stage settings
global.settings_page = 0
global.max_settings_lines_per_page = 7

// voice transcription settings
global.enable_voice_transcription = 0
global.enable_voice_transcription_flashbangs = 1
global.voice_transcription_inst = -4
global.speaking = false;
global.speech_detection_sensitivity = 0.2
global.voice_transcription_file_src_url	 = 

show_debug_message("Gamemaker Program Directory: " + string(program_directory))
show_debug_message("Gamemaker Working Directory: " + string(working_directory))

// baldi
global.baldi_speed = 1
global.baldi_notebook_count = 0
global.baldi_notebook_answered = 0
global.baldi_notebook = -4

addStageSetting("baldi_speed", 1)

//// Options (last argument in addSetting):
    // changeInGame: (bool) Determines if the setting can be changed during gameplay. Default: true.
    // sett_k: (string) The displayed name of the setting in the UI. Defaults to the display_name parameter.
    // sett_v: (any) The value displayed for the setting. Defaults to the current value of the global variable (_val).
    // maxNum: (real) The maximum allowable value for the setting (required if the type is "range").
    // minNum: (real) The minimum allowable value for the setting (required if the type is "range").
    // changeRate: (real) The increment or decrement amount for the setting when adjusted. Default: 1.
    // type: (string) The type of the setting:
    //       - "range": Represents a numerical range (e.g., brightness 0-100).
    //       - "bool": Represents a toggle (on/off, true/false).
    // keyDelay: (bool) Determines if holding down a key repeatedly changes the setting. Default: false.
    // askConfirm: (bool) Specifies if the setting should prompt a "Are you sure?" confirmation before applying changes. Default: false.
    // sett_v_cases: (array) Defines specific display values for certain numeric cases (e.g., [0, "OFF"], [1, "ON"]).
    // loop: (bool) Specifies if the setting should loop back to min when max is exceeded and vice versa. Default: false.
	
addSetting("Custom_Settings", "Forest Raining", "forest_raining", 0, "Custom_Settings.ini", {changeInGame: 0, keyDelay: 0})
addSetting("Custom_Settings", "Speech Detection Sensitivity", "speech_detection_sensitivity", 0.2, "Custom_Settings.ini", {type: "range", changeInGame: 1, keyDelay: 0, minNum: 0.00, maxNum: 1.00, changeRate: 0.05})
//addSetting("Custom_Settings", "Ballin", "ballin", 1, "Custom_Settings.ini", {changeInGame: 1, type: "bool", sett_v_cases: [[0, "OFF"], [1, "ON"]], askConfirm: 1})
addSetting("Graphics", "Gamespeed (FPS)", "gamespeed_fps", 60, "Graphics_Settings.ini", {changeInGame: 0, type: "range", maxNum: 240, minNum: 30, keyDelay: 0, changeRate: 2, askConfirm: 0})
addSetting("Graphics", "Vsync (Buggy)", "enable_vsync", 0, "Graphics_Settings.ini", {type: "bool", askConfirm: 1, sett_v_cases: [[0, "Disabled"], [1, "Enabled"]]})
addSetting("Debug", "Show Mob Traces", "show_mob_traces", 1, "DebugSettings.ini", {type: "bool", askConfirm: 0, sett_v_cases: [[0, "Disabled"], [1, "Enabled"]]})
addSetting("Debug", "Mob Trace Count", "mob_trace_count", 4, "DebugSettings.ini", {type: "range", askConfirm: 0, minNum: 0, maxNum: 100, keyDelay: 1, changeRate: 1})
addSetting("Debug", "Mob Trace Forget Chance (%)", "mob_trace_forget_chance", 30, "DebugSettings.ini", {type: "range", askConfirm: 0, minNum: 0, maxNum: 100, keyDelay: 0, changeRate: 5})
addSetting("Graphics", "Censor", "enable_nsfw", 0, "Graphics_Settings.ini", {type: "bool", askConfirm: 1, sett_v_cases: [[0, "Enabled"], [1, "Disabled"]]})
addSetting("Graphics", "Censor Mode", "nsfw_censor_mode", 0, "Graphics_Settings.ini", {type: "range", askConfirm: 0, minNum: 0, maxNum: 2, keyDelay: 1, sett_v_cases: [[0, "Box"], [1, "Outline"], [2, "Alt Sprite"]]})

// get rid of nsfw stuff just in case
global.nsfw_sprites = [
    spr_doppel_h1,
    spr_doppel_c1,
	spr_doppel_appear,
    spr_hachi_c2,
    spr_hachi_h1,
    spr_hachi_h2,
    spr_hachi_idle,
    spr_hachi_walk,
    spr_hanako_hs_a,
    spr_hanako_hs_a_cum,
    spr_hanako_hs_b,
    spr_hanako_hs_b_c,
    spr_hanako_hs_c_blow1,
    spr_hanako_hs_c_blow2,
    spr_hanako_hs_c_cum,
    spr_hanako_hs_c_lick,
    spr_hanako_hs_d_blow,
    spr_hanako_hs_d_cum,
    spr_hanako_idle,
    spr_jianshi_down_seal,
    spr_jianshi_hs_cum,
    spr_jianshi_hs_sex,
    spr_jianshi_jump,
    spr_jianshi_jump_seal,
    spr_kuchi_h_a,
    spr_kuchi_h_a_cum,
    spr_kuchi_idle,
    spr_kuchi_run,
    spr_ladypaint_hs_bj,
    spr_ladypaint_hs_cum,
    spr_ladypaint_idle,
    spr_ladypaint_walk,
    spr_mary_c,
    spr_mary_h,
    spr_pianist_h,
    spr_pianist_h_c,
    spr_police_go,
    spr_police_hs_a,
    spr_police_hs_a_cum,
    spr_police_hs_res,
    spr_police_idle,
    spr_police_stop,
    spr_sfx_0,
    spr_sfx_1,
    spr_sfx_2,
    spr_wpangel_hs_cum,
    spr_wpangel_hs_dwn,
    spr_wpangel_hs_res,
    spr_wpangel_hs_sex,
    spr_wpangel_idle,
	spr_pianist_h,
	spr_pianist_h_c,
	spr_pianist_play,
	spr_pianist_stop
];

global.nsfw_censor_mask_sprite = spr_missing
global.nsfw_alt_sprite = spr_h_figure //spr_h_figure

//addSetting("Graphics", "Brightness", "brightness", 100, "Graphics_Settings.ini", {changeInGame: true, maxNum: 200, minNum: 0, changeRate: 10, type: "range", askConfirm: 1});
//addSetting("Audio", "Master Volume", "master_volume", 80, "Audio_Settings.ini", {changeInGame: true, maxNum: 100, minNum: 0, changeRate: 5, type: "range"});
//addSetting("Gameplay", "Difficulty Level", "difficulty_level", 1, "Gameplay_Settings.ini", {
//    changeInGame: true,
//    type: "range",
//    sett_v_cases: [[0, "Easy"], [1, "Normal"], [2, "Hard"], [3, "Expert"]],
//    maxNum: 3,
//    minNum: 0,
//    changeRate: 1,
//	loop: 1
//});
//addSetting("Accessibility", "Subtitles", "subtitles", 1, "Accessibility_Settings.ini", {changeInGame: true, type: "bool", sett_v_cases: [[0, "OFF"], [1, "ON"]]});
//addSetting("Graphics", "Motion Blur", "motion_blur", 0, "Graphics_Settings.ini", {changeInGame: true, type: "bool", sett_v_cases: [[0, "Disabled"], [1, "Enabled"]]});
//addSetting("Audio", "Music Genre", "music_genre", 0, "Audio_Settings.ini", {
//    changeInGame: true,
//    type: "range",
//    sett_v_cases: [[0, "Classical"], [1, "Jazz"], [2, "Rock"], [3, "Electronic"]],
//    maxNum: 3,
//    minNum: 0,
//    changeRate: 1
//});
//addSetting("Graphics", "Screen Resolution", "screen_resolution", 1, "Graphics_Settings.ini", {
//    changeInGame: false,
//    type: "range",
//    sett_v_cases: [[0, "1280x720"], [1, "1920x1080"], [2, "2560x1440"], [3, "3840x2160"]],
//    maxNum: 3,
//    minNum: 0,
//    changeRate: 1
//});
//addSetting("Gameplay", "Auto-Save Interval", "auto_save_interval", 10, "Gameplay_Settings.ini", {changeInGame: true, maxNum: 60, minNum: 5, changeRate: 5, type: "range"});
//addSetting("Input", "Controller Vibration", "controller_vibration", 1, "Input_Settings.ini", {changeInGame: true, type: "bool", sett_v_cases: [[0, "OFF"], [1, "ON"]]});
//addSetting("General", "Language", "language", 0, "General_Settings.ini", {
//    changeInGame: false,
//    type: "range",
//    sett_v_cases: [[0, "English"], [1, "Spanish"], [2, "French"], [3, "German"]],
//    maxNum: 3,
//    minNum: 0,
//    changeRate: 1
//});
//addSetting("Graphics", "Field of View", "fov", 90, "Graphics_Settings.ini", {changeInGame: true, maxNum: 120, minNum: 60, changeRate: 5, type: "range"});


global.custom_settings_count = array_length(global.settings);
global.max_settings_pages = ceil(global.custom_settings_count / global.max_settings_lines_per_page)
global.setting_ind = 0
global.custom_settings_ui_index = (global.settings_page * global.max_settings_lines_per_page) + (global.setting_ind - global.max_settings_lines_per_page)

global.gamespeed_fps = 60
global.enable_vsync = 0

image_speed = 0.125
depth = -9999999

global.ui_spectate_list_index = 0
global.obj_cam_vx = 0
global.obj_cam_vy = 0

global.pkun_frozen = 0

map_keys()

global.game_dir = program_directory
global.title_msg = "Made By Dottoru(v1.0.0) (PORT!! Expect bugs!)"
sys_load_setting()
loadTextFile()
global.game_debug = -1
global.game_is_over = 0
gio_t = 0
global.key_delay = 0
global.bgm_curr = -4
global.bgm_prev = -4
global.transition = 0
global.trans_goto = -4
global.trans_wait = 0
global.trans_alp = 0.9
global.trans_spd = adjust_to_fps(0.01)
global.trans_col = 0
global.hscene_target = -4
global.hscene_hide_fl = 0
mob_id = 0
global.dialog_show_box = 0
global.dialog_acting = 0
global.dialog_mode = 0
global.dialog_name = ""
global.dialog_line = ""
global.dialog_hs_next = 0
global.dialog_hs_id = 0
global.dialog_num_curr = 1
global.dialog_num_total = 0
global.dialog_spr = spr_null
global.dialog_goto = -4
global.dialog_choice_opt1 = ""
global.dialog_choice_opt2 = ""
global.dialog_choice_out = ""
global.dialog_se = -4
global.dialog_se_instance = -4
global.dialog_played_se = 0
global.dialog_se_start_delay = 0
global.dialog_text_reveal_time = 0.5
dialog_choice_ind = 1
dialog_char = 0
dialog_skip = 0
dialog_fskip = 0
global.dialog_do_fskip = 1
global.mini_dialog_line = ""
mini_dialog_timer = 0
mini_dialog_scl = 0
mini_dialog_scl_to = 0
mini_dialog_char = 0
global.bell_timer = 0
global.bell_count = 0
global.menu_mode = 0
global.menu_ind = 0
menu_alp = 0
global.setting_mode = 0
global.setting_ask = 0
global.enable_ui_cutter = 1
clock_init()
memo_ind_curr = 0
memo_move = 0
memo_dir = 0
itemScale[0] = 100
itemScale[1] = 100
itemDescI = 0
itemDescA = 0
global.itemSwap = 0
sys_init_stage()
sys_load_player()

if (global.enable_voice_transcription)
	global.voice_transcription_inst = instance_create_layer(x, y, layer, obj_voice_network);