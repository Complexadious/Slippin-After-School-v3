var current_target = get_closest_target(x, y, id)

/// @description Insert description here
// You can write your code in this editor
if ((!game_is_paused()) && (!obj_pkun.timeStop) && (!police_stop()))
{
	if yy <= 0 && fall_timer > 0
		fall_timer-= adjust_to_fps(1)
    if ((soundDelay > 0))
        soundDelay-= adjust_to_fps(1)
    if ((state != (0)) && (yy <= 0) && (((image_index >= 1) && (image_index < 4)) || ((image_index >= 5) && (image_index < 8))))
    {
        if ((x < target_x))
        {
			mob_set_dir(1)
			mob_move(move * dir, 0)
            //dir = 1
            //x += adjust_to_fps(7)
        }
        else
        {
			mob_set_dir(-1)
			mob_move(move * dir, 0)
            //dir = -1
            //x -= adjust_to_fps(7)
        }
    }
    if ((state == (2)))
    {
        if ((yy > 0))
        {
            set_sprite(spr_ladypaint_idle, 0)
            yy -= adjust_to_fps(20)
        }
        else
        {
            set_sprite(spr_ladypaint_walk, 0.5)
            if ((!soundDelay) && (check_index(1) || check_index(5)))
            {
                soundDelay = 20
                mob_play_ds(choose(se_creak_1, se_creak_2, se_creak_3, se_creak_4))
            }
        }
        if (target_is_near() && (!((current_target.hiding && lostTarget))))
        {
            target_x = current_target.x
            lostTarget = 0
            mob_init_trace()
        }
        else
            mob_track_trace()
    }
    else if ((state == (1)) || (state == (0)))
    {
        if ((!((current_target.hiding && lostTarget))) && target_is_near() && (yy == 0) && (distance_to_object(current_target) < 2000))
        {
            mob_set_state(2)
            lostTarget = 0
        }
        if (!target_is_near())
        {
            if ((lifespan > 0))
                lifespan-= adjust_to_fps(1)
            else if ((yy <= 0))
                instance_destroy()
            else
            {
                var to = noone
                var list = ds_list_create()
                with (obj_lp_sp)
                {
                    if ((distance_to_object(current_target) > 2000) || (!target_is_near()))
                        ds_list_add(list, id)
                }
                to = ds_list_find_value(list, irandom((ds_list_size(list) - 1)))
                //mob_set_x(to.x)
                //y = (560 + (720 * floor((to.y / 720))))
				mob_set_pos(to.x, (560 + (720 * floor((to.y / 720)))))
                ds_list_destroy(list)
                lifespan = 600
            }
        }
        if ((state == (0)))
        {
            if ((yy <= 0))
            {
                if ((timer > 0))
                    timer-= adjust_to_fps(1)
                else
                    mob_wander(1)
            }
            else
            {
                sprite_index = spr_ladypaint_idle
                if ((distance_to_object(current_target) >= 400))
                {
                    if ((timer > 0))
                        timer-= adjust_to_fps(1)
                    else
                    {
                        timer = irandom_range(30, 60)
                        image_index = irandom(2)
                    }
                }
                else if ((distance_to_object(current_target) >= 10))
                    image_index = ((current_target.x < x) ? 2 : 1)
                else
                {
                    timer = 0
                    mob_set_state(2)
                    lostTarget = 0
                }
            }
        }
        else if ((state == (1)))
        {
            set_sprite(spr_ladypaint_walk, 0.5)
            if ((!soundDelay) && (check_index(1) || check_index(5)))
            {
                soundDelay = 20
                mob_play_ds(choose(se_creak_1, se_creak_2, se_creak_3, se_creak_4))
            }
            if ((abs((x - target_x)) < 40))
            {
                timer = 0
                mob_set_state(0)
            }
        }
    }
    if ((yy <= 0) && (state == (2)) && place_meeting(x, y, current_target) && (!current_target.immortal)) && fall_timer <= 0
    {
        if (!lostTarget) && current_target.object_index == obj_pkun
        {
            play_se(se_catch, 1)
            global.hscene_target = self; if check_is_server() sync_hscene_event();
            global.trans_alp = 1
        }
    }
}
else
    image_speed = 0

event_inherited()