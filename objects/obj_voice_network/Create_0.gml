// Initialize the socket
global.transcript_socket = network_create_socket(network_socket_tcp);
global.transcript_server_ip = "127.0.0.1"; // Python server IP
global.transcript_server_port = 65432; // Python server port
global.transcript_connected = false;

// speaking stuff
global.current_volume = 0
global.speaking = false;

time_since_last_ping = 0
timeout_time = 300 // 5 seconds

only_one_action_at_a_time = 1

retry_time_steps = adjust_to_fps(30);
alarm[0] = retry_time_steps;

show_debug_message("obj_voice_network: Attempting to connect to the server...");

// trigger words or phrases and their respective actions
trigger_words = {
	"ninja": ["low taper fade", "taper fade", "low taper", "taper", "massive", "biggest meme", "paper fade", "tape or", "low tape", "low tip are fade", "low tip or fade", "tape or"],
	"cell": ["perfect", "cell", "sell", "selling"]
}

actions = {
	"ninja": {_spr: spr_ninja, _reveal_sound: -4, _spr_sound: se_low_taper_fade_1},
	"cell": {_spr: spr_realistic_cell, _reveal_sound: -4, _spr_sound: se_ultra_instinct_short}
}

function run_action(action_id) {
	var action = actions[$ action_id]
	if (action != -4) && (action != undefined) {
		if (only_one_action_at_a_time) && (instance_exists(obj_ui_flashbang))
			with (obj_ui_flashbang) {instance_destroy();}
		
		show_debug_message("obj_voice_network: Running action " + string(action_id))
		
		var fb = instance_create_layer(x, y, layer, obj_ui_flashbang)
		fb.spr = action._spr
		fb.reveal_sound = action._reveal_sound
		fb.spr_sound = action._spr_sound
	}
}

function process_transcription(transcription) {
	var _text = string_lower(transcription)
	
//	(string_pos("massive", text) > 0)
	// Check each action and each word in action
	for (var i = 0; i < struct_names_count(actions); i++) {
		var _trigger_actions = struct_get_names(trigger_words)
		var _trigger_action_name = _trigger_actions[i]
		var _words = trigger_words[$ _trigger_action_name]
		var _word_count = array_length(_words)
		
		// for each action
//		show_debug_message("in action " + string(_trigger_action_name) + " with words " + string(_words))

		// check each word
		for (var j = 0; j < _word_count; j++) {
//			show_debug_message("Checking word " + string(_words[j]) + " in action " + string(_trigger_action_name))
			if (string_pos(_words[j], _text)) {
//				show_debug_message("MATCH FOUND!! ACTION: " + string(_trigger_action_name))
				run_action(_trigger_action_name)
				break;
//			} else {
//				show_debug_message("No match in text: " + string(_text))
			}
		}
	}
		
//	for (var i; i < 20; i++) {
//		if (string_pos(word, text) > 0)
//			run_action(action)
//	}
}