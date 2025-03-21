//// GIF STUFF
//var _width = display_get_gui_width();
//var _height = display_get_gui_height();
//var _usable_height = _height - string_height("Q") * 2;

//if (sprite_exists(gif_sprite) || gif_frame_sprites != undefined) {
//	var _delta = delta_time / (1000000 / 100);
//	gif_timer += _delta;
//	while (gif_timer > gif_delays[gif_subimg]) {
//		gif_timer -= gif_delays[gif_subimg];
//		gif_subimg = (gif_subimg + 1) % gif_frames;
//	}
//	//
//	var _gif_width = sprite_get_width(gif_sprite);
//	var _gif_height = sprite_get_height(gif_sprite);
//	var _gif_scale = max(1, min(_width div _gif_width, _usable_height div _gif_height));
//	var _gif_x = (_width - _gif_width * _gif_scale) div 2;
//	var _gif_y = (_height - _gif_height * _gif_scale) div 2;
	
//	//
//	var _gif_sprite, _gif_subimg;
//	if (gif_frame_sprites != undefined) {
//		_gif_sprite = gif_frame_sprites[gif_subimg];
//		_gif_subimg = 0;
//	} else {
//		_gif_sprite = gif_sprite;
//		_gif_subimg = gif_subimg;
//	}
//	draw_sprite_ext(_gif_sprite, _gif_subimg, _gif_x, _gif_y, _gif_scale, _gif_scale, 0, c_white, 1);
//}