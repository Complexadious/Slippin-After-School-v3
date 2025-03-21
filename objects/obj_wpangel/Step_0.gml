var current_target = get_closest_target(x, y, id)

/// @description Insert description here
// You can write your code in this editor
if ((!game_is_paused()) && (!obj_pkun.timeStop) && (!police_stop()))
{
    if (!stop)
    {
        if ((x < target_x))
        {
            dir = 1
            x += adjust_to_fps(6)
        }
        else
        {
            dir = -1
            x -= adjust_to_fps(6)
        }
    }
    if ((state == (2)))
    {
        heartRate = real((75 - (50 * (1 - min(max(0, ((distance_to_object(current_target) - 400) / 800)), 1)))))
        if ((heartRate >= heartTimer))
            heartTimer+= adjust_to_fps(1)
        else
        {
            heartTimer = 0
            mob_play_ds(se_heartbeat)
        }
        if target_is_near()
        {
            if (!((current_target.hiding && lostTarget)))
            {
                target_x = current_target.x
                lostTarget = 0
                mob_init_trace()
            }
            else
                state = (1)
        }
        else
            mob_track_trace()
        if (target_is_near() && (lostTarget || ((x < current_target.x) && (current_target.dir == -1)) || ((x >= current_target.x) && (current_target.dir == 1))))
        {
            alp = 1
            if ((stop == 0))
            {
                stop = 1
                if ((distance_to_object(current_target) > 500))
                    image_index = 0
                else
                    image_index = irandom_range(1, 3)
                lifespan-= adjust_to_fps(1)
            }
            if ((lifespan > 0))
            {
                if ((distance_to_object(current_target) < 700))
                    lifespan -= adjust_to_fps(0.5)
            }
            else
            {
                global.trans_alp = 1
                instance_destroy()
            }
        }
        else
        {
            image_index = 0
            alp = 0
            stop = 0
        }
    }
    else if ((state == (1)) || (state == (0)))
    {
        if ((!((current_target.hiding && lostTarget))) && target_is_near() && (distance_to_object(current_target) < 2000))
        {
            state = (2)
            lostTarget = 0
        }
        if ((lifespan > 0))
            lifespan-= adjust_to_fps(1)
        else
            instance_destroy()
    }
    if ((state == (2)) && place_meeting(x, y, current_target) && (!current_target.immortal) && distance_to_object(current_target) <= 200)
    {
        if (!lostTarget) && current_target.object_index == obj_pkun
        {
            play_se(se_catch, 1)
            global.hscene_target = self
            global.trans_alp = 1
        }
    }
}
else
    image_speed = 0
