function replace_stuff_in_strings(strings, struct_w_names_and_vals, delim = "|") {
	var vars = struct_get_names(struct_w_names_and_vals)
	var delim_len = string_length(delim)
	
	for (var i = 0; i < array_length(strings); i++) {
		// for each string
		var _offset = 0
		
//		show_debug_message("replace_stuff_in_strings, CHECKING STRING " + strings[i])
		while (string_pos_ext(delim, strings[i], _offset) > _offset) {
			var _start = string_pos(delim, strings[i])	
			_offset = string_pos_ext(delim, strings[i], _start + delim_len)
			var _name = string_region(strings[i], _start + delim_len, _offset - delim_len)
			
			// replace if is valid
			if struct_exists(struct_w_names_and_vals, _name) {
//				show_debug_message("IT EXISTS IN STRUCT")
				var new_str = string_delete(strings[i], _start, string_length(_name) + (delim_len * 2)) // remove old
				new_str = string_insert(struct_get(struct_w_names_and_vals, _name), new_str, _start)
				array_set(strings, i, new_str)
			}
//			else
//				show_debug_message("IT DONT EXIST IN STRUCT")
			
//			show_debug_message("replace_stuff_in_strings, FOUND DELIM SHIT! NAME = " + string(_name) + ", START = " + string(_start) + ", OFFSET = " + string(_offset) + ", REPLACED = " + string(new_str) + ", STR = " + string(strings[i]))
			//break;
		}
	}
	
//	show_debug_message("replace_stuff_in_strings, DONE, STRINGS = " + string(strings))
	return strings
}

function wa_flags_struct(_flags = {}) constructor {
	flags = _flags

	// methods
	contains = function(flag) {return struct_exists(flags, flag)}
	value = function(flag) {return struct_get(flags, flag)}
	count = function() {return struct_names_count(flags)}
	type = function(flag) {return typeof(flags[$ flag])}
	set = function(flag, value) {struct_set(flags, flag, value)}
}

function asset_type_exists(asset_type) {
	return struct_exists(global.web_asset_data.asset_types, asset_type)	
}

function ref_web_asset(alias_or_source, asset_type, flags = {}) {
	var fallback = web_fallback_asset(asset_type)
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/ref_web_asset")}
	
	if !asset_type_exists(asset_type)
		__log("Cannot reference web_asset '" + string(alias_or_source) + "' since asset_type '" + string(asset_type) + "' doesn't exist.", logType.warning.def)
	
	// check if asset exists or not
	if (alias_to_asset(alias_or_source) == noone) && (source_to_asset(alias_or_source) == noone) {
		// create it if alias_or_source is a source
		if (web_asset_is_alias_or_source(alias_or_source) == "source") || (global.web_asset_data.asset_types[$ asset_type].REQUIRE_URL == 0) {
			create_web_asset(alias_or_source, asset_type, alias_or_source, flags)
			__log("Creating a new web_asset since referenced web_asset '" + string(alias_or_source) + "' doesn't exist.")
		}
		return fallback
	}

	// assuming it does exist
	var asset = -4
	switch web_asset_is_alias_or_source(alias_or_source, true) {
		case "source": {
			asset = source_to_asset(alias_or_source)
			break;
		}
		case "alias": {
			asset = alias_to_asset(alias_or_source)
			break;
		}
	}
	
	return (asset.reference != -4) ? asset.reference : fallback
}

function web_asset_is_alias_or_source(alias_or_source, check_web_assets = 0) {
	var matches_a_file_source = struct_exists(global.web_asset_data.downloads, alias_or_source)
	var has_web_protocol = (string_starts_with(alias_or_source, "http://") || string_starts_with(alias_or_source, "https://"))
	
	// i know I can just do 'string_starts_with(alias_or_source, "http")' for both, but im doing this just in case :)
	if (has_web_protocol && (matches_a_file_source || !check_web_assets))
		return "source"
	return (struct_exists(global.web_asset_data.assets, alias_or_source)) ? "alias" : "unknown" // really just assuming its an alias, idk
}

function alias_to_asset(alias) {
	return (struct_exists(global.web_asset_data.assets, alias)) ? global.web_asset_data.assets[$ alias] : noone
}

function source_to_asset(source) {
	if struct_exists(global.web_asset_data.assets, source)
		return global.web_asset_data.assets[$ source]
	
	var assets = struct_get_names(global.web_asset_data.assets)
	for (var i = 0; i < array_length(assets); i++) {
		var asset = global.web_asset_data.assets[$ assets[i]]
		
		if asset.source == source
			return source
	}
	
	return noone
}

function check_web_asset_references() {
	var assets = struct_get_names(global.web_asset_data.assets)
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/check_web_asset_references")}
	
	for (var i = 0; i < array_length(assets); i++) {
		var asset = global.web_asset_data.assets[$ assets[i]]
		var func = global.web_asset_data.asset_types[$ asset.asset_type].SAVE
		if (asset.reference != -4)
			continue;		
		if script_exists(func)
			script_execute(func, asset)
		else
			__log("Asset_type '" + string(asset.asset_type) + "' doesn't have a valid SAVE handler for it's web asset '" + string(asset.alias) + "'", logType.warning.def)
	}	
}

function web_asset_data_init() {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/web_asset_data_init")}
	__log("Init stage ran for Web Asset System.")
	
	if !instance_exists(obj_web_asset_manager) {
		instance_create_depth(0, 0, 999, obj_web_asset_manager)
		__log("Created obj_web_asset_manager instance.")
	}
	// init request headers for certain asset_types
	global.eleven_api_key = "sk_719d7e40357769b38b2b18ba196335c235e74162a483b9b0"
	global.elevenlabs_request_headers = ds_map_create()
	ds_map_add(global.elevenlabs_request_headers, "xi-api-key", global.eleven_api_key);
	ds_map_add(global.elevenlabs_request_headers, "Content-Type", "application/json");
	
	// init web asset data
	global.web_asset_data = {
		settings: global.web_asset_data_settings,
		struct_formats: {
			"asset": [
				["alias", "string"],
				["source", "string"],
				"reference",
				["asset_type", "string"]
			],
			"download": [
				["url", "string"],
				["file_path", "string"],
				["size", "number"],
				"bytes_downloaded",
				["request_id", "number"],
				["status", "number"],
				["fail_count", "number"],
				"async_ds",
				["flags", "array"],
				["timers", "struct"]
			]
		},
		downloads: {},
		timers: {
			"refresh_web_asset_references": {
				"count": 30,
				"func": check_web_asset_references,
				"dur": 60,
				"active": 1
			},
			"validate_struct_data": {
				"count": 60,
				"func": noone,
				"dur": 300,
				"active": 0
			}
		},
		assets: {},
		lookup_tables: {},
		info: {
			"active_downloads": obj_web_asset_manager.active_downloads,
			"max_active_downloads": obj_web_asset_manager.max_active_downloads,
			"file_download_attempt_count": obj_web_asset_manager.file_download_attempt_count
		},
		func: {},
		asset_types: {
			// Where each asset type is handled.
			// REQUIRE_URL: bool, // whether to allow creation w/o a url (1 = source must be url, asset wont be made w/o it)
			// SAVE: function - Runs when an asset is saved, must accept the asset_struct as the only argument
			// DELETE: function - Runs when an asset is deleted, must accept the asset_struct as the only argument
			// FALLBACK: any - fallback asset or string or whatever, what's referenced when asset isnt set
			// FLAGS: Struct - Struct containing required flags and optional data_type as value for asset creation
			// REQUEST_TYPE: 'file' (http_get_file) OR other request type, must define request info
				// REQUEST_URL
				// REQUEST_QUERY
				// REQUEST_HEADERS
				// REQUEST_BODY
			"asset_sprite": {
				REQUIRE_URL: 1, // whether to allow creation w/o a url
				SAVE: web_asset_sprite_save_handler,
				DELETE: web_asset_sprite_delete_handler,
				FALLBACK: spr_error,
				FLAGS: {}, // required flags for when creating them
				REQUEST_TYPE: "file" // request type, 'file' for standard http_get_file
			},
			"asset_sound": {
				REQUIRE_URL: 1, // whether to allow creation w/o a url
				SAVE: web_asset_sound_save_handler,
				DELETE: web_asset_sound_delete_handler,
				FALLBACK: se_lobotomy,
				FLAGS: {}, // required flags for when creating them
				REQUEST_TYPE: "file" // request type, 'file' for standard http_get_file
			},
			"asset_text": {
				REQUIRE_URL: 1, // whether to allow creation w/o a url
				SAVE: web_asset_text_save_handler,
				DELETE: web_asset_text_save_handler,
				FALLBACK: "Unable to get Web Text :(",
				FLAGS: {}, // required flags for when creating them
				REQUEST_TYPE: "file" // request type, 'file' for standard http_get_file
			},
			"asset_elevenlabs_sound": {
				REQUIRE_URL: 0, // whether to allow creation w/o a url
				SAVE: web_asset_sound_save_handler,
				DELETE: web_asset_sound_delete_handler,
				FALLBACK: se_ruler_slap,
				FLAGS: {"voice_id": "string", "text": "string", "model_id": "string"}, // required flags for when creating them
				REQUEST_TYPE: "POST", //"POST", // request type, 'file' for standard http_get_file or 'post' for advanced
				REQUEST_URL: "https://api.elevenlabs.io/v1/text-to-speech/",
				REQUEST_QUERY: "|voice_id|?output_format=mp3_44100_128", // spaces determine where to add flag values
				REQUEST_HEADERS: global.elevenlabs_request_headers, // "|" is delimiter
				REQUEST_BODY: "{\"text\":\"|text|\",\"model_id\":\"|model_id|\"}"
			}
//			"asset_gif": {
////				REFERENCE: web_asset_sound_ref_handler,
//				SAVE: web_asset_gif_save_handler,
//				DELETE: web_asset_sprite_delete_handler,
//				FALLBACK: spr_error
//			}
		}
	}
}

function web_fallback_asset(asset_type) {
	if is_undefined(global.web_asset_data.asset_types[$ asset_type].FALLBACK)
		show_error("Error while trying to fetch fallback asset for asset type: '" + string(asset_type) + "'", 1)
	return global.web_asset_data.asset_types[$ asset_type].FALLBACK
}

/// @function web_asset(source: String, asset_type: String, *alias: String)
/// @param {string} _source The direct link to the file to download
/// @param {string} _asset_type The type of asset this is (asset_sprite, asset_sound, ...)
/// @param {string} _alias Optional name for the web asset, defaults to _source
/// @description Constructs a web_asset struct, further processing is needed

function web_asset(_source, _asset_type, _alias = _source) constructor {
	var possible_asset_types = struct_get_names(global.web_asset_data.asset_types)
	var __log = function(msg, type = logType.info.def) {log(msg, type, "CONSTRUCTOR/web_asset")}
	if !array_contains(possible_asset_types, _asset_type)
		show_error("Error constructing web_asset: Provided asset_type (" + string(_asset_type) +") is invalid. Possible asset types are: " + string(possible_asset_types), 1)
	
	if !string_starts_with(_source, "http://") && !string_starts_with(_source, "https://") {
		__log("Source doesn't start with HTTP or HTTPS! (web_asset '" + string(_alias) + "')", logType.warning.def)
		_source = string_insert(_source, "http://", 0)
	}
	
	source = _source
	asset_type = _asset_type
	alias = _alias
	reference = -4
}

/// @function create_web_asset(source: String, asset_type: String, *alias: String)
/// @param {string} source The direct link to the file to download
/// @param {string} asset_type The type of asset this is (asset_sprite, asset_sound, ...)
/// @param {string} alias Optional name for the web asset, defaults to _source
/// @description Constructs a new web_asset, use ref_web_asset(alias OR source, asset_type) to use it.

function create_web_asset(source, asset_type, alias = source, flags = {}) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/create_web_asset")}
	
	if (alias == noone || alias == -4 || alias == "")
		alias = source
		
	// check if its a valid asset_type
	if !asset_type_exists(asset_type) {
		__log("Can't create web_asset '" + string(alias) + "', asset_type '" + string(asset_type) + "' doesn't exist!", logType.error.def)
		exit;
	}
	
	var wa = new web_asset(source, asset_type, alias)
	var _flags = new wa_flags_struct(flags)
	var wad = global.web_asset_data
	var _at = wad.asset_types[$ asset_type]
	
	// here we will process the asset_type request shit, make sure it contains required flags
		// check if we have all required flags
	var required_flags = struct_get_names(_at.FLAGS)
	for (var i = array_length(required_flags) - 1; i >= 0; i--) {
		if _flags.contains(required_flags[i])
			array_delete(required_flags, i, 1)
	}
	
	if (array_length(required_flags) > 0) { // we are missing flags
		__log("Can't create web_asset '" + string(alias) + "', missing flags: " + string(required_flags), logType.error.def)
		exit;
	}

	// set request flags 
	_flags.set("request_type", _at.REQUEST_TYPE)
	if (_at.REQUEST_TYPE != "file") {
		__log("Asset_type request_type is not 'file'. Doing additional request flag stuff processing!")
	//	{request_type, request_url: "https://api.elevenlabs.io/v1/text-to-speech/9BWtsMINqrJLrRacOk9x?output_format=mp3_44100_128", "request_headers": ds}
		// have all flags, check if we are gonna do a custom request. if so, process the shit (flags)
		var _s = replace_stuff_in_strings([_at.REQUEST_URL, _at.REQUEST_QUERY, _at.REQUEST_BODY], flags, "|")
	
		_flags.set("request_url", _s[0] + _s[1])
		_flags.set("request_body", _s[2])
		_flags.set("request_headers", _at.REQUEST_HEADERS)
		__log("FLAGS: " + string(_flags.flags))
	}
	
	download_file(source, global.web_assets_path + generate_uuid4_string(), _flags)
	struct_set(wad.assets, alias, wa)
	
	__log("Created new web " + string(asset_type) + " '" + string(alias) + "' with source '" + string(source) + "' and flags " + string(flags))
}
	
/// @function dfile(url: String, file_path: String, *flags: Struct)
/// @param {string} _url The direct link to the file to download
/// @param {string} _file_path The local destination for the file
/// @param {struct} _flags Optional flags for downloading file (overwrite_existing_file, ...)
/// @description Creates a file download struct to put inside the obj_web_asset_manager queue

function dfile(_url, _file_path, _flags = {}) constructor {
    // {source: "", PATH: "", contentLength: 0, downloadedBytes: 0, requestID: -1, status: "waiting", fail_count: 0, timers: {}}
    url = _url
    file_path = _file_path
    size = "N/A"
    bytes_downloaded = "N/A"
    request_id = -1
    status = "waiting"
    fail_count = 0
    async_ds = -4
    flags = (_flags == {}) ? new wa_flags_struct(_flags) : _flags
	request_type = flags.value("request_type")
	request_url = flags.value("request_type")
	request_headers = flags.value("request_headers")
	request_body = flags.value("request_body")
	
	show_debug_message("flag shit: url=" + string(request_url) + ", headers=" + string(request_headers) + ", body=" + string(request_body))
}

/// @function download_file(url: String, file_path: String, *flags: Array)
/// @param {string} url The direct link to the file to download
/// @param {string} file_path The local destination for the file
/// @param {struct} flags Optional flags for downloading file (overwrite_existing_file, )
/// @description Queues a file to download within obj_web_asset_manager

function download_file(url, file_path, flags = {}) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/download_file")}
    if !instance_exists(obj_web_asset_manager) {
        var inst = instance_create_depth(0, 0, 999, obj_web_asset_manager)
        __log("Created obj_web_asset_manager instance, INST: (" + string(inst) + ")")
    }

    var df = new dfile(url, file_path, flags)
    with obj_web_asset_manager {
        array_push(download_queue, df)
    }
}

function web_asset_is_downloaded_file_valid(asset) {
	// check if the downloaded file exists and is valid
	if !(struct_exists(global.web_asset_data.downloads, asset.source))
		return 0 // end it early so we dont process the rest
		
	var path = global.web_asset_data.downloads[$ asset.source].file_path
	
	if ((file_exists(path)) && (file_size(path) > 0) && (asset.reference <= 0))
		return path
}

// handlers

	// delete file (should be used for all types)
function web_asset_delete_source_file_handler(asset) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/web_asset_delete_source_file_handler")}
	if !struct_exists(global.web_asset_data.downloads, asset.source) {
		__log("Web asset '" + string(asset.alias) + "' source file '" + string(asset.source) + "' wasn't found in global.web_asset_data.downloads!", logType.warning.def)
		return 0	
	}
	
	// assuming downloads struct exists in global.web_asset_data.downloads
	var fp = global.web_asset_data.downloads[$ asset.source].file_path
	if file_exists(fp) {
		file_delete(fp)
		__log("Web asset '" + string(asset.alias) + "' source's local file '" + string(asset.source) + "' AND download struct were deleted!")
	} else
		__log("Web asset '" + string(asset.alias) + "' source's local file '" + string(asset.source) + "' wasn't found or doesn't exist! Download struct was still deleted!", logType.warning.def)
	struct_remove(global.web_asset_data.downloads, asset.source)
	return 1
}

	// sprite
function web_asset_sprite_save_handler(asset) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/web_asset_sprite_save_handler")}
	var path = web_asset_is_downloaded_file_valid(asset)
	if (path != 0) && !is_undefined(path) {
		asset.reference = sprite_add(path, 0, false, false, 0, 0)
		__log("Created sprite reference for web asset '" + string(asset.alias) + "' from image file at '" + string(path) + "'")
	}
	else
		__log("Unable to create sprite reference for web asset '" + string(asset.alias) + "' from image file at '" + string(path) + "'", logType.warning.def)
}

function web_asset_sprite_delete_handler(asset) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/web_asset_sprite_delete_handler")}
	var suffix = ""
	
	// delete asset
	if (asset.reference > 0) && (asset_get_type(asset.reference) == asset_sprite) {
		suffix += " AND web_sprite (" + string(asset.reference) + ")"
		sprite_delete(asset.reference)
	}
	
	// delete web asset local downloaded file
	if web_asset_delete_source_file_handler(asset)
		suffix += " AND image file"
	
	// finally delete web asset from web_asset_data.assets
	struct_remove(global.web_asset_data, asset.alias) // dekete from assets
	__log("Deleted web asset_sprite '" + string(asset.alias) + "'" + suffix)
	exit;
}

	// sound
function web_asset_sound_save_handler(asset) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/web_asset_sound_save_handler")}
	var path = web_asset_is_downloaded_file_valid(asset)
	if (path != 0) && !is_undefined(path) {
		asset.reference = audio_create_stream(path)
		__log("Created audio stream for web asset '" + string(asset.alias) + "' from sound file at '" + string(path) + "'")
	}
	else
		__log("Unable to create audio stream for web asset '" + string(asset.alias) + "' from sound file at '" + string(path) + "'", logType.warning.def)
}

function web_asset_sound_delete_handler(asset) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/web_asset_sound_delete_handler")}
	var suffix = ""
	
	// delete asset
	if (asset.reference > 0) && (asset_get_type(asset.reference) == asset_sound) {
		var _r = string(asset.reference)
		var del = audio_destroy_stream(asset.reference)
		if (del > 0) {
			suffix += " AND web_sound (" + _r + ")"
		} else {
			suffix += " BUT NOT web_sound (" + _r + ")"
			__log("Couldn't delete web asset_sound '" + string(asset.alias) + "'!", logType.warning.def)
		}
	}
	
	// delete web asset local downloaded file
	if web_asset_delete_source_file_handler(asset)
		suffix += " AND sound file"
	
	// finally delete web asset from web_asset_data.assets
	struct_remove(global.web_asset_data, asset.alias) // dekete from assets
	__log("Deleted web asset_sound '" + string(asset.alias) + "'" + suffix)
	exit;
}

	// text
function web_asset_text_save_handler(asset) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/web_asset_text_save_handler")}
	var path = web_asset_is_downloaded_file_valid(asset)
	if (path != 0) && !is_undefined(path) {
		var file = file_bin_open(path, 0)
		asset.reference = file_text_read_string(file)
		file_bin_close(file)
		__log("Got web text for web asset '" + string(asset.alias) + "' from text file at '" + string(path) + "'")
	}
	else
		__log("Unable to getweb  text for web asset '" + string(asset.alias) + "' from text file at '" + string(path) + "'", logType.warning.def)
}

function web_asset_text_delete_handler(asset) {
	var __log = function(msg, type = logType.info.def) {log(msg, type, "FUNC/web_asset_text_delete_handler")}
	var suffix = ""
	
	// delete web asset local downloaded file
	if web_asset_delete_source_file_handler(asset)
		suffix += " AND text file"
	
	// finally delete web asset from web_asset_data.assets
	struct_remove(global.web_asset_data, asset.alias) // dekete from assets
	__log("Deleted web asset_text '" + string(asset.alias) + "'" + suffix)
	exit;
}

//	// gif (sprite)
//function web_asset_gif_save_handler(asset) {
//	var path = web_asset_is_downloaded_file_valid(asset)
//	if (path != 0) && !is_undefined(path) {
//		asset.reference = sprite_add_gif(path, 0, 0, 10)
//		show_debug_message(log_msg_prefix() + "[FUNC web_asset_gif_save_handler] Created sprite (GIF) reference for web asset '" + string(asset.alias) + "' from gif file at '" + string(path) + "'")
//	}
//	else
//		show_debug_message(log_msg_prefix() + "[FUNC web_asset_gif_save_handler] WARNING! Unable to create sprite (GIF) reference for web asset '" + string(asset.alias) + "' from gif file at '" + string(path) + "'")
//}

//function web_asset_gif_delete_handler(asset) {
//	var suffix = ""
	
//	// delete asset
//	if (asset.reference > 0) && (asset_get_type(asset.reference) == asset_sprite) {
//		var _r = string(asset.reference)
//		var del = (asset.reference)
//		if (del > 0) {
//			suffix += " AND web_sound (" + _r + ")"
//		} else {
//			suffix += " BUT NOT web_sound (" + _r + ")"
//			show_debug_message(log_msg_prefix() + "[FUNC web_asset_sound_delete_handler] WARNING! Couldn't delete web asset_sound '" + string(asset.alias) + "'!")
//		}
//	}
	
//	// delete web asset local downloaded file
//	if web_asset_delete_source_file_handler(asset)
//		suffix += " AND sound file"
	
//	// finally delete web asset from web_asset_data.assets
//	struct_remove(global.web_asset_data, asset.alias) // dekete from assets
//	show_debug_message(log_msg_prefix() + "[FUNC web_asset_sound_delete_handler] Deleted web asset_sound '" + string(asset.alias) + "'" + suffix)
//	exit;
//}