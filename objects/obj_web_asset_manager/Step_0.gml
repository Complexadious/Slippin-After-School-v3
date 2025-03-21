// process timers
var timers = global.web_asset_data.timers
var timer_list = struct_get_names(timers)

for (var j = 0; j < struct_names_count(timers); j++) {
	var timer =	timers[$ timer_list[j]]
	
	if (timer.count > 0) && (timer.active) {
		timer.count -= adjust_to_fps(1)
	} else {
		timer.count = timer.dur
		if (timer.func) {script_execute(timer.func)}
	}
}

//show_debug_message("QUEUE = " + string(download_queue))
var queue_len = array_length(download_queue)

if (queue_len <= 0) // just in case something gets fucked up
	active_downloads = 0

if (active_downloads >= max_active_downloads)
	exit;

for (var i = queue_len - 1; i >= 0; i--) {
    // inside the download queue, all items are 'dfile'
    var file_curr = download_queue[i]

    var _split = string_split(file_curr.file_path, "/")
    var file_name = string(_split[array_length(_split) - 1])
	var _f = file_curr.flags

	// check and see if we're a duplicate
	if array_contains(download_queue, file_curr, 0, i) { // check for duplicates behind us
		array_delete(download_queue, i, 1)
		show_debug_message("WE ARE A FUCKING DUPLICATE!!")
		continue;
	}

	// other checks
    var not_downloading = (file_curr.status == "waiting") || (file_curr.status == "failed")
	var overwrite_flag = _f.contains("overwrite_existing_file")
    var overwriting = (file_exists(file_curr.file_path)) && !overwrite_flag

    var ready = (not_downloading && !overwriting)

    if ready {
        // start the download process
		if (overwrite_flag)
			log("Overwriting existing file '" + file_name + "' at '" + string(file_curr.file_path) + "' due to presense of 'overwrite_existing_file' flag")
		
		// where we run the download shit
		if (_f.value("request_type") == "file") {
			file_curr.request_id = http_get_file(file_curr.url, file_curr.file_path)
			log("Started download for file '" + file_name + "'")
		} else {
			file_curr.request_id = http_request(
				_f.value("request_url"),
				_f.value("request_type"),
				_f.value("request_headers"),
				_f.value("request_body")
			)
			log("Did http_request [type " + string(_f.value("request_type")) + "] for file '" + file_name + "'")
		}
		
		file_curr.status = "downloading"
		active_downloads++
		file_download_attempt_count++
    } else if overwriting {
		file_curr.status = "complete"
		file_curr.size = file_size(file_curr.file_path)
		file_curr.bytes_downloaded = file_curr.size	
		
		array_delete(download_queue, i, 1)
		log("File '" + file_name + "', already exists at '" + string(file_curr.file_path) + "', skipping download and considering it complete")
	}
	
	// sync to web asset download stuff
	struct_set(global.web_asset_data.downloads, file_curr.url, file_curr)
}

//// GIF STUFF
////var _width = window_get_width();
////var _height = window_get_height();
////if (surface_get_width(application_surface) != _width
////	|| surface_get_height(application_surface) != _height
////) {
////	surface_resize(application_surface, _width, _height);
////	display_set_gui_size(_width, _height);
////}

////
//if (reader != undefined) {
//	var _start = get_timer();
//	var _until = _start + 16 * 1000;
//	var _cont;
//	do {
//		var _elapsed = get_timer();
//		_cont = reader.next();
//		_elapsed = get_timer() - _elapsed;
		
//		reader_total_time += _elapsed;
		
//		show_debug_message(
//			"Load progress:"
//			+ " frame: " + string(array_length(reader_delays))
//			+ " action: '" + gif_reader_get_action_name(reader.last_action) + "'"
//			+ " time: " + string(_elapsed / 1000) + "ms"
//		)
//	} until (!_cont || get_timer() >= _until);
	
//	reader_total_frames += 1;
	
//	if (!_cont || mouse_check_button_pressed(mb_left)) { // finish/abort
//		loadCleanup();
		
//		var _elapsed = get_timer();
//		gif_sprite = reader.finish();
//		reader_total_time += get_timer() - _elapsed;
//		reader = undefined;
		
//		gif_bottom_text = ("Loaded in "
//			+ string(reader_total_time div 1000) + "ms over "
//			+ string(reader_total_frames) + " frames!"
//		);
		
//		gif_delays = reader_delays;
//		gif_frame_sprites = reader_frame_sprites;
//		if (gif_sprite != -1) {
//			loadPost();
//		}
//	}
//}
////if (keyboard_check_pressed(ord("1"))) opt_gradual = !opt_gradual;
////if (keyboard_check_pressed(ord("2"))) opt_frame_sprites = !opt_frame_sprites;

///*if (mouse_check_button_pressed(mb_right)) {
//	sprite_save_strip(gif_sprite, "sprite.png");
//}*/