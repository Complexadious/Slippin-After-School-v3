event_inherited()

if ((!game_is_paused()) && (!global.timeStop) && (!police_stop()) && (__disable_ai <= 0)) || actor
{
    if ((soundDelay > 0))
        soundDelay-= adjust_to_fps(1)
    if ((state != (0)))
    {
        if ((x < target_x))
        {
			mob_set_dir(1)
			mob_move(move * dir, 0)
            //dir = 1
            //x += adjust_to_fps(8)
        }
        else
        {
			mob_set_dir(-1)
			mob_move(move * dir, 0)
            //dir = -1
            //x -= adjust_to_fps(8)
        }
    }
    if ((state == (2)))
    {
        set_sprite(spr_kuchi_run, 1)
        if ((!soundDelay) && check_index(0))
        {
            soundDelay = 10
            mob_play_ds(se_step)
        }
        if (target_is_near() && (!((current_target.hiding && lostTarget)))) && (abs(current_target.y - y) < 25) // y must match?
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
        if ((!((current_target.hiding && lostTarget))) && target_is_near() && (distance_to_object(current_target) < 2000))
        {
            mob_set_state(2)
            lostTarget = 0
        }
        if ((state == (1)))
        {
            set_sprite(spr_kuchi_run, 1)
            if ((!soundDelay) && check_index(0))
            {
                soundDelay = 10
                mob_play_ds(se_step)
            }
            if ((abs((x - target_x)) < 20))
            {
                timer = irandom_range(150, 400)
                mob_set_state(0)
            }
        }
        else if ((state == (0)))
        {
            set_sprite(spr_kuchi_idle, (1/3))
            if ((timer > 0))
                timer-= adjust_to_fps(1)
            else
                mob_wander(1)
        }
    }
    if ((state == (2)) && place_meeting(x, y, current_target) && (!current_target.immortal)) && !actor
    {
        if (!lostTarget) && current_target.object_index == obj_pkun
        {
            play_se(se_catch, 1)
            global.hscene_target = self; if check_is_server() sync_hscene_event();
            global.trans_alp = 1
            global.hscene_hide_fl = 1
        }
    }
}
else
    image_speed = 0