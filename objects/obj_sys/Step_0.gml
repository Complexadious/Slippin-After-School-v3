// multiplayer stuff
	// targetting stuff
if (struct_names_count(global.targetting_cached) > 0) { // decrease or remove expired timers
	var _t = struct_get_names(global.targetting_cached)

	for (var l = array_length(_t) - 1; l >= 0; l--) {
		if (global.targetting_cached[$ _t[l]][0] > 0)
			global.targetting_cached[$ _t[l]][0]-= adjust_to_fps(1) //(target_is_near_obj(real(_t[l]))) ? adjust_to_fps(5) : adjust_to_fps(1)
		else
			struct_remove(global.targetting_cached, _t[l])
	}
}

if keyboard_check_pressed(ord("K")) && !global.disable_game_keyboard_input {
	room_goto(rm_game)
	global.skip_clock = 1
}

if keyboard_check_pressed(ord("Y")) && instance_exists(obj_pkun) && !global.disable_game_keyboard_input {
	show_debug_message("SYS, RUNNING CREATE PLAYER!")
	global.player = new player_entity("testusernameorsum", obj_pkun.x, obj_pkun.y, obj_pkun.dir)
	global.player.create()
}

if keyboard_check_pressed(ord("C")) && !global.disable_game_keyboard_input && global.game_debug {
	global.cowardOn = flip_bool(global.cowardOn)
}

//if keyboard_check_pressed(ord("L")) && global.game_debug && !global.disable_game_keyboard_input
//{
//	// Define the command for the executable
//	var command;
//	//command = "\"C:\\Users\\proul\\Downloads\\AutoClicker-3.0.exe\"";
//	command = program_directory + "\\Slippin After School v3.exe\""

//	// Execute the program asynchronously
//	var process_id;
//	process_id = ProcessExecuteAsync(command);
//}

if keyboard_check_pressed(vk_f1) {  // reset and redownload all of the shit
	check_web_asset_references()
	if is_multiplayer()
		close_server()
	else
		start_server()
}

if keyboard_check_pressed(vk_f2) {
	join_server()	
}

if keyboard_check_pressed(vk_f3) {
	if is_multiplayer() {
		do_packet(new PLAY_CB_SET_HSCENE(1, 4, 0, se_catch, 1, 1), string(1))	
	}
}

if keyboard_check_pressed(vk_home) {
	sys_game_restart()	
}

// Things that disable general keyboard input for interactions and movement and such
if (global.command_bar_open)
	global.disable_game_keyboard_input = 1
else
	global.disable_game_keyboard_input = 0

// Things that hide camera ui
if (global.command_bar_open)
	global.camera_hide_ui = 1
else
	global.camera_hide_ui = 0	

// command bar handler
if (keyboard_check_pressed(vk_escape) && global.command_bar_open) || (((keyboard_check_pressed(global.keybinds[$ "commandBarOpenCommand"]) && !global.command_bar_open) || keyboard_check_pressed(global.keybinds[$ "commandBarOpenChat"]) && ((room != rm_title) && (room != rm_intro)) && (!global.command_bar_open))) {
	keyboard_clear(global.keybinds[$ "commandBarOpenChat"])
	keyboard_clear(keyboard_key)
	keyboard_key = 0
	toggle_command_bar()
}

if (global.command_bar_open)
{
	if instance_exists(obj_pkun)
		obj_pkun.intrTarget = noone
	
	var content_len = string_length(global.command_bar_content)
	command_bar_txt_insert_pos = content_len - command_bar_cursor_offset
	
	if (command_bar_history_mv_index == -1) {
		command_bar_curr_text = global.command_bar_content // save before so can go back
	}
	
	// blinking cursor
	if command_bar_blinking_cursor_tmr > 0
		command_bar_blinking_cursor_tmr -= adjust_to_fps(1)
	else
	{
		command_bar_blinking_cursor_tmr = 20
		command_bar_blinking_cursor_state = !command_bar_blinking_cursor_state
	}
	
	var hist_len = array_length(global.command_bar_history)
	
	if keyboard_check(vk_enter) {
		if (string_char_at(global.command_bar_content, 1) == "/") {
			cmd_execute_command(string_delete(global.command_bar_content, 1, 1))
			show_debug_message("COMMAND = '" + string_delete(global.command_bar_content, 1, 1) + "'")
		} else {
			show_debug_message("NOT COMMAND, IS CHAT, MSG = " + global.command_bar_content) 
			with (obj_pkun) {
				miniMsgStr = global.command_bar_content
				miniMsgTmr = 300
			}
		}
		if (global.command_bar_content != "") {
			if (hist_len > 0) && (global.command_bar_content != global.command_bar_history[hist_len - 1])
				array_push(global.command_bar_history, global.command_bar_content)
			else if (hist_len == 0)
				array_push(global.command_bar_history, global.command_bar_content)
		}
		toggle_command_bar()
	}
	
	// handle text being typed into bar and cursor move key shit
	if keyboard_check(vk_control) {
		if keyboard_check_pressed(ord("V"))
			global.command_bar_content = string_insert(clipboard_get_text(), global.command_bar_content, command_bar_txt_insert_pos)
	} else if (keyboard_check(vk_anykey)) {
		if !(keyboard_lastkey == command_bar_last_char) // not pressing same prev key
			command_bar_hold_key_tmr = 30
		
		show_debug_message("FUCK ME!! AHH, keyboard_lastkey = " + string(keyboard_lastkey) + ", cmdlastchar = " + string(command_bar_last_char) + ", tmr = " + string(command_bar_hold_key_tmr) + ", key delay = " + string(global.key_delay))
		if ((command_bar_hold_key_tmr <= 0) || (command_bar_hold_key_tmr == 30)) && !key_delay() {
			show_debug_message("ADDING KEY!! key = " + string(keyboard_key))
			cmd_bar_handle_key_press(keyboard_key)
			command_bar_hold_key_tmr_timeout = 0
		}
		
		if (command_bar_hold_key_tmr > 0)
			command_bar_hold_key_tmr-= adjust_to_fps(1)
	} else {
		if (command_bar_hold_key_tmr_timeout < 2)
			command_bar_hold_key_tmr_timeout+= adjust_to_fps(1)
		else { // over max time, reset timer
			command_bar_hold_key_tmr = 30 // reset timer
		}
	}

	if command_bar_cursor_offset < -1
		command_bar_cursor_offset = -1
	
	if command_bar_cursor_offset > string_length(global.command_bar_content) - 1
		command_bar_cursor_offset = string_length(global.command_bar_content) - 1
	
    // History navigation
    if (hist_len > 0) {
        if (keyboard_check_pressed(vk_up)) {
            if (command_bar_history_mv_index < hist_len - 1) {
                command_bar_history_mv_index++;
            }

//            keyboard_string = global.command_bar_history[
            global.command_bar_content = global.command_bar_history[
                (hist_len - 1) - command_bar_history_mv_index
            ];
        }

        if (keyboard_check_pressed(vk_down)) {
            if (command_bar_history_mv_index > -1) {
                command_bar_history_mv_index--;
            }

            if (command_bar_history_mv_index == -1) {
//                keyboard_string = command_bar_curr_text; // Clears input when reaching the newest position
                global.command_bar_content = command_bar_curr_text; // Clears input when reaching the newest position
            } else {
//                keyboard_string = global.command_bar_history[
                global.command_bar_content = global.command_bar_history[
                    (hist_len - 1) - command_bar_history_mv_index
                ];
            }
        }
    }
}

// Handle input if the menu is open
if (multiplayer_menu_open) {
    switch (menu_focus) {
        case 0: // Username input
            if (keyboard_check_pressed(vk_enter)) {
                username = get_string("Enter Username:", username);
                menu_focus = 1; // Move to the next field
            }
            break;
        case 1: // Server IP input
            if (keyboard_check_pressed(vk_enter)) {
                server_ip = get_string("Enter Server IP:", server_ip);
                menu_focus = 2; // Move to the next field
            }
            break;
        case 2: // Server Port input
            if (keyboard_check_pressed(vk_enter)) {
                server_port = get_string("Enter Port:", server_port);
                multiplayer_menu_open = false; // Close the menu
                global.menu_mode = 0; // Reset menu mode (if applicable)
                initiate_connection(username, server_ip, real(server_port)); // Initiate connection
            }
            break;
    }
}



// Page system bounds check
/// Basic wrapping from 0 -> 8 and 8 -> 0
if (global.settings_page < 0) global.settings_page = global.max_settings_pages;
if (global.settings_page > global.max_settings_pages) global.settings_page = 0;

global.custom_settings_ui_index = (global.settings_page * global.max_settings_lines_per_page) + (global.setting_ind - global.max_settings_lines_per_page)

if ((global.bgm_curr != -4))
{
    if (!audio_is_playing(global.bgm_curr))
        audio_play_sound(global.bgm_curr, 0, true)
    audio_sound_gain(global.bgm_curr, (global.vol_bgm / 100), 0)
//	if (game_is_paused() && audio_is_playing(global.bgm_curr))
//		audio_sound_gain(global.bgm_curr, ((global.vol_bgm / 100) / 2), 0)
		
	// if we're in a menu, make the bgm quieter
	if (global.menu_mode && audio_is_playing(global.bgm_curr))
		audio_sound_gain(global.bgm_curr, ((global.vol_bgm / 100) / 2), 0)
	else
		audio_sound_gain(global.bgm_curr, (global.vol_bgm / 100), 0)
}
if ((global.bell_timer > 0))
    global.bell_timer-= adjust_to_fps(1)
else if ((global.bell_count > 0))
{
    global.bell_count-= adjust_to_fps(1)
    global.bell_timer = (120)
    play_se(se_bell_ding, 1)
}
if ((global.key_delay > 0))
    global.key_delay-= adjust_to_fps(1)
if keyboard_check_pressed(vk_f4)
    window_set_fullscreen((!window_get_fullscreen()))
if keyboard_check_pressed(vk_f12)
{
    if global.dialog_mode
        global.dialog_num_curr = (global.dialog_num_total + 1)
    global.game_debug *= -1
    show_debug_overlay(global.game_debug)
}
if global.dialog_se_start_delay > 0
	global.dialog_se_start_delay-= adjust_to_fps(1)
if (global.dialog_se != -4) && global.dialog_se_start_delay <= 0
{
	// play it if it exists and not currently in menu, and we haven't played it before (prevents looping)
	if (!audio_is_playing(global.dialog_se) && !global.menu_mode && !global.dialog_played_se)
	{
		global.dialog_se_instance = play_se(global.dialog_se, 1)
		global.dialog_played_se = 1	
	}
		
	// pause audio if game paused
	if audio_is_playing(global.dialog_se) && global.menu_mode
		audio_pause_sound(global.dialog_se)
	else
		audio_resume_sound(global.dialog_se)
		
	
//	else if game_is_paused() && audio_is_playing()
}