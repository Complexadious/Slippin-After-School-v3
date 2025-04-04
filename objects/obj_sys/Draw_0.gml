var vx = instance_exists(obj_camera) ? global.obj_cam_vx : camera_get_view_x(view_camera[0])
var vy = instance_exists(obj_camera) ? global.obj_cam_vy : camera_get_view_y(view_camera[0])

//draw_sprite_ext(ref_web_asset("sigma", "asset_sprite"), 0, vx, vy, 1, 1, 0, c_white, 0.2)
//draw_sprite(ref_web_asset("https://i1.sndcdn.com/artworks-ZC6HKyiU8ae1bdiE-4vaFJQ-t240x240.jpg", "asset_sprite"), 0, vx + 500, vy)
//draw_sprite(ref_web_asset("https://i1.sndcdn.com/artworks-ZC6HKyiU8ae1bdiE-4vaFJQ-t240x240.jpg", "asset_sprite"), 0, vx, vy)
//draw_sprite(ref_web_asset("https://i1.sndcdn.com/artworks-ZC6HKyiU8ae1bdiE-4vaFJQ-t240x240.jpg", "asset_sprite"), 0, vx + 500, vy)
//draw_sprite(ref_web_asset("https://i1.sndcdn.com/artworks-ZC6HKyiU8ae1bdiE-4vaFJQ-t240x240.jpg", "asset_sprite"), 0, vx, vy)
//draw_text(0, 0, ref_web_asset("https://assets.jacqb.com/misc/test.txt", "asset_text"))
////draw_sprite(ref_web_asset("https://media.tenor.com/FZBn9kBeY1sAAAAM/goonicide-reverse.gif", "asset_gif"), 0, vx + 500, vy)
////draw_sprite(ref_web_asset(test_url1, "asset_sprite"), 0, vx, vy)
////draw_sprite(ref_web_asset(test_url1, "asset_sprite"), 0, vx + 500, vy)
//var snd = ref_web_asset("https://assets.jacqb.com/misc/test.ogg", "asset_sound")
//if !audio_is_playing(snd)
//	audio_play_sound(snd, 1, 0)

// render commandbar


if (global.command_bar_open)
{
	var bg_col = c_black
	var bg_height = 25
	var bg_alp = 0.75
	
	var txt_font = fnt_minecraft
	var bg_tl = [vx, (vy + (720 - bg_height))]// top left of the background box
	var bg_edge_sep_border = 4 // pixels around the edge of the bottom of the screen 
	
	// draw command line background
	draw_set_color(bg_col)
	draw_set_alpha(bg_alp)
	draw_rectangle(vx + (bg_edge_sep_border - 1), vy + (720 - bg_edge_sep_border), vx + (1280 - bg_edge_sep_border), (vy + 720) - (bg_height + bg_edge_sep_border), 0)
	
	// draw text
	draw_set_color(col_hex("a8a8a8"))
	draw_set_font(txt_font)
	draw_set_alpha(1)
	var fsize = font_get_size(txt_font)
	var y_offset = 0 - bg_edge_sep_border //3 //(abs(bg_height - fsize) / 2)// offset off of top of black bar to center text
	var x_offset = 3 + bg_edge_sep_border
	draw_text(bg_tl[0] + x_offset, ((vy + 720) - bg_height) + y_offset, global.command_bar_content)
	draw_set_color(c_white)
	if command_bar_blinking_cursor_state {
		var len = string_length(global.command_bar_content)
		var cursor = (command_bar_cursor_offset == -1) ? "_" : "|"
		var cursor_x_offset = string_width(string_region(global.command_bar_content, 0, command_bar_txt_insert_pos - 2)) + x_offset
		//draw_text(bg_tl[0] + x_offset, ((vy + 720) - bg_height) + y_offset, (string_region(global.command_bar_content, 0, _pos) + cursor))
		draw_text(bg_tl[0] + cursor_x_offset, ((vy + 720) - bg_height) + y_offset, cursor)
	}
}

if ((keyboard_check(vk_tab)) && global.game_debug)
{
	draw_ui_mob_spectate_list()
	global.ui_spectate_list_open = 1
	
	// handle changing index stuff
	if keyboard_check_pressed(vk_left)
		global.ui_spectate_list_index--
	if keyboard_check_pressed(vk_right)
		global.ui_spectate_list_index++
}
else
{
//	global.ui_spectate_list_index = 0
	global.ui_spectate_list_open = 0
//	if instance_exists(obj_camera) {obj_camera.camTarget = noone}
}

// render debug
if (global.show_mob_traces)
{
	var prefix = "obj_sys Step: (Rendering Mob Traces) "
	
	var variables_to_display = ["entity_id", "x", "y", "current_target", "lostTarget", "state", "dx", "trace_x", "trace_y"]
	
	var close_color = c_green
	var far_color = c_red
	
	var alp = 0.5
	var mob_preview_alp = 0.25
	var thickness = 3
	
	var tracing_supported = 1
	var c_zoom = (instance_exists(obj_camera) ? obj_camera.zoom : 1)
	
	with (obj_p_mob)
	{
		// if we dont have target_x then fake it ig
		if !variable_instance_exists(id, "target_x")
		{
			tracing_supported = 0
			target_x = x
			trace_x = []
			trace_y = []
			
			mob_preview_alp = 0
		}
		
		// render the line between mob and target x
		var _max = max(x, target_x)
		var _min = min(x, target_x)
		
		var y_offset = -(sprite_get_width(sprite_index) / 2)
		
		// color stuff
		var prog_to_target_x = min(((_min / _max)), 1)
		var _time = (power(prog_to_target_x, 8))
		var far_color_components = [color_get_red(far_color), color_get_green(far_color), color_get_blue(far_color)]
		var close_color_components = [color_get_red(close_color), color_get_green(close_color), color_get_blue(close_color)]
		var _r = lerp(close_color_components[0], far_color_components[0], _time)
		var _g = lerp(close_color_components[1], far_color_components[1], _time)
		var _b = lerp(close_color_components[2], far_color_components[2], _time)
		
		var line_color = make_color_rgb(_r, _g, _b)
		
		// draw line to target_x along with sprite and draw center line
		draw_sprite_ext_safe(sprite_index, image_index, target_x, y, dir, 1, 0, c_white, mob_preview_alp)
		draw_set_color(line_color)
		draw_set_alpha(tracing_supported * alp)
		draw_line_width(x, (y + y_offset), target_x, (y + y_offset), thickness * c_zoom) // target_x line
		draw_set_alpha(alp)
		draw_line_width(x, (y + y_offset) - 50, x + (dir * 100), (y + y_offset) - 50, thickness * c_zoom) // draw dir line
		draw_set_color(c_gray)
		draw_line_width(x, (y + y_offset), x, (y + y_offset) - sprite_get_height(sprite_index), thickness * c_zoom) // height line
		
		// render text above mob
		var txt_x_offset = 0 //(sprite_get_width(sprite_index) / 2)
		var txt_y_offset = -(sprite_get_height(sprite_index) / 2)
		var _text = "[" + object_get_name(object_index) + "]\n"
		
		for (var j = 0; j < array_length(variables_to_display); j++) {
			var variable = variables_to_display[j]
			var val = (variable_instance_exists(id, variable)) ? self[$ variable] : "N/A"
			_text += (variables_to_display[j] + " = " + string(val) + "\n")
		}
		draw_set_color(c_white)
		draw_set_font(fnt_minecraft)
		draw_set_align(fa_left, fa_top)
		draw_text((x + txt_x_offset), (y + txt_y_offset), _text)
		
		// draw markers on each trace, draw line if near portal
		var tracer_count = (global.mob_trace_count > 0) ? array_length(trace_x) : 0
		for (var j = 0; j < tracer_count; j++) {
			if !((trace_x[j] + trace_y[j]) < 1)
			{
				var _tx = trace_x[j]
				var _ty = trace_y[j]
				
				draw_sprite_ext_safe(sprite_index, image_index, _tx, _ty, (0.25 * dir), 0.25, 0, c_white, mob_preview_alp)
				draw_set_color(c_yellow)
				draw_set_alpha(alp)
				draw_text_ext(_tx, _ty, "Tracer " + string(j + 1), 0, 999)
				
				// check if target_x is near portal
				var _portal = point_near_portal(_tx, _ty, 50)
				if _portal {
					var _target_portal = portal_linked(_portal)
					var _tp_adj_y = y_to_floor(_target_portal.y)
					draw_set_color(c_purple)
					draw_line_width(_tx, y + y_offset, _target_portal.x, _tp_adj_y + y_offset, thickness * c_zoom)
					draw_sprite_ext_safe(sprite_index, image_index, _target_portal.x, _tp_adj_y, dir, 1, 0, c_white, mob_preview_alp)
				}
			}
		}

		// log
		var msg = (prefix + "In child instance " + string(object_get_name(object_index)))
		
		msg += "\n- target_x = " + string(target_x)
		+ "\n- trace_x = " + string(trace_x)
		+ "\n- trace_y = " + string(trace_y)
		+ "\n- prog_to_target_x = " + string(prog_to_target_x)
		
//		show_debug_message(msg)
	}
	
	with (obj_network_object)
	{
		variables_to_display = ["x", "y", "dx", "entity_id"]
		var y_offset = -(sprite_get_width(sprite_index) / 2)
		draw_set_alpha(alp)
		draw_line_width(x, (y + y_offset) - 50, x + (dir * 100), (y + y_offset) - 50, thickness * c_zoom) // draw dir line
		draw_set_color(c_gray)
		draw_line_width(x, (y + y_offset), x, (y + y_offset) - sprite_get_height(sprite_index), thickness * c_zoom) // height line
		
		// render text above mob
		var txt_x_offset = 0 //(sprite_get_width(sprite_index) / 2)
		var txt_y_offset = -(sprite_get_height(sprite_index) / 2)
		var _text = "[" + object_get_name(object_index) + "]\n"
		
		for (var j = 0; j < array_length(variables_to_display); j++) {
			var variable = variables_to_display[j]
			var val = (variable_instance_exists(id, variable)) ? self[$ variable] : "N/A"
			_text += (variables_to_display[j] + " = " + string(val) + "\n")
		}
		draw_set_color(c_white)
		draw_set_font(fnt_minecraft)
		draw_set_align(fa_left, fa_top)
		draw_text((x + txt_x_offset), (y + txt_y_offset), _text)
	}
}

// multiplayer stuff
if (multiplayer_menu_open) {
    draw_set_color(c_black);
    draw_set_alpha(0.8);
    draw_rectangle(room_width / 4, room_height / 4, room_width * 3 / 4, room_height * 3 / 4, false);

    draw_set_color(c_white);
    draw_set_alpha(1);
    var text_x = room_width / 4 + 50; // Adjusted text starting position
    draw_text(room_width / 2, room_height / 4 + 20, "Enter Multiplayer Details:");
    draw_text(text_x, room_height / 4 + 60, "Username: " + username);
    draw_text(text_x, room_height / 4 + 100, "Server IP: " + server_ip);
    draw_text(text_x, room_height / 4 + 140, "Port: " + server_port);
}

// render if we're speaking or not
//if global.speaking
if global.enable_voice_transcription
	draw_sprite_stretched_ext(spr_speaker_icon, 0, (vx + 20), (vy + 20), 50, 50, (global.speaking ? c_red : c_gray), global.current_volume)

if global.game_is_over
{
    if ((global.lifeCur <= 0))
    {
        draw_set_alpha((gio_t / 100))
        draw_set_color(c_black)
        draw_rectangle((vx - 200), (vy - 200), (vx + 1480), (vy + 920), false)
        draw_set_alpha(1)
        draw_set_color(c_white)
        draw_sprite_ext(spr_ui_gameover, 0, (vx + 640), (vy + 360), 1, 1, 0, c_white, ((gio_t - 100) / 100))
        if (!global.transition)
        {
            if ((gio_t < 400))
            {
                if ((gio_t == 100))
                    play_se(se_gameover, 1)
                if ((gio_t >= 180) && (gio_t < 220))
                {
                    draw_sprite_ext(spr_ui_gameover, 0, ((vx + 640) + irandom_range(-14, 14)), ((vy + 360) + irandom_range(-14, 14)), 1, 1, 0, c_white, 0.4)
                    draw_sprite_ext(spr_ui_gameover, 0, ((vx + 640) + irandom_range(-14, 14)), ((vy + 360) + irandom_range(-14, 14)), 1, 1, 0, c_white, 0.2)
                }
                gio_t+= adjust_to_fps(1)
                if ((gio_t >= 100) && keyboard_key_press(vk_return))
                    gio_t = 400
            }
            else
            {
                global.transition = 1
                global.trans_goto = rm_intro
                global.trans_col = 0
            }
        }
    }
}
draw_set_alpha(global.trans_alp)
draw_set_color(global.trans_col)
draw_rectangle((vx - 200), (vy - 200), (vx + 1480), (vy + 920), false)
draw_set_alpha(1)
if ((global.transition == 2))
{
    if ((global.clock_tk_spd != adjust_to_fps(1)))
    {
		clock_tick()
        if ((global.clock_trans_t > 0))
            global.clock_trans_t-= adjust_to_fps(1)
        else
        {
            global.clock_trans_t = -1
            global.clock_tk_spd = adjust_to_fps(1)
            global.transition = 0
        }
        draw_ui_clock(((vx - 201) + 640), ((vy - 56) + 360), 3)
    }
}
else if ((global.transition == 1))
{
    if ((global.trans_alp < 1))
        global.trans_alp += global.trans_spd
    else if ((global.trans_wait > 0))
        global.trans_wait-= adjust_to_fps(1)
    else if (!global.dialog_mode)
    {
        if ((global.trans_goto != -4))
        {
            if ((global.trans_goto == rm_intro))
                sys_game_restart()
            else
                room_goto(global.trans_goto)
            global.trans_goto = -4
        }
        global.transition = 0
    }
}
else if ((global.transition == 0))
{
    if ((global.trans_alp > 0))
        global.trans_alp -= global.trans_spd
    else
        global.trans_col = 0
}
if (!game_is_paused())
{
    if ((global.mini_dialog_line != ""))
    {
        mini_dialog_scl_to = 100
        if ((mini_dialog_char < ctext_length(global.mini_dialog_line)))
            mini_dialog_char += 0.5
        if ((mini_dialog_timer > 0))
            mini_dialog_timer--
        else
        {
            global.mini_dialog_line = ""
            mini_dialog_char = 0
        }
    }
    else
        mini_dialog_scl_to = 0
    mini_dialog_scl -= ((mini_dialog_scl - mini_dialog_scl_to) / 5)
}
draw_sprite_ext(spr_ui_dialog_mini, 0, (vx + 640), (vy + 100), (mini_dialog_scl / 100), 1, 0, c_white, 1)
draw_set_align(fa_center, fa_middle)
setFont("B", 21)
draw_set_color(c_white)
ctext_draw_mid((vx + 640), (vy + 100), global.mini_dialog_line, mini_dialog_char)
if ((dialog_skip > 0))
    dialog_skip--
if (global.dialog_mode && (global.clock_trans_t == -1))
{
    if ((global.dialog_num_curr <= global.dialog_num_total))
    {
        if ((global.dialog_spr == spr_memo_1) || (global.dialog_spr == spr_memo_2) || (global.dialog_spr == spr_memo_3) || (global.dialog_spr == spr_memo_4))
        {
            draw_sprite_ext(global.dialog_spr, 0, (vx + 640), (vy + 360), 1, 1, 0, c_white, 1)
            draw_sprite_ext(global.dialog_spr, 0, (vx + 640), (vy + 360), 1, 1, 0, c_black, (global.shaderOn ? 0.3 : 0))
            draw_set_align(fa_center, fa_middle)
            setFont("C", 21)
            draw_set_color(make_color_rgb(50, 50, 50))
            dialog_char = ctext_length(global.dialog_line)
            ctext_draw_mid((vx + 640), (vy + 360), global.dialog_line, dialog_char)
        }
        else
        {
            if ((global.dialog_line != " ") && (global.dialog_line != ""))
            {
                draw_sprite_ext(global.dialog_spr, 0, (vx + 640), (vy + 360), 1, 1, 0, c_white, 1)
                if global.dialog_show_box
                    draw_sprite(spr_ui_dialog_box, 0, (vx + 640), (vy + 600))
                draw_set_align(fa_left, fa_top)
                setFont("B", 21)
                if ((global.dialog_name != ""))
                {
                    draw_set_color(make_color_rgb(100, 100, 100))
                    draw_text((vx + 280), (vy + 530), (string(global.dialog_name) + ":"))
                    draw_set_color(c_white)
                    ctext_draw((vx + 280), (vy + 570), global.dialog_line, dialog_char)
                }
                else
                {
                    draw_set_color(c_white)
                    ctext_draw((vx + 280), (vy + 530), global.dialog_line, dialog_char)
                }
            }
            if global.dialog_do_fskip
            {
                draw_set_align(fa_right, fa_bottom)
                setFont("B", 16)
                if keyboard_check(vk_control)
                {
                    if ((dialog_fskip < 60))
                        dialog_fskip+= adjust_to_fps(1)
                    else
                    {
                        global.dialog_num_curr = (global.dialog_num_total + 1)
                        dialog_fskip = 0
                        if ((global.clock_hr == 12))
                        {
                            global.lastX = 4542
                            global.lastY = 4880
                        }
                    }
                    draw_pie_bar(((vx + 1280) - 114), ((vy + 720) - 16), dialog_fskip, 60, c_white, 12, 1, 4)
                    draw_set_color(c_white)
                    draw_text(((vx + 1280) - 10), (vy + 720), "Full Skip")
                }
                else
                {
                    draw_set_color(c_white)
                    draw_text(((vx + 1280) - 10), (vy + 720), "[Ctrl] Full Skip")
                    dialog_fskip = 0
                }
            }
        }
        if ((global.hscene_target == -4) && (global.dialog_hs_id != 0))
        {
            play_se(se_catch, 1)
            mob_id = global.dialog_hs_id
            global.dialog_hs_id = 0
            global.hscene_target = self; if check_is_server() sync_hscene_event();
            global.hscene_hide_fl = obj_dialog.hide_fl
            global.dialog_acting = 0
            global.trans_alp = 1
            with (obj_actor)
                instance_destroy()
        }
        else if global.dialog_hs_next
        {
            global.dialog_hs_next = 0
            obj_pkun.hs_stp++
            obj_pkun.hs_lp = -1
            obj_pkun.hs_snd_delay = 0
        }
        if ((global.dialog_line != " "))
        {
            if ((dialog_char < ctext_length(global.dialog_line))) && (global.dialog_se_start_delay <= 0)
                dialog_char += adjust_to_fps(global.dialog_text_reveal_time)
            else if ((global.dialog_choice_opt1 != ""))
            {
                draw_set_align(fa_center, fa_middle)
                setFont("B", 21)
                draw_set_color(((dialog_choice_ind == 1) ? c_white : make_color_rgb(100, 100, 100)))
                draw_text(((vx + 640) - 80), (vy + 644), string(global.dialog_choice_opt1))
                draw_set_color(((dialog_choice_ind == 2) ? c_white : make_color_rgb(100, 100, 100)))
                draw_text(((vx + 640) + 80), (vy + 644), string(global.dialog_choice_opt2))
            }
            else
                draw_sprite(spr_ui_dialog_arr, image_index, (vx + 640), (vy + 660))
            if (!global.menu_mode)
            {
                if ((global.dialog_choice_opt1 != ""))
                {
                    if keyboard_check_pressed(vk_left)
                    {
                        dialog_choice_ind = 1
                        play_se(se_select, 1)
                    }
                    else if keyboard_check_pressed(vk_right)
                    {
                        dialog_choice_ind = 2
                        play_se(se_select, 1)
                    }
                    else if ((dialog_choice_ind > 0) && keyboard_check_pressed(vk_return))
                    {
                        global.dialog_choice_out = ((dialog_choice_ind == 1) ? global.dialog_choice_opt1 : global.dialog_choice_opt2)
                        dialog_char = 0
                        dialog_choice_ind = 1
                        if instance_exists(obj_ending_handler)
                        {
                            obj_ending_handler.next = 1
                            global.dialog_choice_opt1 = ""
                            global.dialog_choice_opt2 = ""
                        }
                        else
                            global.dialog_num_curr++
                        play_se(se_select, 1)
                    }
                }
                else if (keyboard_check_pressed(vk_return) || (keyboard_check(vk_control) && (!dialog_skip)))
                {
                    dialog_skip = 10
                    if ((dialog_char < ctext_length(global.dialog_line)))
                        dialog_char = ctext_length(global.dialog_line)
                    else
                    {
                        dialog_char = 0
                        global.dialog_num_curr++
                        play_se(se_select, 1)
                    }
                }
            }
        }
    }
    else
    {
        global.dialog_mode = 0
        global.dialog_acting = 0
        global.dialog_show_box = 1
        global.dialog_name = ""
        global.dialog_line = ""
        global.dialog_num_curr = 1
        global.dialog_num_total = 0
        global.dialog_choice_opt1 = ""
        global.dialog_choice_opt2 = ""
        dialog_choice_ind = 1
        global.dialog_spr = spr_null
        if ((global.transition == 2))
            global.transition = 0
        dialog_char = 0
        if instance_exists(obj_camera)
            obj_camera.camTarget = -4
        with (obj_actor)
            instance_destroy()
        with (obj_dialog)
            instance_destroy()
        if global.dialog_goto
        {
            global.trans_goto = global.dialog_goto
            global.dialog_goto = -4
            global.transition = 1
        }
        global.dialog_do_fskip = 1
    }
}
if (!global.game_is_over) && !multiplayer_menu_open
{
    if ((global.menu_mode > 0))
    {
        draw_set_color(c_black)
        draw_set_alpha(0.4)
        draw_rectangle((vx - 200), (vy - 200), (vx + 1480), (vy + 920), false)
        draw_set_alpha(1)
    }
    if ((global.menu_mode == 0))
    {
        if ((menu_alp > 0))
            menu_alp -= adjust_to_fps(0.1)
        draw_sprite_ext(spr_ui_menu, 0, (vx + 640), (vy + 360), (0.5 + (0.5 * menu_alp)), (0.5 + (0.5 * menu_alp)), 0, c_white, menu_alp)
        draw_sprite_ext(spr_ui_menu, 1, ((vx + 640) + (18 + (100 * menu_alp))), (vy + 360), 1, 1, 0, c_white, menu_alp)
        draw_sprite_ext(spr_ui_menu, 2, (vx + 640), ((vy + 360) - (18 + (100 * menu_alp))), 1, 1, 0, c_white, menu_alp)
        draw_sprite_ext(spr_ui_menu, 3, ((vx + 640) - (18 + (100 * menu_alp))), (vy + 360), 1, 1, 0, c_white, menu_alp)
        draw_sprite_ext(spr_ui_menu, 4, (vx + 640), ((vy + 360) + (18 + (100 * menu_alp))), 1, 1, 0, c_white, menu_alp)
        if (instance_exists(obj_pkun) && keyboard_check_pressed(vk_backspace)) && !global.disable_game_keyboard_input
        {
            global.menu_mode = 1
            play_se(se_menu, 1)
			// sync_pkun_event()
        }
    }
    else if ((global.menu_mode == 1))
    {
        if ((menu_alp < 1))
            menu_alp += adjust_to_fps(0.1)
        else
        {
            draw_set_color(c_white)
            setFont("B", 21)
            draw_set_align(fa_center, fa_middle)
            draw_text((vx + 640), ((vy + 360) - 200), getText("menu_sett"))
            draw_text((vx + 640), ((vy + 360) + 200), getText("menu_back"))
            draw_set_halign(fa_right)
            draw_text(((vx + 640) - 190), (vy + 360), getText("menu_memo"))
            draw_set_halign(fa_left)
            draw_text(((vx + 640) + 190), (vy + 360), getText("menu_map"))
        }
        draw_sprite_ext(spr_ui_menu, 0, (vx + 640), (vy + 360), (0.5 + (0.5 * menu_alp)), (0.5 + (0.5 * menu_alp)), 0, c_white, menu_alp)
        draw_sprite_ext(spr_ui_menu, 1, ((vx + 640) + (18 + (100 * menu_alp))), (vy + 360), 1, 1, 0, c_white, menu_alp)
        draw_sprite_ext(spr_ui_menu, 2, (vx + 640), ((vy + 360) - (18 + (100 * menu_alp))), 1, 1, 0, c_white, menu_alp)
        draw_sprite_ext(spr_ui_menu, 3, ((vx + 640) - (18 + (100 * menu_alp))), (vy + 360), 1, 1, 0, c_white, menu_alp)
        draw_sprite_ext(spr_ui_menu, 4, (vx + 640), ((vy + 360) + (18 + (100 * menu_alp))), 1, 1, 0, c_white, menu_alp)
        if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(vk_backspace))
        {
            play_se(se_select, 1)
            global.menu_mode = 0
        }
        else if keyboard_check_pressed(vk_up)
        {
            key_pressed()
            play_se(se_menu, 1)
            global.menu_mode = 2
            global.setting_mode = 1
            global.setting_ind = 0
        }
        else if keyboard_check_pressed(vk_right)
        {
            global.menu_mode = 3
            play_se(se_menu, 1)
            play_se(se_paper, 1)
        }
        else if keyboard_check_pressed(vk_left)
        {
            global.key_delay = 30
            global.menu_mode = 4
            play_se(se_paper, 1)
        }
    }
    else if ((global.menu_mode == 3))
    {
        draw_ui_map()
        if keyboard_check_pressed(vk_backspace)
        {
            play_se(se_select, 1)
            global.menu_mode = 0
        }
    }
    else if ((global.menu_mode == 4))
        draw_ui_memolist()
    if global.setting_mode
    {	
		// Settings interaction stuff
        if ((room != rm_title))
            draw_ui_setting((vx + 470), (vy + 230))
		if keyboard_check_pressed(vk_tab)
		{
			// Switch pages on tab press
			global.settings_page++
			show_debug_message("Obj_sys draw, Tab pressed in settings page, adjusting page.")
		}
        if keyboard_check_pressed(vk_return)
        {
            play_se(se_select, 1)
			if (global.settings_page == 0)
			{
				if ((global.setting_ind == 3))
	                window_set_fullscreen((!window_get_fullscreen()))
	            else if ((global.setting_ind == 4))
	                global.shaderOn *= -1
	            else if ((global.setting_ind == 5))
	                global.cowardOn *= -1
	            else if ((global.setting_ind == 6))
	            {
	                if (!global.setting_ask)
	                    global.setting_ask = 1
	                else
	                {
	                    global.transition = 1
	                    global.trans_goto = rm_intro
	                    if ((global.menu_mode != 0))
	                        global.menu_mode = 0
	                    global.dialog_mode = 0
	                    global.setting_mode = 0
	                    global.setting_ask = 0
	                    sys_save_setting()
	                }
				}
            }
			if ((global.setting_ind == 7))
			{
				global.settings_page++ // Go to next page when enter is pressed	
			}
            if ((global.setting_ind == 8)) // Back button, ind was 7
            {
                if ((global.menu_mode != 0))
                    global.menu_mode = 0
                global.setting_mode = 0
                global.setting_ask = 0
                sys_save_setting()
            }

        }
        else if keyboard_check_pressed(vk_backspace)
        {
            play_se(se_select, 1)
            if ((global.menu_mode != 0))
                global.menu_mode = 0
            global.setting_mode = 0
            global.setting_ask = 0
            sys_save_setting()
        }
		
		// Handle key events after key delay
        if (!global.key_delay)
        {
			// Handle interactions on first page like normal <3
			if (global.settings_page == 0)
			{
	            if ((global.setting_ind == 1) || (global.setting_ind == 2))
	            {
	                if keyboard_check(vk_left)
	                {
	                    key_pressed()
	                    play_se(se_select, 1)
	                    if ((global.setting_ind == 1))
	                    {
	                        if ((global.vol_se > 0))
	                            global.vol_se -= 10
	                    }
	                    else if ((global.setting_ind == 2))
	                    {
	                        if ((global.vol_bgm > 0))
	                            global.vol_bgm -= 10
	                    }
	                }
	                else if keyboard_check(vk_right)
	                {
	                    key_pressed()
	                    play_se(se_select, 1)
	                    if ((global.setting_ind == 1))
	                    {
	                        if ((global.vol_se < 100))
	                            global.vol_se += 10
	                    }
	                    else if ((global.setting_ind == 2))
	                    {
	                        if ((global.vol_bgm < 100))
	                            global.vol_bgm += 10
	                    }
	                }
	            }
	            else if keyboard_check_pressed(vk_left)
	            {
	                key_pressed()
	                if (global.setting_ind != global.max_settings_lines_per_page) && (global.setting_ind != global.max_settings_lines_per_page + 1)
						play_se(se_select, 1)
	                if ((global.setting_ind == 0))
	                {
	                    if (!global.dialog_mode)
	                    {
	                        if ((global.language > 0))
	                            global.language--
	                        else
	                            global.language = 2
	                    }
	                }
	                else if ((global.setting_ind == 3))
	                    window_set_fullscreen((!window_get_fullscreen()))
	                else if ((global.setting_ind == 4))
	                    global.shaderOn *= -1
	                else if ((global.setting_ind == 5))
	                    global.cowardOn *= -1
	            }
	            else if keyboard_check_pressed(vk_right)
	            {
	                key_pressed()
	                if (global.setting_ind != global.max_settings_lines_per_page) && (global.setting_ind != global.max_settings_lines_per_page + 1)
						play_se(se_select, 1)
	                if ((global.setting_ind == 0))
	                {
	                    if (!global.dialog_mode)
	                    {
	                        if ((global.language < 2))
	                            global.language++
	                        else
	                            global.language = 0
	                    }
	                }
	                else if ((global.setting_ind == 3))
	                    window_set_fullscreen((!window_get_fullscreen()))
	                else if ((global.setting_ind == 4))
	                    global.shaderOn *= -1
	                else if ((global.setting_ind == 5))
	                    global.cowardOn *= -1
	            }
			}
			
			// Handle interactions on other settings pages
			else if !((global.setting_ind == global.max_settings_lines_per_page) || (global.setting_ind == global.max_settings_lines_per_page + 1))
			{
				// Check if we are in the custom settings, else we kill ourselves
				if (global.custom_settings_ui_index >= 0) && (global.custom_settings_ui_index < global.custom_settings_count)
				{
					var _setting = global.settings[global.custom_settings_ui_index]
					var _global_var = _setting._global_var
					var _changeRate = real(_setting._options.changeRate)
					var _type = _setting._options.type
					var _max = _setting._options.maxNum
					var _min = _setting._options.minNum
					var _ask = _setting._options.askConfirm
					var _keyDelay = _setting._options.keyDelay
					var _loop = _setting._options.loop
					var _changeInGame = _setting._options.changeInGame
					
					var disabled = (!_changeInGame && !(room == rm_title))
					//var exclusion = ((global.setting_ind == global.max_settings_lines_per_page) || (global.setting_ind == global.max_settings_lines_per_page + 1))
					
					if (keyboard_check_pressed(vk_return) && !(_type == "range")) && !disabled
					{
						play_se(se_select, 1)
						if (!global.setting_ask) && _ask
							global.setting_ask = 1
						else
						{
							global[$ _global_var] = flip_bool(global[$ _global_var])
							global.setting_ask = 0
						}
						if (global.apply_settings_on_change)
							sys_apply_settings();
					}
					if ((keyboard_check(vk_right) && !_keyDelay) || (keyboard_check_pressed(vk_right))) && !disabled
					{
						key_pressed()
						play_se(se_select, 1)
						show_debug_message("RIGHT ON SETTING " + string(_setting) + ", DISABLED: " + string(disabled))
						
						// increase
						if (!global.setting_ask) && _ask
							global.setting_ask = 1
						else
						{
							if (_type == "range")
							{
								var temp = (global[$ _global_var] + _changeRate)
								if (temp > _max)
									global[$ _global_var] = (_loop) ?  _min : _max
								else
									global[$ _global_var] = temp
							}
							else
								// flip since we're not a range
								global[$ _global_var] = flip_bool(global[$ _global_var])
							global.setting_ask = 0
						}
						if (global.apply_settings_on_change)
							sys_apply_settings();
					}
					else if ((keyboard_check(vk_left) && !_keyDelay) || (keyboard_check_pressed(vk_left))) && !disabled
					{
						key_pressed()
						play_se(se_select, 1)
						show_debug_message("LEFT ON SETTING " + string(_setting))
						
						// decrease
						if (!global.setting_ask) && _ask
							global.setting_ask = 1
						else
						{
							if (_type == "range")
							{
								var temp = (global[$ _global_var] - _changeRate)
								if (temp < _min)
									global[$ _global_var] = (_loop) ?  _max : _min
								else
									global[$ _global_var] = temp
							}
							else
								// flip since we're not a range
								global[$ _global_var] = flip_bool(global[$ _global_var])
							global.setting_ask = 0
						}
						if (global.apply_settings_on_change)
							sys_apply_settings();
					}
				}
//				else
//					show_debug_message("WHAT THE SIGMA!!")
			}
			
			// Always handle interaction on page button, regardless of page #
			if keyboard_check_pressed(vk_right) {
				play_se(se_select, 1)
				if ((global.setting_ind == 7))
						global.settings_page++
			}
			else if keyboard_check_pressed(vk_left) {
				play_se(se_select, 1)
				if ((global.setting_ind == 7))
						global.settings_page--
			}
			// Handle movement wrap around and boundaries/limits
            if keyboard_check(vk_up)
            {
                key_pressed()
                play_se(se_select, 1)
                global.setting_ask = 0
                if ((global.setting_ind > 0))
                {
					var exclusion = (global.setting_ind == 8) 
                    if ((room == rm_title) && (global.setting_ind == 7)) && (global.settings_page == 0) // Skip "Go To Title" in title, going up
                        global.setting_ind = 5
                    else if ((global.custom_settings_ui_index - 1) > (array_length(global.settings) - 1)) && !exclusion
					{
						var last_element = (global.settings_page_end_index - ((global.settings_page - 1) * global.max_settings_lines_per_page)) - 1
						global.setting_ind = last_element
						show_debug_message("GOING UP FOR BALLS PENIS WHATEVER, EXCLUSION = " + string(exclusion) + ", LAST ELEMENT SETTING_IND = " + string(last_element))
					}
					else
                        global.setting_ind--

					// Wrap between empty space in the middle going up on other pages
					        //global.settings_page_start_index
							//global.settings_page_end_index
					//if global.settings_page != 0 && ((global.setting_ind < 7) && (global.setting_ind > global.settings_page_end_index))
					//	global.setting_ind = global.settings_page_end_index - 1
                }
                else
                    global.setting_ind = 8
            }
            else if keyboard_check(vk_down)
            {
                key_pressed()
                play_se(se_select, 1)
                global.setting_ask = 0
                if ((global.setting_ind < 8))
                {
					var exclusion = (global.setting_ind == 7) || (global.setting_ind == 8) 
                    if ((room == rm_title) && (global.setting_ind == 5)) && (global.settings_page == 0) // Skip "Go To Title" in title, going down
                        global.setting_ind = 7
                    else if (global.custom_settings_ui_index >= (array_length(global.settings) - 1)) && !exclusion
					{
						global.setting_ind = global.max_settings_lines_per_page
						show_debug_message("GOING DOWN FOR BALLS PENIS WHATEVER, EXCLUSION = " + string(exclusion))
					}
					else
                        global.setting_ind++
						
					// Wrap between empty space in the middle going down on other pages
					        //global.settings_page_start_index
							//global.settings_page_end_index
					//if global.settings_page != 0 && (global.setting_ind == global.settings_page_end_index)
					//	global.setting_ind = 7
                }
                else
                    global.setting_ind = 0
            }
        }
    }
}
if global.game_debug
{
    var debug_log = ((("===== Game =====\nFPS:" + string(fps)) + "\nGameDir = ") + string(global.game_dir))
		debug_log += "\nsettings_ind = " + string(global.setting_ind) + "\nglobal.custom_settings_ui_index = " + string(global.custom_settings_ui_index) + "\ncustom_settings_count = " + string(array_length(global.settings))
    draw_set_align(fa_left, fa_top)
    draw_set_alpha(1)
    setFont("B", 16)
    draw_set_color(c_white)
	if instance_exists(obj_camera) {
		var ct = obj_camera.camTarget
		var obj_name = (instance_exists(ct)) ? object_get_name(ct.object_index) : ""
		debug_log += ("\n===== Camera =====\nx = " + string(obj_camera.x) + "\ny = " + string(obj_camera.y) + "\nzoom = " + string(obj_camera.zoom) + "\ncamTarget = " + string(obj_camera.camTarget) + " (" + string(obj_name) + ")")
	}
	if instance_exists(obj_pkun)
        debug_log += ((((((((((((((((((("\n===== Player =====\nlocation = " + string(pkun_get_location(1))) + "\nport = ") + string(obj_pkun.portalPort)) + "\nx = ") + string(obj_pkun.x)) + "\ny = ") + string(obj_pkun.y)) + "\nhs_stp = ") + string(obj_pkun.hs_stp)) + "\nhs_spr = ") + sprite_get_name(obj_pkun.hs_spr)) + "\nhs_ind = ") + string(obj_pkun.hs_ind)) + "\nhs_lp = ") + string(obj_pkun.hs_lp)) + "\nhs_snd_prev = ") + audio_get_name(obj_pkun.hs_snd_prev)) + "\nmob numbers = ") + string(instance_number(obj_p_mob)) + "\nroom = " + string(room))
    if global.dialog_mode
        debug_log += ((((((((((("\n===== Dialog =====\ndialog_mode = " + string(global.dialog_mode)) + "\ndialog_name = ") + global.dialog_name) + "\ndialog_line = ") + global.dialog_line) + "\ndialog_num = ") + string(global.dialog_num_curr)) + "/") + string(global.dialog_num_total)) + "\nobj_dialog = ") + string(instance_number(obj_dialog)) + "\ndialog_se = " + string(global.dialog_se) + "\ndialog_se_instance = " + string(global.dialog_se_instance))
	draw_text(vx, vy, debug_log)
}

if is_multiplayer() {
	draw_set_color((check_is_server()) ? c_blue : c_red)
	draw_text(vx, vy, string_upper(check_is_server() ? "[SERVER]" : "[CLIENT]") + " [" + string(obj_multiplayer.network.connection_state) + "] [Recieved: " + string(global.multiplayer_packets_recieved) + "] [Sent: " + string(global.multiplayer_packets_sent) + "]")
}