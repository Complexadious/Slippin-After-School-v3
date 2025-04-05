switch network_obj_type {
	case "player": {
		//if (emulated_transition == 1) { // for disabling mob ai and stuff
		//	if ((emulated_trans_alp < 1))
		//        emulated_trans_alp += emulated_trans_spd
		//    else if ((emulated_trans_wait > 0))
		//        emulated_trans_wait-= adjust_to_fps(1)
		//    else if (!emulated_dialog_mode)
		//    {
		//        emulated_transition = 0
		//    }
		//}

		var _alp = ((!((ceil((immortal / 8)) % 2))) + 0.5)
		if (!global.dialog_acting)
		{
		    if ((hs_spr != -4) && (hs_mob_id > 0))
		    {
		        draw_sprite_ext_safe(hs_spr, hs_ind, x, (y - 20), dir, 0.1, 0, c_black, 0.5)
		        draw_sprite_ext_safe(hs_spr, hs_ind, x, y, dir, 1, 0, c_white, 1)
		        if (!hs_hide_fl)
		            draw_sprite_ext_safe(spr_pkun_fl, 0, x, ((y + 4) + 14), dir, 1, 0, c_white, 1)
		    }
		    else if (!hiding)
		        draw_sprite_ext_safe(sprite_index, image_index, x, (y + 14), dir, 1, 0, c_white, _alp)
		}
		
		if flashOn && !hs_mob_id && !hiding
			draw_flashlight(self)
	break;
	}
}