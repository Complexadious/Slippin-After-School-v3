function cmd_bar_handle_key_press(key) {
	with (obj_sys) {
		switch key {
			//case ord("V"): {
			//	if keyboard_check(vk_control)
			//		global.command_bar_content = string_insert(clipboard_get_text(), global.command_bar_content, command_bar_txt_insert_pos)
			//	else
			//		global.command_bar_content = string_insert(keyboard_lastchar, global.command_bar_content, command_bar_txt_insert_pos)
			//	break;	
			//}
			case vk_backspace: { // i know im doing this dumb i dont give a FUCK!!
				global.command_bar_content = string_delete(global.command_bar_content, command_bar_txt_insert_pos - 1, 1)
				break;
			}
			case vk_left: {
				command_bar_cursor_offset++
				break;	
			}
			case vk_right: {
				command_bar_cursor_offset--
				break;	
			}
			default: {
				global.command_bar_content = string_insert(keyboard_lastchar, global.command_bar_content, command_bar_txt_insert_pos)
				break;
			}
		}
		command_bar_last_char = key
		keyboard_lastchar = ""
		global.key_delay = 4
	}
}

// execute commands for command bar
function cmd_execute_command(input) {
	if (input == "" || input == noone)
		return;

	var parts = string_split(input, " ", 1)
	var command = parts[0]
	
	array_delete(parts, 0, 1)
	var args = parts
	
	var msg = "Command Bar: " + input
	// execute
	switch (command) {
		case "heal": {
			global.lifeCur = global.lifeMax
			break;
		}
		case "summon": {
			var min_args = 4
			if (array_length(args) < min_args)
			{
				msg = "Error: Command 'summon' not enough args. (obj, x, y, depth)"
				break;
			}
			else
			{
				// evaluate
				var _x = (args[1] == "x") ? real(obj_pkun.x) : args[1]
				var _y = (args[2] == "y") ? real(obj_pkun.y) : args[2]
				args[1] = _x
				args[2] = _y
				
				var _eval = cmd_evaluate_args(args, ["object", "real", "real", "real"])
				if (_eval[1] != "")
					msg = "Command '" + command + "' " + _eval[1] // somethings wrong, its an error
				else
				{
					msg = "Summoned new " + string(_eval[0][0])
					instance_create_depth(_x, _y, _eval[0][3], _eval[0][0])
				}
			}
			break;
		}
		case "kill": {
			var min_args = 1
			var kill_count = 0
			var last_killed = "N/A"
			if (array_length(args) < min_args)
			{
				msg = "Error: Command 'kill' not enough args. (obj)"
				break;
			}
			else
			{
				// evaluate
				var target = ((args[0] == "all") || (args[0] == "@e")) ? "obj_p_mob" : args[0]
				args[0] = target
				
				var _eval = cmd_evaluate_args(args, ["object"])
				if (_eval[1] != "")
					msg = "Command '" + command + "' " + _eval[1] // somethings wrong, its an error
				else
				{
					with (_eval[0][0]) {
						kill_count++
						last_killed = object_get_name(object_index)
						instance_destroy()
					}
					var _suffix = (kill_count > 1) ? (string(kill_count) + " entities") : (last_killed)
					msg = "Killed " + _suffix
				}
			}
			break;
		}
		case "noclip": {
			toggle_pkun_noclip()
			break;
		}
		case "clip": {
			toggle_pkun_noclip(0)
			break;
		}
		case "speed": {
			var min_args = 0
			if (array_length(args) < min_args)
			{
				msg = "Error: Command 'speed' not enough args. (speed_multiplier)"
				break;
			}
			else
			{
				// evaluate
				var multiplier = (array_length(args) > 0) ? args[0] : 1
				
				var _eval = cmd_evaluate_args(multiplier, ["real"])
				if (_eval[1] != "")
					msg = "Command '" + command + "' " + _eval[1] // somethings wrong, its an error
				else
				{
					msg = "Set Pkun speed multipler to " + string(multiplier)
					obj_pkun.speed_multiplier = multiplier
				}
			}
			break;
		}
		case "immortal": {
			obj_pkun.immortal = infinity
			break;
		}
		case "mortal": {
			obj_pkun.immortal = 0
			break;
		}
		case "restart": {
			sys_game_restart()
			break;
		}
		case "charge": {
			global.flashPow = 100
			break;	
		}
		case "tp": {
			var min_args = 1
			var tp_count = 0
			var last_tped = "N/A"
			if (array_length(args) < min_args)
			{
				msg = "Error: Command 'tp' not enough args. (obj, x, y, dir (optional))"
				break;
			}
			else
			{
				// evaluate
				var target = ((args[0] == "all") || (args[0] == "@e")) ? "obj_p_mob" : args[0]
				args[0] = target
				var _x = (args[1] == "x") ? real(obj_pkun.x) : args[1]
				var _y = (args[2] == "y") ? real(obj_pkun.y) : args[2]
				
				args[1] = _x
				args[2] = _y
				
				var type_lists = ["object", "real", "real"]
				var contains_dir = (array_length(args) > 3)
				if (contains_dir)
					array_push(type_lists, "real")				
				
				var _eval = cmd_evaluate_args(args, type_lists)
				if (_eval[1] != "")
					msg = "Command '" + command + "' " + _eval[1] // somethings wrong, its an error
				else
				{
					with (_eval[0][0]) {
						tp_count++
						last_tped = object_get_name(object_index)
						x = _eval[0][1]
						y = _eval[0][2]
						if (contains_dir)
							dir = _eval[0][3]
					}
					var _suffix = (tp_count > 1) ? (string(tp_count) + " entities") : (last_tped)
					msg = "Teleported " + _suffix
				}
			}
			break;
		}
		case "func": {
			var min_args = 1
			if (array_length(args) < min_args)
			{
				msg = "Error: Command 'func' not enough args. (function_name, [args] (optional))"
				break;
			}
			else
			{
				// combine stuff if it is fucked up ya know
				var _fargs = ""
				for (var i = 1; i < array_length(args); i++) {
					_fargs += string(args[i])	
				}
				
				// make sure it starts and ends with brackets
				if (string_char_at(_fargs, 0) != "[") || (string_char_at(_fargs, string_length(_fargs)) != "]") {
					msg = "Error: Command 'func', provided function args aren't JSON formatted idiot"
					break;
				}
				
				var arg_array = (array_length(args) > 1) ? json_parse(_fargs) : []
				var func = variable_global_get(args[0])
				var msg = ""
				
				if (array_length(arg_array) == 1)
					arg_array = arg_array[0]
				show_debug_message("func executing args = " + string(arg_array))
				
				if !is_undefined(func)
					msg = string(args[0]) + ": " + string(script_execute(func, arg_array))
				else
					msg = "Error: Command 'func', function '" + string(args[0]) + "' doesn't appear to exist."
			}
			break;	
		}
	}
	// log
	obj_pkun.miniMsgStr = msg
	obj_pkun.miniMsgTmr = 300
}

function cmd_evaluate_args(args_to_eval, types, invalid_code=global.command_bar_evaluate_invalid_code) {
	// types are: object, string, real
	// it will convert args to their type, put INVALID_CODE if it is bad :(
	show_debug_message("EVALUATING COMMAND ARGUMENTS " + string(args_to_eval) + " WITH TYPES " + string(types))
	var arguments = array_length(args_to_eval)
	var evaluated_arguments = []
	
	for (var i = 0; i < arguments; i++) {
		// checking if type matches
		var arg = args_to_eval[i]
		var type = types[i]
		var _earg = invalid_code
		switch (type) {
			case "string": {
				_earg = string(arg)
			}
			case "real": {
				var s_l = string_length(string(arg))
				var d_l = string_length(string_digits(arg))
				
				// check if string contains "." or "-" for numbers :)
				for (var j = 0; j < s_l; j++)
					if (string_char_at(arg, j) == ".") || (string_char_at(arg, j) == "-") {d_l++;}
				
				if (s_l) == (d_l)
					_earg = real(arg)
			}
			case "object": {
				if (is_real(arg) && object_exists(arg)) // handle for ID
					_earg = arg
				else if ((is_string(arg)))
				{
					var object_id = asset_get_index(arg)
					if (object_id != -1)
						_earg = object_id
				}			
			}
		}
		
		// check if invalid, if it is then go crazy
		if _earg == invalid_code
		{
			var _msg = "Error: Arg " + string(i) + " (" + string(arg) + ") <" + string(typeof(arg)) + "> is not expected <" + type + ">"
			show_debug_message("EVALUATED, ERROR RETURNING " + _msg)
			return [noone, _msg]
		}
		array_push(evaluated_arguments, _earg)
	}
	show_debug_message("EVALUATED, RETURNING " + string([evaluated_arguments, ""]))
	return [evaluated_arguments, ""]
}

function toggle_command_bar()
{
	global.command_bar_content = ""
	obj_sys.command_bar_block_key_input = 1
	obj_sys.command_bar_history_mv_index = -1
	obj_sys.command_bar_cursor_offset = -1
	global.command_bar_open = !global.command_bar_open
	if global.command_bar_open
		keyboard_unset_map()
	else
		map_keys()
	show_debug_message("obj_sys Step: Command bar " + ((global.command_bar_open) ? "closed" : "opened"))
}

// Keyboard mapping
function map_keys() {
	keyboard_set_map(ord("W"), vk_up)
	keyboard_set_map(ord("A"), vk_left)
	keyboard_set_map(ord("S"), vk_down)
	keyboard_set_map(ord("D"), vk_right)
	keyboard_set_map(ord("Z"), vk_return)
	keyboard_set_map(vk_space, vk_return)
	keyboard_set_map(ord("X"), vk_backspace)
}

// check if number is between min and max and correct it if it is outside bounds
function check_num_wrap(_min, _max, val) {
	if (val > _max)
		return _max
	else if (val < _min)
		return _min
	else
		return val
}

function render_gui_editor() {
	return;	
}

function create_menu() constructor {
	return;	
}

function check_mouse_click_on_element() {
	return;	
}

function create_element(type, data = {}) constructor {
	show_debug_message("create_element: Creating element [" + type + "] with data \n<" + string(data) + ">")
	
	var constructed_element = {}
	var info_struct = {"type": type}
	var type_data_struct = {}
	
	// ex format
	
	// sprite element format:
	// {"source": "web" OR "sprite" OR "file", "sprite": "https://direct.image.link/image.png" OR spr_sprite OR progam_directory + "/images/sigma.png"}
	
	// video element format:
	// {"source": "web" OR "file", "video": "https://direct.video.link/video.mp4" OR program_directory + "/videos/sigma.mp4"}
	switch (type) {
		case "button": {
			// ex format: (info stores universal data between all things) (type_data is data specific to that type whether button or image)
			// {"info": {"type": "button", "position": [1, 1], "size": [100, 100], "visible": 1, "visibility_conditions": {"condition_type": "bool", "condition_require_value": 1"}}, "type_data": {""}}
			// type_data:
			// button_sprite: <SPRITE_ELEMENT_FORMAT>
			// button_hover_sprite: <SPRITE_ELEMENT_FORMAT>
			//struct_set(constructed_element)
			break;
		}
		case "image": {
			// type_data:
			// sprite: <SPRITE_ELEMENT_FORMAT>
			
			break;
		}
		case "video": {
			// type_data:
			// video_source_type: ONLY "file" (program_directory + '/videos/vid.mp4')
			// video_fps: <real> (fps to play video at, which is adjusted to gamespeed)
			// video_mute: <bool> (whether to play video audio or not)
			
			break;	
		}
		case "text": {
			// type_data:
			// text_content: <string> or <variable>
			// text_font: <fnt_reference>
			// text_size: <point size, real>
			// text_color: <color, c_white>
			// text_alignment: <string> ("left" OR "center" OR "right")
			// text_enable_markdown: <bool> (whether to interpret '**' and stuff for italics and bold)
			
			break;	
		}
		case "text_input": {
			break;
		}
	}
	struct_set(constructed_element, "info", info_struct)
	struct_set(constructed_element, "type_data", type_data_struct)
	
	return constructed_element
}

/// @description Checks if struct has needed names, and optionally if values are a specified type. Returns array [is_valid, error_message]
/// @param {struct} struct Struct to check
/// @param {array} names Array with names and value types, can be a string with just name in array. Ex. [["name1", "array"], "name2"] 
function validate_struct_names(struct, names, log = 0) {
	if (typeof(struct) != "struct") {
		return [0, "validate_struct_names: Provided struct argument is not <struct>, is <" + string(typeof(struct)) + ">"]
	}
	
	var err_msg = "validate_struct_names: Struct is invalid due to:"
	var err = err_msg
	
	var required_names = []
	array_copy(required_names, 0, names, 0, array_length(names))
	var missing_names = []
	array_copy(missing_names, 0, names, 0, array_length(names))

	// go through all required names and remove them from name list if they are present
	for (var i = array_length(required_names) - 1; i >= 0; i--) {
		// going over each name
		var _name = required_names[i]
		var _type = noone
		
		if (typeof(_name) == "array") {
			var len = array_length(_name)
			_type = ((len >= 2) && (_name[1] != "any")) ? _name[1] : noone
			_name = required_names[i][0]
		}
		
		// check if name exists
		if variable_struct_exists(struct, _name) {
			array_delete(missing_names, i, 1)
			
			// process type
			if ((_type != noone) && (typeof(struct[$ _name]) == _type)) { // if _type is not noone, then we check
//				show_debug_message("validate_struct_names: Type check for " + _name + ", type is correct! (" + string(_type) + ")")
			} else if (_type != noone) {
				// aint match BITCH
				err_msg += "\n- Name '" + _name + "' value type is incorrect. Expected <" + string(_type) + ">, got <" + typeof(struct[$ _name]) + ">"
			}
		}
	}
	
	if (array_length(missing_names) > 0) {
		for (var j = 0; j < array_length(missing_names); j++) {
			err_msg += "\n- Name '" + string(missing_names[j]) + "' doesn't exist in the struct."
		}
	}
	
	var _is_err = !(err_msg == err) // err_msg == err, if true, no error, false, error
	if (_is_err) && (log) // if true, we have error messages!
		show_debug_message(err_msg)
	return [!_is_err, (_is_err) ? err_msg : ""];
}

/// @description Tries to convert a value to a given type. Returns noone if it cant be converted.
/// @param {any} value Value to convert
/// @param {string} type Type to convert to ("string", "real")
function convert_to_type(value, type) {
	//types: string, real, number, object, sound, sprite, script, function, bool
	if can_be_converted_to_type(value, type) {
		switch (type) {
			case "string": {
				return string(value)	
			}
			default: {
				return real(value)	
			}
		}
	}
	else
		return noone
}

/// @description Checks if a value can be converted to a given type. Returns 1 if it can be converted, 0 if it can't.
/// @param {any} value Value to convert
/// @param {string} type Type to convert to ("string", "real")
function can_be_converted_to_type(value, type) {
	//types: string, real, number
	switch (type) {
		case ("string"): {
			return 1
			break;	
		}
		default: {
			// assume its number then
			if (typeof(value) == "real") || (typeof(value) == "number") {
				return 1
			}
			// it is a string then, check and see if it can be converted
			var char_cases = ["."] // chars if seen then add to _dl
			var seen_char_cases = []
			var _val = string(value) // make sure its a string
			var _l = string_length(_val) 
			var _dl = string_length(string_digits(_val)) // digits starting string length
			
			if (string_char_at(_val, 1) == "-")
				_dl++
			
			for (var i = 1; i <= _l; i++) {
				// loop through all string digits and check for char_cases
				var char = string_char_at(_val, i)
				if array_contains(char_cases, char) && !array_contains(seen_char_cases, char) { // add
					array_push(seen_char_cases, string_char_at(_val, i))
					_dl++
				}
			}
			
			return (_l == _dl) // can be converted or not
		}
	}
}

//function check_type_asset() {
//	asset_get_type()
//}

//function check_type(value, type) {
//	//types: string, real, number, object, sound, sprite, script, function, bool
//		// string and real types are simple. We need to do more stuff for other types!
//	if ((type == "string") || (type == "real"))
//		return type_of(value) 
//	switch (type) {
//		case "string": {
//			return 
//			break;	
//		}
		
//	}
//}

function gui_initalize_load_menu() {
	return 0;	
}

function gui_render_element(element) {
	return;
}

function gui_process_struct_value(value_struct) {
	var result = noone
	var _p = "gui_process_struct_value: "
	var err_msg = _p + "Unable to fetch value due to: "
	var err = err_msg
	
	if (typeof(value_struct) != "struct") {
		show_debug_message(_p + "provided value_struct argument is not <struct>, is <" + string(typeof(value_struct)) + ">")
		return value_struct
	}
	
	var validate = validate_struct_names(value_struct, global.gui_value_struct_format)
	if !(validate[0]) {
		show_debug_message(_p + "value struct is formatted incorrectly. Reasons: " + string(validate[1]))
		return -4
	}
	
	// [{"type": "menu_value", "value_type": "sprite", "source_type": "web", source: "x.y.z/img.png"}]
	var _type = value_struct[$ "type"]
	var _value_type = value_struct[$ "value_type"]
	var _source_type = value_struct[$ "source_type"]
	var _source = value_struct[$ "source"]
	
	if (_type != "menu_value") {
		show_debug_message(_p + "Provided value struct is not the right type. Expected type 'menu_value', got '" + string(_type) + "'")
		return -4	
	}
//	show_debug_message("testing!!! type = " + string(_type) + ", vtype = " + string(_value_type) + ", stype = " + string(_source_type) + ", source = " + string(_source))
	switch (_value_type) {
		case "sprite": {
			result = asset_get_index(_source)
			break;
		}
		case "global_variable": {
			if struct_exists(global, _source)
				result = global[$ _source]
			break;
		}
		case "instance_variable": { // source = "obj_hachi.sigma", inst var = sigma
			var split = string_split(_source, ".")
			var obj = split[0]
			var local_var = split[1]
			
			var _id = asset_get_index(obj)
			
			if (_id) && (asset_get_type(_id) == "object") {
				if instance_exists(_id) && variable_instance_exists(_id, local_var)
					result = _id[$ local_var]
				else
					err_msg += "\n- No instance of '" + string(obj) + "' exists."
				break;
			} else
				err_msg += "\n- Object name '" + string(obj) + "' doesn't correspond to an existing object."
			break;
		}
		case "text": {
			result = string(_source)
			break;
		}
	}
	// possible value struct types: sprite, video, text, global_variable
	// possible value struct source types: web, file, global_variable
	
	var _is_err = !(err_msg == err) // err_msg == err, if true, no error, false, error
	if (_is_err)// if true, we have error messages!
		show_debug_message(err_msg)
	show_debug_message(_p + "RESULT: " + string([result, (_is_err) ? err_msg : ""]))
	return [result, (_is_err) ? err_msg : ""];
}

function gui_download_web_data(url, type) {
	return -4
}
//function gui_load_type_sprite(sprite_strut) {
//	return sprite_strut
//}

//function gui_load_type_video(video_strut) {
//	return video_strut
//}