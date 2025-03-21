//show_debug_message("ASYNC QUEUE = " + string(download_queue))
var queue_len = array_length(download_queue)

for (var i = queue_len - 1; i >= 0; i--) {
    // inside the download queue, all items are 'dfile'
    var file_curr = download_queue[i]

    var _split = string_split(file_curr.file_path, "/")
    var file_name = string(_split[array_length(_split) - 1])

	if (async_load[? "id"] == file_curr.request_id) {
		var status = ds_map_find_value(async_load, "status")
		var http_status = async_load[? "http_status"]
		
		// save async_load
		file_curr.async_ds = json_encode(async_load)
		
		switch status {
			case 1: { // Downloading
				file_curr.size = async_load[? "contentLength"] ?? "N/A"
				file_curr.bytes_downloaded = async_load[? "sizeDownloaded"] ?? "N/A"
				file_curr.status = "downloading"
		
				var _percent = (file_curr.size != "N/A") ? (file_curr.bytes_downloaded / file_curr.size) * 100 : "N/A"
		
				log("Downloading file '" + file_name + "' (" + string(_percent) + "%) (" + string(file_curr.bytes_downloaded) + "/" + string(file_curr.bytes_downloaded) + " bytes)");	
				break;
			}
			case 0: { // Done
				file_curr.status = "complete"
				
				// process saving shit for request_type
				var rt = file_curr.flags.value("request_type")
				
				if (rt == "file") {
					file_curr.size = file_size(file_curr.file_path)
					file_curr.bytes_downloaded = file_curr.size
				} else {
					// save file manually
					var data = async_load[? "result"];
					var len = string_byte_length(data);
					show_debug_message("LEN = " + string(len) + ", RESULT: " + string(data));

					// Create a buffer with the number of bytes we expect
					var buf = buffer_create(len, buffer_fixed, 1);

					// Write each byte from the data string into the buffer
					for (var j = 1; j <= len; j++) {
					    // Get the character at position i and convert it to its byte value.
					    buffer_write(buf, buffer_u8, ord(string_char_at(data, i)));
					}

					// Save the buffer to the desired file
					buffer_save(buf, file_curr.file_path);
					buffer_delete(buf);
					log("Saved buffer to file at '" + string(file_curr.file_path) + "'")
				}
				
				array_delete(download_queue, i, 1)
				log("Finished downloading file '" + file_name + "', saved to '" + string(file_curr.file_path) + "'")
				active_downloads--
				break;
			}
			default: { // Error occured
				file_curr.status = "failed"
				
				array_delete(download_queue, i, 1)
				log("Error downloading file '" + file_name + "' (http_status: " + string(http_status) + ")")
				active_downloads--
				break;
			}
		}
	}
}

//var status = ds_map_find_value(async_load, "status");
//if status == 1
//{
//	var _total_size = async_load[? "contentLength"];
//	var _current_size = async_load[? "sizeDownloaded"];
//	var _percent = (_current_size / _total_size) * 100;
//	show_debug_message("Percentage Download = " + string(_percent) + "%");
//}
//var queue_len = array_length(asset_download_queue)

//var _handle_failiure = function(_asset, _index) {
//	// Error occurred
//	show_debug_message("obj_web_asset_manager: Error downloading item '" + string(_asset.alias) + "', HTTP_STATUS: " + string(async_load[? "http_status"]))
//	_asset.status = "failed"
//	_asset.fail_count++
		
//	if (_asset.fail_count > global.web_assets_max_redownload_attempts) { // failed too much!
//		show_debug_message("REMOVED FROM QUEUE")
//		array_delete(asset_download_queue, _index, 1)
//		_asset.fail_count--
//		active_downloads--
//	} else {
//		struct_set(failed_download_timers, _asset.alias, failed_download_timer_dur)
//	}
//}

//for (var i = queue_len - 1; i >= 0; i--) {
////	var reversed_i = queue_len - i - 1
//	// added check to ensure we're within the shit?
//	show_debug_message("FUCK ME IN MY ASS, I = " + string(i))
//	var asset = asset_download_queue[i] // is reversed but we still get first one
	
//	// check if asset is downloading and is the same async_load id
//	if !((asset.status == "downloading") && (async_load[? "id"] == asset.request_id))
//		exit;
		
//	var _status = async_load[? "status"];
////	show_debug_message("obj_web_asset_manager: Status for item '" + string(asset.alias) + "' is [" + string(_status) + "]")
	
//	if (_status < 0)
//	{
//		_handle_failiure(asset, i)
//	    exit;
//	}

//	if (_status == 1)
//	{
//	    // Downloading
//		show_debug_message("obj_web_asset_manager: Downloading item '" + string(asset.alias) + "'")
//	    asset.status = "downloading"
//		exit;
//	}

//	if (_status == 0)
//	{
//	    // Request completed!
//		show_debug_message("obj_web_asset_manager: Request completed for item '" + string(asset.alias) + "', HTTP_STATUS: " + string(async_load[? "http_status"]))
//		asset.status = "ready"
    
//	    if (async_load[? "http_status"] == 200)
//	    {
//	        // Request was succesful
//			show_debug_message("obj_web_asset_manager: Finished downloading item '" + string(asset.alias) + "', saved to '" + string(asset.file_path) + "'")
			
//			// double check and see if file exists and size isnt 0
//			if !(file_exists(asset.file_path)) || !(file_size(asset.file_path) > 0) {
//				_handle_failiure(asset, i)
//				exit;
//			}
			
//			// save it and stuff
//			var content = -4
//			switch asset.asset_type {
//				case "asset_sprite": {
//					content = sprite_add(asset.file_path, 0, 0, 0, 0, 0)
//					break;
//				}
//				case "asset_sound": {
//					content = audio_create_stream(asset.file_path)
//					break;
//				}
//			}
			
//			asset.content = content
			
//			// remove it from the queue
//			array_delete(asset_download_queue, i, 1)
//			active_downloads--
			
//			show_debug_message("THIS WAS FINALIZED OR SUM SHIT FOR ASSET " + string(asset.alias))
//	    }
//	}
	
//	// update the cache
//	cache_web_asset(asset)
//}


////for (var i = array_length(currently_downloading_assets) - 1; i >= 0 ; i--) {
////	var _rid = currently_downloading_assets[i][2]
////	var _url = currently_downloading_assets[i][1]
////	var _asset_type = string(currently_downloading_assets[i][0])
////	var _file_path = currently_downloading_assets[i][3]
	
////	if (async_load[? "id"] == _rid)
////	{
////		var _status = async_load[? "status"];
		
////		switch _asset_type {
////			case "asset_sprite": {
////				if file_exists(_file_path) {
////					show_debug_message("obj_web_asset_manager: Saving web image at file path " + _file_path)
////					var _spr = sprite_add(_file_path, 1, false, false, 0, 0);
////					struct_set(global.gui_cached_web_assets[$ _asset_type], _url, [_spr, _file_path])
////					show_debug_message("obj_web_asset_manager: Saved web image to sprite")
////					array_pop(currently_downloading_assets)
////				} //else { // issue happened, redownload later
////				//	var curr_val = global.gui_cached_web_assets[$ _asset_type][$ _url]
////				//	var delim = string_char_at(global.web_assets_invalid_download_counter_code, string_length(global.web_assets_invalid_download_counter_code))
////				//	if !is_undefined(curr_val) && (array_length(string_split(curr_val, delim)) == 2) {
////				//		var count = real(string_split(curr_val, delim)[1]) + 1
////				//		var val = global.web_assets_invalid_download_counter_code + string(count)
////				//		struct_set(global.gui_cached_web_assets[$ _asset_type], _url, val)	
////				//	} else {
////				//		var val = global.web_assets_invalid_download_counter_code + string(0)
////				//		struct_set(global.gui_cached_web_assets[$ _asset_type], _url, val)
////				//	}
////				//}
////				break;
////			}
////			case "asset_sound": {
////				if file_exists(_file_path) {
////					show_debug_message("obj_web_asset_manager: Saving web audio (OGG) at file path " + _file_path)
////					var _snd = audio_create_stream(_file_path)
////					struct_set(global.gui_cached_web_assets[$ _asset_type], _url, [_snd, _file_path])
////					show_debug_message("obj_web_asset_manager: Saved web audio (OGG) to sound")
////					array_pop(currently_downloading_assets)
////				}
////				break;
////			}
////		}
////	    show_debug_message("obj_web_asset_manager: REQUEST ID " + string(_rid) + " DOWNLOADING STATUS = " + string(_status))
////	}
////}
////if (ds_map_exists(async_load, "status")) {
////    if (async_load[?"status"] == 0) { // Successful download
////        var buffer = async_load[?"result"];

////        // Define a file path (in the "local storage" of GameMaker)

////        // Save buffer to a file
////        buffer_save(buffer, file_path);

////        // Free buffer
////        buffer_delete(buffer);

////        // Load the sprite from the saved file
////        if (file_exists(file_path)) {
////            global.web_sprite = sprite_add(file_path, 1, false, false, 0, 0);
////        }
////		show_debug_message("Image saved at: " + working_directory + file_path);
////    }
////}
////show_debug_message("HTTP EVENT??? async_load = " + string(async_load))