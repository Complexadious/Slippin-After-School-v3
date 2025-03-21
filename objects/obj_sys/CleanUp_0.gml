/// @description Insert description here
// You can write your code in this editor
if ds_exists(global.textFile, 1)
{
    ds_map_destroy(global.textFile)
    ds_map_destroy(global.textKey)
}

audio_stop_all()
if (global.delete_temp_dir_on_game_close) {
	// manually clear temp directory
	show_debug_message("DIR CONTENTS = " + string(directory_size(global.web_assets_path)))
}