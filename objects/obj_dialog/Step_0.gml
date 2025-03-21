/// @description Insert description here
// You can write your code in this editor

// handle sounds
//if (se_instance == -4 && se != -4)
//	se_instance = audio_play_sound(se, 999, false)
//if global.menu_mode && audio_is_playing(se_instance)
//	audio_pause_sound(se_instance)
//if audio_is_paused(se_instance)
//	audio_resume_sound(se_instance)
//if global.dialog_line != d_line && se_instance != -4
//	audio_stop_sound(se_instance)

if ((global.dialog_num_curr <= global.dialog_num_total))
{
    if ((global.dialog_num_curr != curr))
    {
        curr = global.dialog_num_curr
        global.dialog_line = d_line[curr]
        global.dialog_name = d_name[curr]
        global.dialog_hs_next = d_hs_next[curr]
        global.dialog_hs_id = d_hs_id[curr]
		if audio_is_playing(global.dialog_se)
			audio_stop_sound(global.dialog_se)
		global.dialog_se = d_se[curr]
		global.dialog_played_se = 0
		global.dialog_se_start_delay = d_se_start_delay[curr]
		if ((global.dialog_se != -4) && (d_reveal_time != -4))
			global.dialog_text_reveal_time = d_reveal_time[curr]
		else
			global.dialog_text_reveal_time = 0.5
//		show_debug_message("Set global se for dialog sound")
        if ((d_trans[curr] != -1))
            global.transition = d_trans[curr]
        if ((d_choice_at != -1) && (d_choice_at == curr))
        {
            global.dialog_choice_opt1 = d_choice_opt1
            global.dialog_choice_opt2 = d_choice_opt2
            global.dialog_choice_out = ""
        }
        if ((d_spr[curr] != -4))
            global.dialog_spr = d_spr[curr]
        if (instance_exists(obj_camera) && (d_view[curr] != -1))
        {
            if ((d_view[curr] != -4))
            {
                if string_pos("obj_", d_view[curr])
                    obj_camera.camTarget = asset_get_index(d_view[curr])
                else
                    obj_camera.camTarget = dialog_find_actor(d_view[curr])
            }
            else
                obj_camera.camTarget = -4
        }
        dialog_play_act()
    }
}
else
    instance_destroy()
