var current_target = get_closest_target(x, y, id)
var _is_server = check_is_server()

/// @description Insert description here
// You can write your code in this editor
if ((!game_is_paused()) && (!global.timeStop) && (!police_stop()))
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
            //x += move
        }
        else
        {
			mob_set_dir(-1)
			mob_move(move * dir, 0)
            //dir = -1
            //x -= move
        }
    }
    if ((state == (2)))
    {
        if (!soundDelay)
        {
            soundDelay = 120
            mob_play_ds(se_shadow)
        }
        if (target_is_near() && current_target.flashOn && (lostTarget || ((x < current_target.x) && (current_target.dir == -1)) || ((x >= current_target.x) && (current_target.dir == 1))))
        {
            if ((lifespan > 0))
            {
                if ((distance_to_object(current_target) < 800))
                {
                    lifespan -= 1
                    if ((spd > spdMin))
                        spd -= adjust_to_fps(0.1)
                    if ((alp > 0.5))
                        alp -= adjust_to_fps(0.02)
                }
            }
            else
            {
                var dead = instance_create_depth(x, y, depth, obj_doppel_dead)
                dead.dir = dir
                instance_destroy()
            }
        }
        else
        {
            if ((lifespan < 300))
                lifespan += adjust_to_fps(0.1)
            if ((spd < spdMax))
                spd += adjust_to_fps(0.1)
            if ((alp < 1))
                alp += adjust_to_fps(0.02)
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
    else if ((state == (1)) || (state == (0))) && _is_server
    {
        if ((!((current_target.hiding && lostTarget))) && target_is_near() && (distance_to_object(current_target) < 2000))
        {
            mob_set_state(2)
            lostTarget = 0
        }
        if ((state == (1)))
        {
            set_sprite(spr_doppel_away, 0)
            if ((!soundDelay) && check_index(0))
            {
                soundDelay = 10
                mob_play_ds(48)
            }
            if ((abs((x - target_x)) < 20))
            {
                timer = irandom_range(150, 400)
                mob_set_state(0)
            }
        }
        else if ((state == (0)))
        {
            set_sprite(spr_doppel_away, 0)
            if ((timer > 0))
                timer-= adjust_to_fps(1)
            else
                mob_wander(1)
        }
    }
    if ((state == (2)) && place_meeting(x, y, current_target) && (!current_target.immortal))
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

event_inherited()