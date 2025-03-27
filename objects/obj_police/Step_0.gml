/// @description Insert description here
// You can write your code in this editor
if ((!game_is_paused()) && (!obj_pkun.timeStop))
{
    dir = (-obj_pkun.dir)
    if ((distance_to_object(obj_pkun) > 1000))
        x = ((obj_pkun.dir * 400) + obj_pkun.x)
    else
        x -= adjust_to_fps((x - ((obj_pkun.dir * 400) + obj_pkun.x)) / 10)
    y = obj_pkun.y
    if ((stopTimer > 0))
    {
        stopTimer-= adjust_to_fps(1)
        if stop
            set_sprite(spr_police_stop, 0.5)
        else
            set_sprite(spr_police_go, 0.5)
    }
    else if stop
    {
        stopTimer = irandom_range(180, 270)
        delay = 30
        stop = 0
        stopAt = -1
        if ((lifespan > 1))
            lifespan--
        else
        {
            global.trans_col = 16777215
            global.trans_alp = 1
            instance_destroy()
        }
        play_se(se_whistle_gostop, 1)
    }
    else
    {
        stopTimer = irandom_range(90, 210)
        stop = 1
        delay = 45
        play_se(se_whistle_gostop, 1)
    }
    if stop
    {
        if ((delay > 0))
            delay-= adjust_to_fps(1)
        else if ((stopAt == -1))
            stopAt = obj_pkun.x
        else if ((stopAt != obj_pkun.x))
        {
            play_se(se_catch, 1)
            play_se(se_whistle_caught, 1)
            global.hscene_target = self; if check_is_server() _cb_sync_hscene();
            global.trans_alp = 1
        }
    }
    else if ((delay > 0))
        delay-= adjust_to_fps(1)
}
else
    image_speed = 0
