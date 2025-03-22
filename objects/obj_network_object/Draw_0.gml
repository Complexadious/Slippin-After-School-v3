switch network_obj_type {
	case "player": {
		if (!global.dialog_acting)
		{
		    if ((hscene_target != -4) && (hs_spr != -4))
		    {
		        draw_sprite_ext_safe(hs_spr, hs_ind, x, (y - 20), dir, 0.1, 0, c_black, 0.5)
		        draw_sprite_ext_safe(hs_spr, hs_ind, x, y, dir, 1, 0, c_white, 1)
		        if (!global.hscene_hide_fl)
		            draw_sprite_ext_safe(spr_pkun_fl, 0, x, ((y + 4) + 14), dir, 1, 0, c_white, 1)
		    }
		    else if (!hiding)
		        draw_sprite_ext_safe(sprite_index, image_index, x, (y + 14), dir, 1, 0, c_white, ((!((ceil((immortal / 8)) % 2))) + 0.5))
		}
		
		if flashOn[1] && !hscene_target && !hiding
			draw_flashlight(self)
	break;
	}
}

// draw nametag
if (nametag != "") {
	var tx = x;
	var ty = y;

	var sh = string_height(nametag);
	var sw = string_width(nametag);
	var txtpad = 4;
	var y_offset = -20;

	draw_set_alpha(0.5);
	draw_set_color(c_black);
	draw_set_font(fnt_minecraft);

	var x1 = ((tx - (sw / 2)) - txtpad);
	var x2 = (x1 + (2 * txtpad) + sw);
	var y1 = (((ty - 400) + y_offset) - txtpad);
	var y2 = (y1 + (2 * txtpad) + sh);
	draw_rectangle(x1, y1, x2, y2, 0);

	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_text((tx - (sw / 2)), ((ty - sprite_height) + y_offset), nametag);	
}