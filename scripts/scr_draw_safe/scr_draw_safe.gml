// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function is_sprite_nsfw(sprite) {
	return array_contains(global.nsfw_sprites, sprite) || array_contains(asset_get_tags(sprite, asset_sprite), "nsfw")
}

function draw_sprite_safe(sprite, subimg, x, y) {
	draw_sprite_ext(sprite, subimg, x, y, 1, 1, 0, c_white, 1)
}

function draw_sprite_ext_safe(sprite, subimg, x, y, xscale, yscale, rot, colour, alpha, mob=0) {
	// highlight mobs in freecam mode
	if (instance_exists(obj_camera)) && (obj_camera.freecam) && (global.freecam_highlight_mobs) && (is_sprite_nsfw(sprite) || mob) // all mob sprites are nsfw so yeah
		colour = global.freecam_highlight_color
	
	if (!global.enable_nsfw && is_sprite_nsfw(sprite))
	{
		var src_w = sprite_get_width(sprite)
		var src_h = sprite_get_height(sprite)

		var x_offset = sprite_get_xoffset(sprite)
		var y_offset = sprite_get_yoffset(sprite)
		
	//	[0, "Box"], [1, "Outline"], [2, "Alt Sprite"]nsfw_censor_mode
	
		if (global.nsfw_censor_mode == 0)
		{
		    // Render black box (mask)
		    gpu_set_blendmode(bm_min);
		    draw_sprite_ext(sprite, subimg, x, y, xscale, yscale, rot, c_black, alpha);

			gpu_set_colorwriteenable(0, 0, 0, 1)
		    // Blend the censor texture over the black box
		    gpu_set_blendmode(bm_add); // Uses the black shape as a mask
		    draw_sprite_stretched(global.nsfw_censor_mask_sprite, 0, x - x_offset, y - y_offset, sprite_get_width(sprite) * xscale, sprite_get_height(sprite) * yscale);

		    gpu_set_blendmode(bm_normal); // Reset blend mode
			gpu_set_colorwriteenable(1, 1, 1, 1)
		}
		else if (global.nsfw_censor_mode == 2)
		{
			// other (alt sprite)
//			var aspect_h = (yscale * src_h) / sprite_get_height(global.nsfw_alt_sprite)
//			var _width = global.nsfw_alternative_sprite_maintain_aspect_ratio ? (aspect_h) : (xscale * src_w)
//			var _height = global.nsfw_alternative_sprite_maintain_aspect_ratio ? (aspect_h) : (yscale * src_h)
			//draw_sprite_stretched_ext(global.nsfw_alt_sprite, subimg, x - x_offset, y - y_offset, (aspect_h * sprite_get_width(global.nsfw_alt_sprite)), (yscale * src_h), c_white, alpha);
			draw_sprite_ext(global.nsfw_alt_sprite, 0, x, y, (xscale * -1), yscale, rot, colour, alpha)
		}
		
		
		

//		gpu_set_blendmode(bm_min)// Set a blend mode that makes it look like an overlay
//		draw_sprite_ext(sprite, subimg, x, y, xscale, yscale, rot, c_black, alpha); // Draw the original sprite
		
        // Apply an overlay mask (e.g., pixelation or black bars)
        
//        draw_sprite_stretched(global.nsfw_censor_mask_sprite, 0, x - x_offset, y - y_offset, src_w, src_h);
//        gpu_set_blendmode(bm_normal); // Reset blend mode
	}
	else
		draw_sprite_ext(sprite, subimg, x, y, xscale, yscale, rot, colour, alpha)
}

function draw_sprite_stretched_safe(sprite, subimg, x, y, w, h) {
	draw_sprite_stretched_ext_safe(sprite, subimg, x, y, w, h, c_white, 1)
}

function draw_sprite_stretched_ext_safe(sprite, subimg, x, y, w, h, colour, alpha) {
	if (!global.enable_nsfw && is_sprite_nsfw(sprite))
	{
		draw_sprite_stretched_ext(sprite, subimg, x, y, w, h, colour, alpha) // Draw the original sprite

        // Apply an overlay mask (e.g., pixelation or black bars)
        gpu_set_blendmode(bm_add); // Set a blend mode that makes it look like an overlay
        draw_sprite_stretched_ext(global.nsfw_censor_mask_sprite, 0, x, y, w, h, c_white, 1);
        gpu_set_blendmode(bm_normal); // Reset blend mode
	}
	else
		draw_sprite_stretched_ext(sprite, subimg, x, y, w, h, colour, alpha) // Draw the original sprite
}

function draw_sprite_tiled_safe(sprite, subimg, x, y) {
	draw_sprite_tiled_ext(sprite, subimg, x, y, 1, 1, c_white, 1)
}

function draw_sprite_tiled_ext_safe(sprite, subimg, x, y, xscale, yscale, colour, alpha) {
	if (!global.enable_nsfw && is_sprite_nsfw(sprite))
	{
		draw_sprite_tiled_ext(sprite, subimg, x, y, xscale, yscale, colour, alpha); // Draw the original sprite

        // Apply an overlay mask (e.g., pixelation or black bars)
        gpu_set_blendmode(bm_add); // Set a blend mode that makes it look like an overlay
        draw_sprite_tiled_ext(global.nsfw_censor_mask_sprite, 0, x, y, xscale, yscale, c_white, 1);
        gpu_set_blendmode(bm_normal); // Reset blend mode
	}
	else
		draw_sprite_tiled_ext(sprite, subimg, x, y, xscale, yscale, colour, alpha)
}