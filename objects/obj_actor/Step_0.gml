if (soundDelay > 0)
    soundDelay--
//show_debug_message("Actor: " + string(role) + " at x:" + string(x) + " y:" + string(y))
//if (!((global.menu_mode || global.hscene_target != -4 || global.setting_mode || global.transition)))
if (!((global.menu_mode || global.hscene_target != -4 || global.setting_mode || (global.transition && global.transition != 2))))
{
    if (len > -1 && len >= spd)
    {
        if (spd != 0)
            state = "move"
        len -= spd
        x += (dir * spd)
    }
    else if (len != -1)
    {
        global.dialog_num_curr++
        state = "idle"
        len = -1
        actor_use_portal(role == "shota")
    }
    if (role == "shota")
    {
        obj_pkun.x = x
        obj_pkun.y = y
        obj_pkun.dir = dir
        if (state == "idle")
            set_sprite(spr_pkun_idle, (1/3))
        else if (state == "move")
        {
            if (spd > 4)
                set_sprite(spr_pkun_dash, 1)
            else
                set_sprite(spr_pkun_walk, 0.5)
            if ((!soundDelay) && (check_index(0) || check_index(3)))
            {
                soundDelay = 10
				if (room != rm_forest)
					play_se(choose(se_step_a_1, se_step_a_2, se_step_a_3), (0.35 + (spd > 6 ? 0.25 : 0)))
				else
					play_se(choose(se_gravel_step_1, se_gravel_step_2, se_gravel_step_3), (0.35 + (spd > 6 ? 0.25 : 0)))
            }
        }
    }
    else if (role == "redmask")
    {
        if (state == "idle")
            set_sprite(spr_kuchi_idle, (1/3))
        else if (state == "move")
        {
            set_sprite(spr_kuchi_run, 1)
            if ((!soundDelay) && check_index(0))
            {
                soundDelay = 10
                mob_play_ds(se_footslap)
            }
        }
        if (!obj_pkun.hiding)
        {
            mob_play_ds(se_door_slide)
            with (obj_pkun)
            {
                play_se(intrTarget.se_in, 1)
                intrTarget.shake = 20
                x = intrTarget.x
                hiding = 1
            }
        }
    }
	else if (role == "custom") 
	{
	    if (state == "idle")
		{
	        set_sprite(idle_sprite, image_speed);
			sprite_index = idle_sprite
		}
	    else if (state == "move")
	    {
	        set_sprite(walk_sprite, image_speed);
			sprite_index = walk_sprite
	        if (!soundDelay && walk_sound != -4)
	        {
	            // Check if current frame matches any of the sound indexes
	            var play_sound = false;
	            for(var i = 0; i < array_length(sound_index); i++) {
	                if(check_index(sound_index[i])) {
	                    play_sound = true;
	                    break;
	                }
	            }
            
	            if(play_sound) {
	                soundDelay = sound_delay;
	                play_se(walk_sound, 1);
	            }
	        }
	    }
		if ((!obj_pkun.hiding) && make_pkun_hide)
        {
            mob_play_ds(se_door_slide)
            with (obj_pkun)
            {
                play_se(intrTarget.se_in, 1)
                intrTarget.shake = 20
                x = intrTarget.x
                hiding = 1
            }
        }
	}
    else if (role == "hanako")
    {
        if (state == "idle")
            set_sprite(spr_hanako_idle, (1/3))
    }
    else if (role == "item")
        set_sprite(spr_item_flick, 1)
}
else
    image_speed = 0
