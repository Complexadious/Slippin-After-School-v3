function log(msg, type = logType.info.def, src = "UNKNOWN") {
	var _t = string_upper(string(type))
	if ((self) && (struct_exists(self, "object_index")))
		src = (object_get_name(object_index)) + "/" + src
	var _ts = "[" + string(current_hour) + "H:" + string(current_minute) + "M:" + string(current_second) + "S:" + string(current_time) + "] "
	show_debug_message(_ts + "[" + src + "] [" + string(type) + "]: " + string(msg))	
}

function flip_bool(argument0) {
	if (argument0) return 0; // flip to 0
	else return 1; // flip to 1
}

function adjust_to_fps(argument0) {
	var _adjustment = (60 / global.gamespeed_fps)
//	show_debug_message("_adjustment = " + string(_adjustment))
	return (_adjustment * argument0)
}

// start voice server, first
//function load_voice_server() {
//	global.voice_transcription_file_src_url	
//}

function min_num_bit_count(num) {
	return int64(logn(2, abs(num)) + 1) + (num < 0)
}

function value_to_datatype(value) {
	switch typeof(value) {
		case "number": {
			var _bits = min_num_bit_count(value)
			if (frac(value) == 0) {
				if (value >= 0) { // is positive
					if (value <= (2^32 - 1))
						return buffer_vint
					else
						return buffer_vlong
				} else { // it is negative
					if ((value * -1) <= (2^8 / 2))
						return buffer_s8
					else if ((value * -1) <= (2^16 / 2))
						return buffer_s16
					else if ((value * -1) <= (2^32 / 2))
						return buffer_s32
					else if ((value * -1) <= (2^64 / 2))
						return buffer_s64
				}
			} else { // is a fraction
				/* i really dont wanna do the thinking for this, so just make it a damn double or some shit
				 lets just round it to 4096 precision
				 nvm just do buffer_f32 for now */
				return buffer_f32
			}
		}
		case "string": {
			return buffer_string
		}
		case "array": {
			return buffer_array	
		}
		case "bool": {
			return buffer_bool
		}
		case "int32": {
			return buffer_s32	
		}
		case "int64": {
			return buffer_s64	
		}
		case "ptr": {
			return buffer_undefined
		}
		case "undefined": {
			return buffer_undefined	
		}
		case "null": {
			return buffer_undefined	
		}
		case "method": {
			return buffer_undefined	
		}
		case "struct": {
			// check if it is custom dt wrapper shit
			if is_dt_wrapper(value)
				return value.__data_type
			return buffer_undefined	
		}
		case "ref": {
			return buffer_u64
		}
		default: {
			return buffer_undefined	
		}
	}
}

function id_to_datatype(id) {
	if (id >= buffer_custom_datatype_start) // within data_type enum range
		return global.data_type_lookup[$ id]
	return id
}

function buffer_read_ext(buffer_id, type = undefined, schema = undefined, skip = 0) {
    var value;
    var position = 0;
    var currentByte;
	
	if skip
		buffer_seek(buffer_id, buffer_seek_relative, BUFFER_DT_ID_TYPE_BYTES)
    
    switch type {
		case undefined: {
			// assume the next byte is the ID
			
			// check if we are still within bounds
			var _buffsize = buffer_get_size(buffer_id)
			if (buffer_tell(buffer_id) >= _buffsize ) {
				show_debug_message("TRIED READING OUTSIDE OF BUFFER RANGE!!!!! WTF!!!!!")
				exit;	
			}
			
			var _byte = buffer_read(buffer_id, BUFFER_DT_ID_TYPE)
			var _id = id_to_datatype(_byte)
//			show_debug_message("buffer_read_ext: type is undefined. read dt id is " + string(_id) + ", _byte is " + string(_byte))
			return buffer_read_ext(buffer_id, _id)
		}
        case buffer_vint: {
            value = 0;
            while (true) {
                currentByte = buffer_read(buffer_id, buffer_u8);
                value |= (currentByte & BUFFER_SEGMENT_BITS) << position;
                if ((currentByte & BUFFER_CONTINUE_BIT) == 0) break;
                position += 7;
                if (position >= 32) show_error("Error reading varint, it's too big!!", 1);
            }
            return value;
        }
        case buffer_vlong: {
            value = int64(0); // Ensure value is 64-bit
            while (true) {
                currentByte = buffer_read(buffer_id, buffer_u8);
                value |= int64(currentByte & BUFFER_SEGMENT_BITS) << position;
                if ((currentByte & BUFFER_CONTINUE_BIT) == 0) break;
                position += 7;
                if (position >= 64) show_error("Error reading varlong, it's too big!!", 1);
            }
            return value;
        }
		case buffer_s64: {
			return int64(buffer_read(buffer_id, buffer_u64))
		}
		case buffer_jstring: {
			try {
				value = json_parse(buffer_read(buffer_id, buffer_string))
			} catch(e) {
				value = "??JSON_READ_ERR: " + string(e) + "??"
			}
			return value	
		}
		case buffer_position: {
			/*
			X: 14 bits (16384)
			DX: 4 bits (16)
			Y: 13 bits (8192)
			DIR: 1 bit (1)
			*/
			
			value = int64(buffer_read(buffer_id, BP_BDT))
			
			var total_bits = BP_DX_ALLOCATION + BP_Y_ALLOCATION + BP_DIR_ALLOCATION
			var _x = logical_rshift(value, total_bits); total_bits -= BP_DX_ALLOCATION
			var _dx = (logical_rshift(value, total_bits) & int64(power(2, BP_DX_ALLOCATION) - 1)); total_bits -= BP_Y_ALLOCATION
			var _y = (logical_rshift(value, total_bits) & int64(power(2, BP_Y_ALLOCATION) - 1)); total_bits -= BP_DIR_ALLOCATION
			var _dir = (logical_rshift(value, total_bits) & int64(power(2, BP_DIR_ALLOCATION) - 1));
			//var _aw = (logical_rshift(value, total_bits) & int64(power(2, BP_AW_ALLOCATION) - 1)); total_bits -= BP_FLASH_ALLOCATION
			//var _flash = (logical_rshift(value, total_bits) & int64(power(2, BP_FLASH_ALLOCATION) - 1));
			
			// make _dir 1 or -1
			if (_dir != 1) _dir = -1;
			
			return [_x, _dx, _y, _dir]
		}
		case buffer_uuid: {
			var uuid = ""
			for (var i = 0; i < 16; i++) {
				var _h = (i == 3 || i == 5 || i == 7 || i == 9) ? "-" : ""
				var _v = dec_to_hex(buffer_read(buffer_id, buffer_u8))
				_v = (string_length(_v) > 1) ? _v : ("0" + _v)
				uuid += _v + _h
			}
			return uuid	
		}
		case buffer_array: {
			// array len
			var _len = buffer_read_ext(buffer_id)
			var _array = []
			show_debug_message("buffer_read_ext: ARRAY LEN IS " + string(_len))
			for (var i = 0; i < _len; i++) {
				array_push(_array, buffer_read_ext(buffer_id))
			}
			
			return _array
	    }
		case buffer_undefined: {
			return undefined	
		}
		case buffer_inf: {
			return infinity	
		}
		case buffer_pi: {
			return pi	
		}
		case buffer_nan: {
			return NaN	
		}
        default: {
            return buffer_read(buffer_id, type);
        }
    }
}

function buffer_write_ext(buffer_id, type, value, schema = undefined) {
	switch type {
		case buffer_vint: {
			buffer_write(buffer_id, BUFFER_DT_ID_TYPE, global.data_type.varint.id)
		    while (true) {
		        if ((value & ~BUFFER_SEGMENT_BITS) == 0) {
		            buffer_write(buffer_id, buffer_u8, value);
		            return;
		        }

		        buffer_write(buffer_id, buffer_u8, ((value & BUFFER_SEGMENT_BITS) | BUFFER_CONTINUE_BIT))

		        // Note: >>> means that the sign bit is shifted with the rest of the number rather than being left alone
		        value = logical_rshift(value, 7)
		    }
			break;
		}
		case buffer_vlong: {
			buffer_write(buffer_id, BUFFER_DT_ID_TYPE, global.data_type.varlong.id)
			value = int64(value)
		    while (true) {
		        if ((value & ~BUFFER_SEGMENT_BITS) == 0) {
		            buffer_write(buffer_id, buffer_u8, value);
		            return;
		        }

		        buffer_write(buffer_id, buffer_u8, ((value & BUFFER_SEGMENT_BITS) | BUFFER_CONTINUE_BIT))

		        // Note: >>> means that the sign bit is shifted with the rest of the number rather than being left alone
		        value = logical_rshift(value, 7)
		    }
			break;
		}
		case buffer_s64: {
			buffer_write(buffer_id, BUFFER_DT_ID_TYPE, global.data_type.long.id)
			buffer_write(buffer_id, buffer_u64, int64(value))
			break;
		}
		case buffer_jstring: {
			buffer_write(buffer_id, BUFFER_DT_ID_TYPE, global.data_type.json_str.id)
			try {
				value = json_stringify(value)
			} catch(e) {
				value = "??JSON_WRITE_ERR: " + string(e) + "??"
			}
			buffer_write(buffer_id, buffer_string, value)
			break;
		}
		case buffer_position: {
			buffer_write(buffer_id, BUFFER_DT_ID_TYPE, global.data_type.position.id)
			//make value[2] (dir) either a 1 or a 0
			if (value[3] > 1) value[3] = 1;
			if (value[3] < 0) value[3] = 0;
			
			/*
			X: 14 bits (16384)
			DX: 4 bits (16)
			Y: 13 bits (8192)
			DIR: 1 bit (1)
			*/
			
			var total_bits = BP_DX_ALLOCATION + BP_Y_ALLOCATION + BP_DIR_ALLOCATION //+ BP_AW_ALLOCATION + BP_FLASH_ALLOCATION
			var _pos = int64(0)
			var _x = int64(value[0]); _pos |= _x << (total_bits)
			var _dx = int64(abs(value[1])); total_bits -= BP_DX_ALLOCATION; _pos |= _dx << (total_bits)
			var _y = int64(value[2]); total_bits -= BP_Y_ALLOCATION; _pos |= _y << (total_bits)
			var _dir = int64(value[3]); total_bits -= BP_DIR_ALLOCATION; _pos |= _dir << (total_bits)
//			var _aw = int64(value[3]); total_bits -= BP_AW_ALLOCATION; _pos |= _aw << (total_bits)
//			var _flash = int64(value[4]); total_bits -= BP_FLASH_ALLOCATION; _pos |= _flash << (total_bits)
			buffer_write(buffer_id, BP_BDT, _pos)
			break;
		}
		case buffer_uuid: {
			buffer_write(buffer_id, BUFFER_DT_ID_TYPE, global.data_type.uuid.id)
			value = string_replace_all(value, "-", "")
			for (var i = 0; i < (string_length(value) / 2); i++) {
				var pair = "0x" + string_char_at(value, (i * 2) + 1) + string_char_at(value, (i * 2) + 2)
				buffer_write(buffer_id, buffer_u8, real(pair))
			}
			break;
		}
		case buffer_array: {
			buffer_write(buffer_id, BUFFER_DT_ID_TYPE, global.data_type.array.id)
			// array len
			var _len = array_length(value)
			buffer_write_ext(buffer_id, buffer_vint, _len)
			
			for (var i = 0; i < _len; i++) {
				var _dt = value_to_datatype(value[i])
				var _val = value[i]
				
				// properly get value if dt_wrapper
				if is_dt_wrapper(_val) {
					show_debug_message("buffer_write_ext: Writing a DT_WRAPPER value!!")	
					_val = _val.__data
				}
				
				if (is_array(schema)) {
					if (is_array(_val)) && (array_length(schema) == array_length(_val)) {
						// write each value to buffer
						for (var j = 0; j < array_length(_val); j++) {
							buffer_write_ext(buffer_id, schema[j], _val[j])		
						}
						continue;
					} else {
						show_debug_message("buffer_write_ext: Cannot write this array! Schema and Val are incompatible!")	
					}
				} else if (schema != undefined) {
					_dt = schema // all same dt
				}
				
				buffer_write_ext(buffer_id, _dt, _val)	
			}
			
			exit;
		}
		case buffer_undefined: {
			buffer_write(buffer_id, BUFFER_DT_ID_TYPE, global.data_type.undefined.id)
			break;
		}
		case buffer_inf: {
			buffer_write(buffer_id, BUFFER_DT_ID_TYPE, global.data_type.inf.id)
			break;
		}
		case buffer_pi: {
			buffer_write(buffer_id, BUFFER_DT_ID_TYPE, global.data_type.pi.id)
			break;
		}
		case buffer_nan: {
			buffer_write(buffer_id, BUFFER_DT_ID_TYPE, global.data_type.nan.id)
			break;
		}
		default: {
			buffer_write(buffer_id, BUFFER_DT_ID_TYPE, type);
			buffer_write(buffer_id, type, value);
			break;
		}
	}
}

function hex_lookup(num) {
	if (num > 15)
		return "?" + string(num) + "?"
	return string_char_at("0123456789ABCDEF", num + 1)
}

function logical_rshift(value, shift) {
    return (value & $FFFFFFFF) >> shift;
}

function string_region(str, start_pos, end_pos) {
	if (str == "") || (str == -4)
		return ""
	
	var str_region = ""
	
	for (var i = start_pos; i <= end_pos; i++) {
		str_region += string_char_at(str, i)	
	}
	
	return str_region
}

function string_array(str) {
	var len = string_length(str)
	var arr = []
	for (var i = 0; i <= len; i++) {
		array_push(arr, string_char_at(str, i))
	}
	return arr
}

function key_delay() {
	return !(global.key_delay <= 0)	
}

function generate_uuid4_string() {
    //As per https://www.cryptosys.net/pki/uuid-rfc4122.html
    //FIXME - Do this without random()/choose() calls
    var _UUID = sha1_string_utf8(string(current_time) + string(date_current_datetime()) + string(random(0xFFFFFF)));
        _UUID = string_set_byte_at(_UUID, 9,  0x2D)
        _UUID = string_set_byte_at(_UUID, 14, 0x2D)
        _UUID = string_set_byte_at(_UUID, 19, 0x2D)
        _UUID = string_set_byte_at(_UUID, 24, 0x2D)
    
        _UUID = string_delete(_UUID, 37, 4)
        _UUID = string_upper(_UUID)
    
        _UUID = string_set_byte_at(_UUID, 15, 0x34);
        _UUID = string_set_byte_at(_UUID, 20, choose(0x38, 0x39, 0x41, 0x42));
    
    return _UUID;
}

function forcefully_clear_struct(struct, replace_with = {}) {
	var names = struct_get_names(struct)
	
	for (var i = 0; i < struct_names_count(struct); i++) {
		struct_remove(struct, names[i])	
	}
	
	if (replace_with != {}) {
		var names = struct_get_names(replace_with)
		for (var j = 0; j < struct_names_count(replace_with); j++) {
			var name = names[j], value = replace_with[$ name]
			struct_set(struct, name, value)
		}
	}
}

function read_binary_file_extension(file_path) {
	if !file_exists(file_path)
		return -4;
		
	var bytes = ""
	var byte_count_to_read = 16
	
	var file = file_bin_open(file_path, 0)
	for (var i = 0; i < byte_count_to_read; i++) {
		file_bin_seek(file, i)
		bytes += string(dec_to_hex(file_bin_read_byte(file)))
	}
	file_bin_close(file)

	return bytes
//	switch binary {
//		case 	
//	}
}

function dec_to_hex(dec_num) {
    if (dec_num == 0) {
        return "0";
    }

    var hex_chars = "0123456789ABCDEF";
    var hex_result = "";

    while (dec_num > 0) {
        var remainder = floor(dec_num % 16);
        dec_num = floor(dec_num / 16);
        var hex_digit = string_char_at(hex_chars, remainder + 1);
        hex_result = hex_digit + hex_result;
    }

    return hex_result;
}

function array_to_string(array, delim = "") {
	var str = ""
	for (var i = 0; i < array_length(array) - 1; i++) {
		var d = (i == array_length(array) - 1) ? "" : delim
		str += string(array[i]) + string(d)
	}
	show_debug_message("ARRAY_TO_STRING: " + str)
	return str
}

function string_reverse(str) {
	return array_to_string(array_reverse(string_array(str)))
}

function log_msg_prefix() {
	return "[" + string(date_current_datetime()) + "] "
}

function array_contains_count(array, value, return_array_of_locations = 0) {
	var appearances = 0
	var spots = []
	var pos = 0
	
	for (var i = 0; i < array_length(array); i++) {
		if (array[i] == value) {
			appearances++
			if return_array_of_locations
				array_push(spots, i)
		}
	}
	
	return (return_array_of_locations) ?? appearances
}

function uuid_to_binary(uuid) {
	buf = buffer_create(16, buffer_fixed, 1)
	uuid = string_replace_all(uuid, "-", "")
	for (var i = 0; i < (string_length(uuid) / 2); i++) {
		var pair = "0x" + string_char_at(uuid, (i * 2) + 1) + string_char_at(uuid, (i * 2) + 2)
		buffer_write(buf, buffer_u8, real(pair))
	}
	return buf
}

function binary_to_uuid(binary) {
	exit;
}

/// @function array_without
/// @param {array} array Array to copy without value
/// @param {any} value Value to exclude from array (Can be an array of values)
/// @description Returns copy of provided array without specified value
function array_without(array, value) {
	if !is_array(value)
		value = [value]
	
	var _arr = []
	for (var i = array_length(array) - 1; i >= 0; i--) {
		if (!array_contains(value, array[i]))
			array_push(_arr, array[i])
	}
	return _arr
}

function play_se_at(se, x, y) {
	if (se == -4) {
		show_debug_message("play_se_at(" + string(se) + ", " + string(x) + ", " + string(y)+ "): Attempted to play -4 as sound! Cancelling!")
		exit;
	}
	if !instance_exists(obj_pkun) {
		play_se(se, 1)
		exit;
	}
    audio_falloff_set_model(4)
	var _near = (!(collision_line(x, y, obj_pkun.x, obj_pkun.y, obj_wall, false, false)));
    if _near
    {
        var _se = audio_play_sound_at(se, (obj_pkun.x + (obj_pkun.x - x)), y, 0, 100, 3000, 1, false, 1)
        audio_sound_gain(_se, (global.vol_se / 100), 0)
    }
    else
    {
        var np = obj_pkun.np
        var lp = obj_pkun.lp
        if ((np != noone) && (lp != noone) && (!(collision_line(x, y, lp.x, lp.y, obj_wall, false, true))))
        {
            var _se = audio_play_sound_at(se, (obj_pkun.x + (1.5 * ((obj_pkun.x - np.x) + (lp.x - x)))), ((obj_pkun.y - 1600) - (2 * abs((lp.x - x)))), 300, 100, 6000, 1.5, false, 1)
            audio_sound_gain(_se, (global.vol_se / 100), 0)
        }
    }
}

function create_event_var_is_unset(variable) {
	return (variable_instance_exists(id, variable)) ? is_undefined(struct_get(self, variable)) : 1
}