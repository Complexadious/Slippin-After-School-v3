// just in case trans_alp isnt 0 after intro, which can prevent menu from showing up
if (trans_alp_intro_correction_timer > 0)
	trans_alp_intro_correction_timer-= adjust_to_fps(1)
else if trans_alp_intro_correction_active
{
	global.trans_alp = 0
	trans_alp_intro_correction_active = 0 // prevent it from running all the time
	show_debug_message("obj_title, forcefully corrected trans_alp")
}


// fix shit
global.trans_spd = adjust_to_fps(0.01)

if keyboard_check_pressed(vk_return) && !global.trans_goto
	global.trans_alp = 0

instance_create_depth(random(1320), -50, 0, obj_efct_rain)
if (zspd > 5)
{
    zoom -= adjust_to_fps((zoom - 20 * global.transition) / zspd)
    zspd -= adjust_to_fps((300 - zspd) / 20)
}
else
    zoom -= adjust_to_fps((zoom - 20 * global.transition) / 5)
if (menu_alp >= 0.1 && (!global.setting_mode) && (!global.transition)) && !(obj_sys.multiplayer_menu_open)
{
    if keyboard_check_pressed(vk_return)
    {
        play_se(se_select, 1)
        if (menu_ind == 0)
        {
            global.transition = 1
            global.trans_goto = rm_game
            global.trans_wait = 160
            play_se(se_walkopen, 1)
            zspd = 299
        }
        else if (menu_ind == 1 && global.clock_hr_load)
        {
            sys_load_stage(0)
            global.transition = 1
            global.trans_goto = rm_game //rm_forest
            global.trans_wait = 160
            play_se(se_walkopen, 1)
            zspd = 299
        }
        else if (menu_ind == 2 && (!global.gallery_lock))
        {
            global.transition = 1
            global.trans_goto = rm_gallery
            global.trans_wait = 160
            play_se(se_walkopen, 1)
            zspd = 299
        }
        else if (menu_ind == 3)
        {
            global.setting_mode = 1
            global.setting_ind = 0
        }
        else if (menu_ind == 4)
            game_end()
    }
    else if (!global.key_delay)
    {
        if keyboard_check(vk_up)
        {
            key_pressed()
            play_se(se_select, 1)
            if (menu_ind > 0)
            {
                if (menu_ind == 3)
                {
                    if global.gallery_lock
                        menu_ind -= (1 + (global.clock_hr_load == -1))
                }
                else if (menu_ind == 2)
                    menu_ind -= global.clock_hr_load == -1
                menu_ind--
            }
            else
                menu_ind = 4
        }
        else if keyboard_check(vk_down)
        {
            key_pressed()
            play_se(se_select, 1)
            if (menu_ind < 4)
            {
                if (menu_ind == 0)
                {
                    if (global.clock_hr_load == -1)
                        menu_ind += (1 + global.gallery_lock)
                }
                else if (menu_ind == 1)
                    menu_ind += global.gallery_lock
                menu_ind++
            }
            else
                menu_ind = 0
        }
    }
}
