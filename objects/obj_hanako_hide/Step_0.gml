//// var current_target = get_closest_target(x, y, id)

/// @description Insert description here
// You can write your code in this editor
current_target = closest_target_thru_walls()

if ((!game_is_paused()) && (!global.timeStop) && (!police_stop()))
{
    pit = current_target.intrTarget
    if current_target.hiding
    {
        if ((prev != current_target.intrTarget))
        {
            prev = current_target.intrTarget
            hide_ban = 3600
        }
        if ((hide_ban > 0))
            hide_ban-= adjust_to_fps(1)
    }
    if (hide_spot && target_is_near())
    {
        if ((distance_to_object(current_target) <= 200))
        {
            if ((current_target.x < hide_spot.x))
                ani_index = 2
            else
                ani_index = 3
        }
        else if ((ani_timer > 0))
            ani_timer-= adjust_to_fps(1)
        else
        {
            ani_timer = irandom_range(30, 90)
            ani_index = choose(0, 0, 0, 1, 2, 3)
        }
    }
    else if ((hide_timer > 0))
        hide_timer-= adjust_to_fps(1)
    else
    {
        hide_timer = irandom_range(300, 600)
        hide_spot = hanako_hide()
        if hide_spot
        {
            x = hide_spot.x
            y = hide_spot.y
        }
        else
        {
            x = current_target.x
            y = current_target.y
        }
    }
    if ((hide_ban <= 0) || (current_target.hiding && (pit == hide_spot))) && !current_target.immortal && current_target.object_index == obj_pkun
    {
        play_se(se_catch, 1)
        global.hscene_target = self; if check_is_server() sync_hscene_event();
        global.hscene_hide_fl = 1
        global.trans_alp = 1
    }
}
else
    image_speed = 0

event_inherited()