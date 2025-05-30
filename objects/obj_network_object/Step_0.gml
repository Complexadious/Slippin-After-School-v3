/// @description Insert description here
// You can write your code in this editor
switch network_obj_type {
	case "player": {
		
		// mimic some pkun variables
		running = (adjust_to_fps(abs(dx)) > 4)
		nametag_y = (instance_exists(hidebox)) ? (hidebox.y - (hidebox.sprite_height)) : (y - (sprite_height - 25))
		miniMsgY = (instance_exists(hidebox)) ? (hidebox.y - (hidebox.sprite_height)) : (y - (sprite_height - 25))
		
		var n = (noclip) ? obj_intr_portal : portal_nearest(id)
		if (np != n)
		{
		    np = n
		    lp = (noclip) ? -4 : portal_linked(n)
		}
		
		var can_move = !collision_rectangle(x + dx, y - 1, x, y + 1, obj_wall, false, true) || noclip
		if can_move
			x += dx
		if (dx > 0) { // if we moving
			if (running) {
				if (stamina > adjust_to_fps(runCost))
				    stamina -= adjust_to_fps(runCost)
				else
				{
				    stamina = 0
				    exhaust = 1
				}
			}
		}
		if (!hiding)
		{
	        if (exhaust && stamina > (25))
	            exhaust = 0
	        if (stamina <= (50))
	        {
	            if (pantDelay > 0)
	                pantDelay-= adjust_to_fps(1)
	            else
	            {
	                pantDelay = (60)
	                instance_create_depth(x, (y + 14), depth, obj_efct_pant)
	            }
	        }
		}
		if (immortal > 0)
			immortal-= adjust_to_fps(1)
		if (stmRegen > 0) && !sliding
	    {
	        stamina += (stmRegen / adjust_to_fps(35))
	        stmRegen -= (stmRegen / adjust_to_fps(35))
	    }
	    else
	        stmRegen = 0
	    if (stamina < 100)
	        stamina += adjust_to_fps(0.1) * !sliding
	    else
	        stamina = 100
		
		// obj_pkun shit
		if (soundDelay > 0)
	        soundDelay-= adjust_to_fps(1)
	    else if (check_index(0) || check_index(3)) && (sprite_index != spr_pkun_idle) && (dx != 0)
	    {
	        soundDelay = (5)
			var _i = random_range(0, array_length(se_step))
	        play_se_at(se_step[_i], x, y, (0.35 + 0.25 * running))
	        if ((!((y < 720 && x > 6540 && x < 8810))) && chance(50))
				_i = random_range(0, array_length(se_creak))
	            play_se_at(se_creak[_i], x, y, (0.3 + 0.2 * running))
	    }
		
		// guess current sprite based off of speed
		if (dx == 0) {
			sprite_index = spr_pkun_idle
			image_speed = adjust_to_fps(1/3)
		} else if (running) {
			sprite_index = spr_pkun_dash
			image_speed = adjust_to_fps(1)
		} else {
			sprite_index = spr_pkun_walk
			image_speed = adjust_to_fps(1/2)
		}
		
		if (hs_mob_id > 0)
			hscene_animate(0)
			//instance_destroy(hscene_target)
	break;
	}
}