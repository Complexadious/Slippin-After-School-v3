/// @description Insert description here
// You can write your code in this editor
switch network_obj_type {
	case "player": {
		x += dx
		y += dy
		
		// adjust flashlight
		if (flashOn[0] != flashOn[1]) {
			flashOn[0] = flashOn[1]
			// change happened
			play_se(se_flash, 1)
		}
		
		// guess current sprite based off of speed
		if (dx == 0) {
			sprite_index = spr_pkun_idle
			image_speed = (1/3)
		} else if (abs(dx) <= 6) {
			sprite_index = spr_pkun_walk
			image_speed = (1/2)
		} else {
			sprite_index = spr_pkun_dash
			image_speed = (1)
		}
		
		// obj_pkun shit
		if (soundDelay > 0)
	        soundDelay-= adjust_to_fps(1)
	    else if (check_index(0) || check_index(3)) && (sprite_index != spr_pkun_idle)
	    {
	        soundDelay = (5)
			var _i = random_range(0, array_length(se_step))
	        play_se(se_step[_i], (0.35 + 0.25 * running))
	        if ((!((y < 720 && x > 6540 && x < 8810))) && chance(50))
				_i = random_range(0, array_length(se_creak))
	            play_se(se_creak[_i], (0.3 + 0.2 * running))
	    }
		
		if (hscene_target != -4) && (instance_exists(hscene_target))
			instance_destroy(hscene_target)
		
		var _intrTarget = instance_nearest(x, y, obj_interactable)
		//show_debug_message("NETWORK OBJ LIFECUR = " + string(lifeCur) + ", LIFEMAX = " + string(lifeMax))
		//if (_intrTarget != noone) && pressing_interact {
		//	if ((intrDone) >= (intrNeed)) {
		//		intrDone = 0
		//		show_debug_message("INTERACTED!!!!")
		//		if (_intrTarget.type == "hidespot") && (!hiding) {
		//			with _intrTarget {
		//				shake = 20
		//				locked = 1
		//				play_se(se_in, 1)
		//			}
		//			hiding = 1
				
		//		} else if (_intrTarget.type == "hidespot") {
		//			with _intrTarget {
		//				shake = 20
		//				locked = 0
		//				play_se(se_out, 1)
		//			}
		//			hiding = 0
		//		}
		//	}
		//}
		//else
		//	intrDone = 0
	break;
	}
}