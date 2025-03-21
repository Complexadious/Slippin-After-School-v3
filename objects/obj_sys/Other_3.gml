/// @description Insert description here
// You can write your code in this editor
audio_stop_all()
if (global.delete_temp_dir_on_game_close) {
	// manually clear temp directory
	directory_destroy(global.web_assets_path)
}