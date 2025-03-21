var current_target = get_closest_target(x, y, id)

/// @description Insert description here
// You can write your code in this editor
if ((!game_is_paused()) && (!obj_pkun.timeStop) && (!police_stop()))
{
    if ((soundDelay > 0))
        soundDelay-= adjust_to_fps(1)
    if sealed
    {
        if ((sprite_index != spr_jianshi_down_seal))
        {
            image_speed = 1
            if ((image_index >= 5))
            {
                x += adjust_to_fps(13 * dir)
                sprite_index = spr_jianshi_jump_seal
            }
            else
                sprite_index = spr_jianshi_down_seal
        }
        else if ((image_index >= 5))
            image_speed = 0
        else
            image_speed = 1
    }
    else
    {
        if ((image_index >= 5))
            x += adjust_to_fps(13 * dir)
        else if ((x < target_x))
            dir = 1
        else
            dir = -1
        if ((state == (2)))
        {
            image_speed = 1
            if ((!soundDelay) && check_index(0))
            {
                soundDelay = 10
                mob_play_ds(se_footslap)
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
            if ((!((current_target.hiding && lostTarget))) && target_is_near() && (distance_to_object(current_target) < 3000))
            {
                state = (2)
                lostTarget = 0
            }
            if ((state == (1)))
            {
                image_speed = 1
                if ((!soundDelay) && check_index(0))
                {
                    soundDelay = 10
                    mob_play_ds(se_footslap)
                }
                if ((abs((x - target_x)) < 20))
                {
                    if target_is_near()
                    {
                        timer = 90
                        mob_play_ds(se_sniff)
                    }
                    else
                        timer = irandom_range(150, 400)
                    state = (0)
                }
            }
            else if ((state == (0)))
            {
                if ((image_index >= 2) && (image_index < 4))
                {
                    image_index = 3
                    image_speed = 0
                }
                else
                    image_speed = 1
                if ((timer > 0))
                    timer-= adjust_to_fps(1)
                else if target_is_near()
                    lostTarget = 0
                else
                    mob_wander(1)
            }
        }
        if ((!sealed) && (state == (2)) && place_meeting(x, y, current_target) && (!current_target.immortal))
        {
            if (!lostTarget) && current_target.object_index == obj_pkun
            {
                play_se(se_catch, 1)
                global.hscene_target = self
                global.trans_alp = 1
                global.hscene_hide_fl = 1
            }
        }
    }
}
else
    image_speed = 0
