for (var i = 0; i < array_length(currently_downloading_assets_ids); i++) {
	var _rid = currently_downloading_assets_ids[i][2]
	var _url = currently_downloading_assets_ids[i][1]
	var _asset_type = currently_downloading_assets_ids[i][0]
	var _file_path = currently_downloading_assets_ids[i][0]
	
	if (async_load[? "id"] == _rid)
	{
		var _status = async_load[? "status"];
	    show_debug_message("obj_web_downloader: REQUEST ID " + string(rid) + " DOWNLOADING STATUS = " + string(_status))
		
		struct_set(global.gui_cached_web_assets[$ string(_asset_type)], _url, _status)
	}
}
//if (ds_map_exists(async_load, "status")) {
//    if (async_load[?"status"] == 0) { // Successful download
//        var buffer = async_load[?"result"];

//        // Define a file path (in the "local storage" of GameMaker)

//        // Save buffer to a file
//        buffer_save(buffer, file_path);

//        // Free buffer
//        buffer_delete(buffer);

//        // Load the sprite from the saved file
//        if (file_exists(file_path)) {
//            global.web_sprite = sprite_add(file_path, 1, false, false, 0, 0);
//        }
//		show_debug_message("Image saved at: " + working_directory + file_path);
//    }
//}