var current_target = get_closest_target(x, y, id)

/// @description Insert description here
// You can write your code in this editor
//if ((!game_is_paused()) && (!obj_pkun.timeStop) && (!police_stop()))
if ((!game_is_paused()) && (!obj_pkun.timeStop) && (!police_stop())) || actor
{
    if ((soundDelay > 0))
        soundDelay-= adjust_to_fps(1)
    if ((state != (0)))
    {
        mob_set_dir((x < target_x) ? 1 : -1)
        //x += (adjust_to_fps(move) * dir)
		mob_move(move * dir, 0)
        if ((warpDelay > 0))
        {
            if ((alp < 1))
                alp += adjust_to_fps(0.05)
            warpDelay-= adjust_to_fps(1)
        }
        else if ((alp > 0))
            alp -= adjust_to_fps(0.05)
        else if ((abs((target_x - x)) >= 350))
        {
            warpDelay = 300
            //x += (adjust_to_fps(350) * dir)
			mob_move(350 * dir, 0)
            mob_play_ds(se_warp)
        }
    }
    else
    {
        if ((alp < 1))
            alp += adjust_to_fps(0.05)
        warpDelay = 300
    }
    if ((state == (2)))
    {
        set_sprite(spr_hachi_walk, 0.5)
        if ((!soundDelay) && (check_index(0) || check_index(3)))
        {
            soundDelay = 10
            mob_play_ds(choose(se_step_b_1, se_step_b_2, se_step_b_3))
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
        if ((!((current_target.hiding && lostTarget))) && target_is_near() && (distance_to_object(current_target) < 2000))
        {
            mob_set_state(2)
            lostTarget = 0
        }
        if ((state == (1)))
        {
            set_sprite(spr_hachi_walk, 0.5)
            if ((!soundDelay) && (check_index(0) || check_index(3)))
            {
                soundDelay = 10
                mob_play_ds(choose(se_step_b_1, se_step_b_2, se_step_b_3))
            }
            if ((abs((x - target_x)) < 20))
            {
                timer = irandom_range(150, 400)
                mob_set_state(0)
            }
        }
        else if ((state == (0)))// && check_is_server()
        {
            set_sprite(spr_hachi_idle, (1/3))
            if ((timer > 0))
                timer-= adjust_to_fps(1)
            else
                mob_wander(1)
        }
    }
    if (target_is_near() && (abs((current_target.x - x)) <= 800)) && !actor
    {
        if ((global.charmed < 100))
            global.charmed += adjust_to_fps(0.35 * max(0, ((800 - abs((current_target.x - x))) / 800)))
        else
            global.charmed = 100
        if (((state == (2)) && place_meeting(x, y, current_target) && (!current_target.immortal) && (!lostTarget)) || (global.charmed >= 100)) && current_target.object_index == obj_pkun
        {
            play_se(se_charmed, 1)
            global.hscene_target = self; if check_is_server() sync_hscene_event();
            global.trans_alp = 1
            global.hscene_hide_fl = 1
        }
    }
}
else
    image_speed = 0

event_inherited()