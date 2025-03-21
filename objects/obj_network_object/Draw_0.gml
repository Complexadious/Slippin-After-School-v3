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
		
		if flash_on && !hscene_target && !hiding
			draw_flashlight(self)
	break;
	}
}