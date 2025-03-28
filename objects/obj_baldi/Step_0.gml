var current_target = get_closest_target(x, y, id)
var _is_server = check_is_server()

/// @description Insert description here
// You can write your code in this editor
if ((!game_is_paused()) && (!obj_pkun.timeStop) && (!police_stop()))
{
    if ((soundDelay > 0))
        soundDelay-= adjust_to_fps(1)
    if frozen
    {
        if ((sprite_index != spr_baldi_idle))
        {
            image_speed = 1
            if ((image_index >= 3))
            {
                x += adjust_to_fps(13 * dir)
                sprite_index = spr_baldi_idle
            }
            else
                sprite_index = spr_baldi_idle
        }
        else if ((image_index >= 5))
            image_speed = 0
        else
            image_speed = 1
    }
    else
    {
        if ((image_index >= 3))
            x += adjust_to_fps(13 * dir)
        else if ((x < target_x))
            dir = 1
        else
            dir = -1
        if ((state == (2)))
        {
            image_speed = 1
            if ((!soundDelay) && check_index(3))
            {
                soundDelay = 10
                mob_play_ds(se_ruler_slap)
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
            if ((!((current_target.hiding && lostTarget))) && target_is_near() && (distance_to_object(current_target) < 3000)) && _is_server
            {
                mob_set_state(2)
                lostTarget = 0
            }
            if ((state == (1))) && _is_server
            {
                image_speed = 1
                if ((!soundDelay) && check_index(3))
                {
                    soundDelay = 10
                    mob_play_ds(se_ruler_slap)
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
                    mob_set_state(0)
                }
            }
            else if ((state == (0))) && _is_server
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
        if ((!frozen) && (state == (2)) && place_meeting(x, y, current_target) && (!current_target.immortal))
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
}
else
    image_speed = 0

event_inherited()