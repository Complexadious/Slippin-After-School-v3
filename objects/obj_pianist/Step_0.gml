var current_target = get_closest_target(x, y, id)

/// @description Insert description here
// You can write your code in this editor
if ((!game_is_paused()) && (!obj_pkun.timeStop) && (!police_stop()))
{
    if playing
    {
        if instance_exists(piano)
        {
            set_sprite(spr_pianist_play, (timer > 60))
            if ((p_elise != -4))
            {
                audio_resume_sound(p_elise)
                if target_is_near()
                {
                    dist = 0
                    audio_emitter_position(p_emitter, obj_pkun.x, obj_pkun.y, 0)
                }
                else if ((lp != noone) && (!(collision_line(obj_pkun.x, obj_pkun.y, lp.x, lp.y, obj_wall, false, true))))
                {
                    dist = ((abs((x - np.x)) + abs((obj_pkun.x - lp.x))) + 4000)
                    audio_emitter_position(p_emitter, (obj_pkun.x + (obj_pkun.x - lp.x)), obj_pkun.y, 0)
                }
                else
                {
                    dist = (7000 * abs((((floor((y / 720)) % 3) + 1) - ((floor((obj_pkun.y / 720)) % 3) + 1))))
                    audio_emitter_position(p_emitter, obj_pkun.x, obj_pkun.y, 0)
                }
                audio_sound_gain(p_elise, (max(0.1, ((distMax - dist) / distMax)) * (global.vol_bgm / 100)), 0)
            }
            else
                p_elise = audio_play_sound_on(p_emitter, bgm_furelise, false, 0)
            if ((timer > 0))
                timer-= adjust_to_fps(1)
            else if !obj_pkun.immortal
            {
                play_se(se_charmed, 1)
                global.hscene_target = self
                global.trans_alp = 1
            }
        }
        else
        {
            playing = 0
            timer = 150
            set_sprite(spr_pianist_stop, 1)
            audio_stop_sound(p_elise)
        }
    }
    else if ((timer > 0))
        timer-= adjust_to_fps(1)
    else
    {
        global.trans_alp = 1
        instance_destroy()
    }
}
else
{
    image_speed = 0
    if ((p_elise != -4) && audio_is_playing(p_elise))
        audio_pause_sound(p_elise)
}
