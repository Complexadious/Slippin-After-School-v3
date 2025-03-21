if (global.delete_temp_dir_on_game_close) && (directory_exists(global.web_assets_path)) {
	directory_destroy(global.web_assets_path)
}