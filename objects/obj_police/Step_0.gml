parent_obj = pid_to_inst(parent_pid)

// get lowest player pid and go to them
if ((parent_obj == -4) || !instance_exists(parent_obj)) {
	log("Parent OBJ is invalid, getting new one (lowest PID to instance)")
	var _apply_real = function(_element, _index) {_element = real(_element)}
	var _players = struct_get_names(obj_multiplayer.network.players)
	array_foreach(_players, _apply_real)
	parent_pid = script_execute_ext(min, _players)
	parent_obj = pid_to_inst(parent_pid)
	log("New parent_pid is '" + string(parent_pid) + "', parent_obj is " + string(parent_obj))
}

/// @description Insert description here
// You can write your code in this editor
if ((!game_is_paused()) && (!global.timeStop))
{
    dir = (-parent_obj.dir)
    if ((distance_to_object(parent_obj) > 1000))
        x = ((parent_obj.dir * 400) + parent_obj.x)
    else
        x -= adjust_to_fps((x - ((parent_obj.dir * 400) + parent_obj.x)) / 10)
    y = parent_obj.y
    if ((stopTimer > 0))
    {
        stopTimer-= adjust_to_fps(1)
        if stop
            set_sprite(spr_police_stop, 0.5)
        else
            set_sprite(spr_police_go, 0.5)
    }
    else if (stop) && is_our_pid(parent_pid)
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
        play_se_at(se_whistle_gostop, x, y, 1)
		entity_event_sync(EVENT_ID.POLICE_SWITCH, obj_police, [stopTimer, delay])
    }
    else if is_our_pid(parent_pid)
    {
        stopTimer = irandom_range(90, 210)
        stop = 1
        delay = 45
        play_se_at(se_whistle_gostop, x, y, 1)
		entity_event_sync(EVENT_ID.POLICE_SWITCH, obj_police, [stopTimer, delay])
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
            play_se_at(se_whistle_caught, x, y, 1)
            play_se_event(se_whistle_caught, x, y)
            global.hscene_target = self; sync_hscene_event(se_catch);
            global.trans_alp = 1
        }
    } 
    else if ((delay > 0))
        delay-= adjust_to_fps(1)
}
else
    image_speed = 0
