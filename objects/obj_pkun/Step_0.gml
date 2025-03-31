// some multiplayer stuff
flashOn = global.flashOn
pressing_interact = keyboard_check(vk_return)
lifeCur = global.lifeCur
lifeMax = global.lifeMax
charmed = global.charmed
itemSlot = global.itemSlot
move_speed = 0

hs_hide_fl = global.hscene_hide_fl
hscene_target = global.hscene_target
hs_mob_id = (hscene_target != -4) ? global.hscene_target.mob_id : 0
	
var cam_target_is_pkun = instance_exists(obj_camera.camTarget) ? (!((obj_camera.camTarget != noone) && (obj_camera.camTarget.object_index != obj_pkun))) : 1

// constantly sync miniMsgStr
update_pkun_mini_msg_event()

// things that will force pkun to be frozen
if ((global.hscene_target != noone) || global.ui_spectate_list_open) || (obj_camera.freecam) || !cam_target_is_pkun || (global.disable_game_keyboard_input) || (global.menu_mode)
	global.pkun_frozen = 1
else
	global.pkun_frozen = 0
	
// things that will make pkun invincible
if (obj_camera.freecam)
	immortal = infinity
else if (immortal = infinity)
	immortal = 0

if (keyboard_check_pressed(ord("H")) && global.game_debug && !global.disable_game_keyboard_input)
{
	global.lifeCur = 3
	global.flashPow = 100
	stamina = 100
}

if (keyboard_check_pressed(ord("J")) && global.game_debug && !global.disable_game_keyboard_input)
	item_add(5)

// some slide stuff
if (sliding && !audio_is_playing(slideSound))
	play_se(slideSound, 1)
else if !sliding
	audio_stop_sound(slideSound)

if (keyboard_check_pressed(ord("G")) && global.game_debug) && !global.disable_game_keyboard_input {
	if global.timeStop > 0
		global.timeStop = 0
	else
		global.timeStop = infinity
}

// make mobs target you if you speak!
var nearest = pkun_get_nearestMob()
if (global.speaking) && (distance_to_object(nearest) < 800) {
	show_debug_message("obj_pkun: Alerted mob " + string(nearest) + " due to speaking!")
	nearest.lostTarget = 0
}

// Fix immortality buggying out
if immortal = 0
	immortal = 0.01

//	instance_create_depth(x, y, depth, obj_global.timeStop_fx)

var nearest = (cam_target_is_pkun) ? instance_nearest(x, y, obj_interactable) : instance_nearest(obj_camera.camTarget.x, obj_camera.camTarget.y, obj_interactable)
if global.trans_spd != adjust_to_fps(0.05)
	global.trans_spd = adjust_to_fps(0.05)
if !audio_is_playing(bgm_rain_inside) && (room = rm_game || room == rm_gallery)
	play_bgm(bgm_rain_inside)
if keyboard_check_pressed(ord("I")) && global.game_debug
	global.clock_min+= adjust_to_fps(1)
if keyboard_check_pressed(ord("O")) && global.game_debug
	global.clock_min-= adjust_to_fps(1)
if (distance_to_object(nearest) < 50) || !cam_target_is_pkun
{
    if (intrTarget != nearest)
    {
        intrTarget = nearest
        intrDone = 0
    }
    intrNeed = (cam_target_is_pkun) ? (nearest.need * (global.flashOn ? 1 : 1.5)) : 0 // instant
}
else
{
    intrTarget = noone
    intrDone = 0
    intrNeed = 0
}	
var n = (noclip) ? obj_intr_portal : portal_nearest((cam_target_is_pkun) ? id : obj_camera.camTarget.id)
if (np != n)
{
    np = n
    lp = (noclip) ? -4 : portal_linked(n)
}
if (instance_number(obj_p_mob) > 0)
{
    if global.game_debug
	{
        nearestMob = instance_nearest(x, y, obj_p_mob)
	}
    else
        nearestMob = pkun_get_nearestMob()
}
audio_listener_position(x, y, 0)
if (!game_is_paused())
{
    if (global.lastX && global.lastY)
    {
        x = global.lastX
        y = 560 + 720 * (floor(global.lastY / 720))
        cam.x = x
        cam.y = y
        global.lastX = -1
        global.lastY = -1
    }
    if (!hiding)
    {
        if (exhaust && stamina > (25))
            exhaust = 0
        if keyboard_check(vk_shift) && (!collision_rectangle(x + (12 * dir), y - 1, x, y + 1, obj_wall, false, true) || noclip)
        {
            if (!exhaust)
                running = 1
        }
        else
            running = 0
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
		if keyboard_check(vk_left) && !global.pkun_frozen
		{
		    move_speed = adjust_to_fps(running ? 12 : 4) * speed_multiplier
		    var can_move = (!collision_rectangle(x - move_speed, y - 1, x, y + 1, obj_wall, false, true) || noclip) && ((global.timeStop <= 0) || global.timeStopCanMove)
		    //show_debug_message("L PKUN MOVE_SPEED = " + string(move_speed))
		    if (can_move)
		    {	
				dir = -1
			
				// update pkun pos
				if (last_movement_key != vk_left) || (last_move_speed != move_speed){
					sync_pkun_event()	// we moved, speed is different
				}
	//			else
	//				show_debug_message("VK_LEFT: Not updating! (last_key = " + string(last_movement_key) + ", last_move_speed = " + string(last_move_speed) + ", move_speed = " + string(move_speed) + ")")
			
		        if (soundDelay > 0)
		            soundDelay-= adjust_to_fps(1)
		        else if (check_index(0) || check_index(3)) && !sliding
		        {
		            soundDelay = (5)
					var _i = random_range(0, array_length(se_step))
		            play_se(se_step[_i], (0.35 + 0.25 * running))
		            if ((!((y < 720 && x > 6540 && x < 8810))) && chance(50))
						_i = random_range(0, array_length(se_creak))
		                play_se(se_creak[_i], (0.3 + 0.2 * running))
		        }        
		        if running
		        {
					if keyboard_check(vk_control)
					{
						// handle sliding
						x -= sliding_momentum
						slideCost = (0.0225 * sliding_momentum)
						set_sprite(spr_pkun_slide, 1)
						if (sliding_momentum > adjust_to_fps(slideCost))
						{
							sliding = 1
							sliding_momentum -= adjust_to_fps(slideCost)	
						} else {
							sliding = 0
							sliding_momentum = 0
						}
					}
					else
					{
			            x -= move_speed;
						sliding_momentum = move_speed
						sliding = 0
			            set_sprite(spr_pkun_dash, (1))
			            if (stamina > adjust_to_fps(runCost))
			                stamina -= adjust_to_fps(runCost)
			            else
			            {
			                stamina = 0
			                running = 0
			                exhaust = 1
			            }
					}
		        }
		        else
		        {
		            x -= move_speed;
		            set_sprite(spr_pkun_walk, (0.5))
		        }
		    }
		    else
		    {
		        set_sprite(spr_pkun_idle, (1/3))
		        image_speed = (1/3)
		    }

			last_movement_key = vk_left
	//		last_move_speed = move_speed
		}
		else if keyboard_check(vk_right) && !global.pkun_frozen
		{
		    move_speed = adjust_to_fps(running ? 12 : 4) * speed_multiplier
		    var can_move = (!collision_rectangle(x, y - 1, x + move_speed, y + 1, obj_wall, false, true) || noclip) && ((global.timeStop <= 0) || global.timeStopCanMove)
			//show_debug_message("R PKUN MOVE_SPEED = " + string(move_speed))
		    if (can_move)
		    {	
				dir = 1
		
				// update pkun pos
				if (last_movement_key != vk_right) || (last_move_speed != move_speed){
					sync_pkun_event()	// we moved, speed is different
				}			
	//			else
	//				show_debug_message("VK_RIGHT: Not updating! (last_key = " + string(last_movement_key) + ", last_move_speed = " + string(last_move_speed) + ", move_speed = " + string(move_speed) + ")")
			
		        if (soundDelay > 0)
		            soundDelay-= adjust_to_fps(1)
		        else if (check_index(0) || check_index(3)) && !sliding
		        {
		            soundDelay = (5)
					var _i = random_range(0, array_length(se_step))
		            play_se(se_step[_i], (0.35 + 0.25 * running))
		            if ((!((y < 720 && x > 6540 && x < 8810))) && chance(50))
						_i = random_range(0, array_length(se_creak))
		                play_se(se_creak[_i], (0.3 + 0.2 * running))
		        }
		        if running
		        {
					if keyboard_check(vk_control)
					{
						// handle sliding
						x += sliding_momentum
						slideCost = (0.025 * sliding_momentum)
						set_sprite(spr_pkun_slide, 1)
						if (sliding_momentum > adjust_to_fps(slideCost))
						{
							sliding = 1
							sliding_momentum -= adjust_to_fps(slideCost)	
						} else {
							sliding = 0
							sliding_momentum = 0
						}
					}
					else
					{
			            x += move_speed;
						sliding_momentum = move_speed
						sliding = 0
			            set_sprite(spr_pkun_dash, 1)
			            if (stamina > adjust_to_fps(runCost))
			                stamina -= adjust_to_fps(runCost)
			            else
			            {
			                stamina = 0
			                running = 0
			                exhaust = 1
			            }
					}
		        }
				else
		        {
		            x += move_speed;
		            set_sprite(spr_pkun_walk, (0.5))
		        }
		    }
		    else
		    {
		        set_sprite(spr_pkun_idle, (1/3))
		        image_speed = (1/3)
		    }
		
			last_movement_key = vk_right
	//		last_move_speed = move_speed
		}
		else
		{
	//		show_debug_message("VK_NONE: Not updating! (last_key = " + string(last_movement_key) + ", last_move_speed = " + string(last_move_speed) + ", move_speed = " + string(move_speed) + ")")
	        set_sprite(spr_pkun_idle, (1/3))
			if (last_move_speed != move_speed)
				sync_pkun_event() // stopped moving
			last_movement_key = -4
			move_speed = 0
			last_move_speed = 0
		}
		if keyboard_check_pressed(ord("F")) && !global.disable_game_keyboard_input
        {
            if (global.flashPow > 0)
                global.flashOn *= -1
				sync_flashlight_event()
            play_se(se_flash, 1)
        }
        else if keyboard_check_pressed(vk_alt) && !global.disable_game_keyboard_input
            item_use()
        else if keyboard_check_pressed(vk_control) && !global.disable_game_keyboard_input
            item_swap()
        if (intrTarget != noone)
        {
            if keyboard_check(vk_return) && !global.disable_game_keyboard_input
            {
                if (adjust_to_fps(intrDone) >= adjust_to_fps(intrNeed))
                {
					sync_pkun_event()
					interact_event()
//					if is_multiplayer()
//						send_client_interact_request_packet(intrTarget)
                    intrDone = 0
                    if (intrTarget.type == "portal")
                    {
						if (cam_target_is_pkun) {
							play_se(intrTarget.se, 1)
							global.transition = 1
							portalPort = intrTarget.port
							if (instance_number(obj_p_mob) > 0 && (!global.timeStop))
	                        {
	                            with (obj_p_mob)
	                            {
	                                if doTrack
	                                    mob_add_trace()
	                            }
								baldi_add_tracer()
	                        }
						} else {
							with (obj_camera.camTarget) {
								if variable_instance_exists(id, "trace_i")
									mob_use_portal()
							}
							keyboard_clear(vk_return)
						}
                    }
                    else if (intrTarget.type == "hidespot")
                    {
                        play_se(intrTarget.se_in, 1)
                        intrTarget.shake = (20)
                        x = intrTarget.x
                        hiding = 1
                        with (obj_p_mob)
                        {
							var current_target = get_closest_target(x, y, id)
							
                            if doTrack
                            {
                                if ((!target_is_near()) || distance_to_object(obj_pkun) > 700)
                                    lostTarget = 1
                            }
                        }
                    }
                    else if (intrTarget.type == "itemspot")
                    {
                        if (intrTarget.itemid > 0)
                        {
                            play_se(se_pickup, 1)
                            item_add(intrTarget.itemid)
                        }
                        else if (intrTarget.itemid < 0)
                            memo_get_random()
                        else
                        {
                            miniMsgTmr = 300
                            miniMsgStr = getText("msg_fn")
                        }
                        with (intrTarget)
                            instance_destroy()
                        intrTarget = noone
                    }
                    else if (intrTarget.type == "figure")
                    {
                        global.hscene_target = intrTarget
                        global.trans_alp = 1
                        global.hscene_hide_fl = intrTarget.hide_fl
                    }
                    else if (intrTarget.type == "piano")
                    {
                        with (intrTarget)
                        {
                            play_se(se, 1)
                            other.intrTarget = noone
                            instance_destroy()
                        }
                    }
                }
                else if (!(((intrTarget.type == "hidespot" || intrTarget.type == "mainexit") && intrTarget.locked)))
                    intrDone+= adjust_to_fps(1)
            }
            else
                intrDone = 0
        }
    }
    else if keyboard_check_pressed(vk_return) && !global.disable_game_keyboard_input
    {
        hiding = 0
//		if is_multiplayer()
//			send_client_interact_request_packet(intrTarget)
        if (intrTarget.type == "hidespot")
        {
            intrTarget.shake = (20)
            play_se(intrTarget.se_out, 1)
			interact_event()
        }
        if (intrTarget.object_index == obj_intr_hidebox) && (hidebox != -4)
        {
			if (intrTarget.id == hidebox.id) {
	            with (intrTarget)
	                instance_destroy()
	            intrTarget = noone
				hidebox = -4
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
    if (global.charmed > 0)
        global.charmed -= adjust_to_fps(0.05)
    if (global.timeStop > 0)
    {
        global.timeStop-= adjust_to_fps(1)
        if (global.timeStop == 0)
        {
            global.trans_col = 16777215
            global.trans_alp = 1
        }
    }
    else
        global.timeStop = 0
    if (room == rm_game)
    {
        if ((!hiding) && global.flashOn)
        {
            if (global.flashPow > 0)
                global.flashPow -= adjust_to_fps(0.008)
            else
            {
                global.flashPow = 0
                global.flashOn = -1
				sync_flashlight_event()
            }
        }
        if (!global.timeStop)
        {
            clock_tick()
			if (is_multiplayer()) {
				if check_is_server()
					pkun_spawn_mob()
			}
			else
				pkun_spawn_mob()
        }
    }
}
else if global.menu_mode
    image_speed = 0
if (global.hscene_target != noone)
{
    if (hiding && global.hscene_target.mob_id != 11)
    {
        hiding = 0
        intrTarget.shake = (20)
        play_se(intrTarget.se_out, 1)
        if (intrTarget.object_index == obj_intr_hidebox)
        {
            with (intrTarget)
                instance_destroy()
            intrTarget = -4
        }
    }
	
	if (global.hscene_target != {"mob_id": hs_mob_id}) {
		show_debug_message("HSCENE UPDATED")
		hs_mob_id = global.hscene_target.mob_id
		instance_destroy(global.hscene_target)
		global.hscene_target = {"mob_id": hs_mob_id}
	}
	
    hscene_animate()
	immortal = 180
}