function can_client_mob_move() {
	if (controlled == -1) //(controlled == -1) || ((controlled == 0) && check_is_server()) // (-1 here means its owned by self, 0 means unowned, other numbers mean sock owner) if controlled, no, no matter what
		return 0
	else if (!is_multiplayer())
		return 1
	else if (check_is_server()) && (controlled == 0)
		return 1
	return 0
}

function mob_move(delta_x = 0, delta_y = 0, force_move = 0) {
	if (can_client_mob_move() || force_move) {
		x += adjust_to_fps(delta_x)
		last_move_speed = abs(delta_x)
		if (delta_y != 0)
			y += adjust_to_fps(delta_y)
		dx = (delta_x)
	} else {
		last_move_speed = 0
	}
}

function mob_set_state(new_state = 0, force = 0) {
	if (can_client_mob_move() || force) {
		state = new_state
	}
}

function mob_set_pos(new_x, new_y, new_dir = dir) {
	mob_set_x(new_x)
	mob_set_y(new_y)
	mob_set_dir(new_dir)
}

function mob_set_x(new_x) {
	if can_client_mob_move() {
		x = new_x
	}
}

function mob_set_y(new_y) {
	if can_client_mob_move() {
		y = new_y
	}
}

function mob_set_dir(new_dir, force = 0) {
	if (can_client_mob_move() || force)
		dir = new_dir
}

// Require the caller to pass in its current x and y
function get_closest_target(_x, _y, _id = noone) {
	// return the stuff within the timers
	//if (_id != noone) {
	//	if !struct_exists(global.targetting_cached, _id)
	//		struct_set(global.targetting_cached, (_id), [global.targetting_update_tmr_dur, target_nearest(_x, _y)])
	//	return (global.targetting_cached[$ _id][1] == 0) ? obj_pkun : global.targetting_cached[$ _id][1]
	//}
	//return target_nearest(_x, _y);
	return obj_pkun
}

function target_nearest(_x, _y) {
    var n = obj_pkun;
    if (instance_number(obj_mob_targettable) > 0) {
        var list = ds_priority_create();
        with (obj_mob_targettable) {
            // Compute distance from the given point (_x, _y) to this candidate's position (x, y)
            var d = point_distance(_x, _y, x, y);
            ds_priority_add(list, id, d);
        }
        n = ds_priority_delete_min(list);
        ds_priority_destroy(list);
    }
    return n;
}

function baldi_add_tracer() {
	show_debug_message("Added baldi tracer :)")
	with (obj_baldi) {
		mob_add_trace()	
	}
}

function toggle_pkun_noclip(state=-4) {
	if instance_exists(obj_pkun) && (state == -4)
		obj_pkun.noclip = !obj_pkun.noclip
	else
		obj_pkun.noclip = state
}

function y_to_floor(y) {
	return (560 + (720 * floor((y / 720))))
}

function police_stop() //gml_Script_police_stop
{
    return (instance_exists(obj_police) && ((obj_police.delay > 0) || obj_police.stop));
}

function time_is_stopped()
{
	return (instance_exists(obj_pkun) && global.timeStop > 0)	
}

function target_is_near_obj(arg0) //gml_Script_target_is_near_obj
{
	var closest = get_closest_target(arg0.x, arg0.y, arg0.id)
    return (!(collision_line(arg0.x, arg0.y, closest.x, closest.y, obj_wall, false, false)));
}

function target_is_near() //gml_Script_target_is_near
{
	var current_target = get_closest_target(x, y, id)
	
	var _speaking_exception = (global.speaking && (distance_to_object(current_target) < 650))
	if (_speaking_exception) {
		show_debug_message("target_is_near: Speaking Exception active. Pkun is forced to be near!")
		return 1
	} else {
		return (!(collision_line(x, y, current_target.x, current_target.y, obj_wall, false, false))) || (global.speaking && (distance_to_object(current_target) < 650))
	}
}

function hanako_hide() //gml_Script_hanako_hide
{
	var current_target = get_closest_target(x, y, id)
    var hd = -4
    var list = ds_list_create()
    var size = 0
    with (obj_intr_locker)
    {
        if ((!locked) && (((current_target.intrTarget != id) && (distance_to_object(current_target) < 4000) && (distance_to_object(current_target) > 700)) || (current_target.lp && (!(collision_line(x, y, current_target.lp.x, current_target.lp.y, obj_wall, false, true))))))
        {
            ds_list_add(list, id)
            size++
        }
    }
    with (obj_intr_rstrmdoor)
    {
        if ((!locked) && (((current_target.intrTarget != id) && (distance_to_object(current_target) < 4000) && (distance_to_object(current_target) > 700)) || (current_target.lp && (!(collision_line(x, y, current_target.lp.x, current_target.lp.y, obj_wall, false, true))))))
        {
            ds_list_add(list, id)
            size++
        }
    }
    if ((size > 0))
        hd = ds_list_find_value(list, irandom((size - 1)))
    if ((list != -1))
        ds_list_destroy(list)
    return hd;
}

function portal_nearest(inst = self) //gml_Script_portal_nearest
{
    var n = -4
    if ((instance_number(obj_intr_portal) > 0))
    {
        var list = ds_priority_create()
        with (obj_intr_portal)
        {
            if (!(collision_line(x, y, other.x, other.y, obj_wall, false, false)))
                ds_priority_add(list, id, distance_to_point(x, y))
        }
        n = ds_priority_delete_min(list)
        ds_priority_destroy(list)
    }
    return n;
}

function portal_linked(argument0) //gml_Script_portal_linked
{
    if ((argument0 != -4)) && ((argument != 0))
    {
		if instance_exists(obj_intr_portal)
		{
	        with (obj_intr_portal)
	        {
	            if ((id != argument0) && (port == argument0.port))
	                return id;
	        }
		}
	}
    return -4;
}

function pkun_get_nearestMob() //gml_Script_target_get_nearestMob
{
    var nearest = -4
    var temp = noone

    if ((instance_number(obj_p_mob) > 0))
    {
        var list = ds_priority_create()
        with (obj_p_mob) {
			ds_priority_add(list, id, distance_to_point(obj_pkun.x, obj_pkun.y))
		}
        do
        {
            temp = ds_priority_find_min(list)
            if collision_line(obj_pkun.x, obj_pkun.y, temp.x, temp.y, obj_wall, true, false)
            {
                temp = -4
                ds_priority_delete_min(list)
            }
            else
                nearest = temp
        } until ((nearest != -4) || (ds_priority_size(list) == 0));
        ds_priority_destroy(list)
    }
    return nearest;
}

function pkun_spawn_mob() //gml_Script_pkun_spawn_mob
{
    if ((instance_number(obj_p_mob) < mob_limit))
    {
        if ((mobSpawnCt > 0))
            mobSpawnCt-= adjust_to_fps(1)
        else
        {
            var mob = noone
            var msp = noone
            var list = ds_list_create()
            var loop = 0
			var _layer = (global.enable_nsfw) ? layer_get_id("Instances") : layer_get_id("Censor")
            while ((loop < 10))
            {
                if ((global.clock_hr >= 3) && (!instance_exists(obj_hanako_hide)))
                {
                    instance_create_depth(x, y, 0, obj_hanako_hide)
					//instance_create_layer(x, y, _layer, obj_hanako_hide)
                    break
                }
                else
                {
                    mob = mob_pool[irandom((array_length(mob_pool) - 1))]
                    if (!instance_exists(mob))
                    {
                        if ((mob == obj_wpangel))
                        {
                            with (obj_intr_portal)
                            {
                                if ((distance_to_object(obj_pkun) > 2000) && target_is_near())
                                    ds_list_add(list, id)
                            }
                            if ((ds_list_size(list) > 0))
                            {
                                msp = ds_list_find_value(list, irandom((ds_list_size(list) - 1)))
                                instance_create_depth(msp.x, (560 + (720 * floor((msp.y / 720)))), -2, obj_wpangel)
								//instance_create_layer(msp.x, (560 + (720 * floor((msp.y / 720)))), _layer, obj_wpangel)
                            }
                            break
                        }
                        else if ((mob == obj_ladypaint))
                        {
                            with (obj_lp_sp)
                            {
                                if ((distance_to_object(obj_pkun) > 2000) || (!target_is_near()))
                                    ds_list_add(list, id)
                            }
                            msp = ds_list_find_value(list, irandom((ds_list_size(list) - 1)))
                            instance_create_depth(msp.x, (560 + (720 * floor((msp.y / 720)))), -1, obj_ladypaint)
                            //instance_create_layer(msp.x, (560 + (720 * floor((msp.y / 720)))), _layer, obj_ladypaint)
                            break
                        }
                        else if ((mob == obj_hachi) || (mob == obj_kuchi) || (mob == obj_jianshi))
                        {
                            with (obj_intr_portal)
                            {
                                if ((distance_to_object(obj_pkun) > 2000) || (!target_is_near()))
                                    ds_list_add(list, id)
                            }
                            msp = ds_list_find_value(list, irandom((ds_list_size(list) - 1)))
                            instance_create_depth(msp.x, (560 + (720 * floor((msp.y / 720)))), -2, mob)
                            //instance_create_layer(msp.x, (560 + (720 * floor((msp.y / 720)))), _layer, mob)
                            break
                        }
                        else if ((mob == obj_doppel))
                        {
                            with (obj_intr_portal)
                            {
                                if ((distance_to_object(obj_pkun) > 2000) && target_is_near())
                                    ds_list_add(list, id)
                            }
                            if ((ds_list_size(list) > 0))
                            {
                                msp = ds_list_find_value(list, irandom((ds_list_size(list) - 1)))
                                instance_create_depth(msp.x, (560 + (720 * floor((msp.y / 720)))), 0, mob)
                                //instance_create_layer(msp.x, (560 + (720 * floor((msp.y / 720)))), _layer, mob)
                            }
                            break
                        }
                        else if ((mob == obj_mary) || (mob == obj_police))
                        {
                            instance_create_depth(0, 0, -4, mob)
                            //instance_create_layer(0, 0, _layer, mob)
                            break
                        }
                        else if ((mob == obj_pianist))
                        {
                            with (obj_intr_portal)
                            {
                                if ((y >= 2100) && (!target_is_near()))
                                    ds_list_add(list, id)
                            }
                            msp = ds_list_find_value(list, irandom((ds_list_size(list) - 1)))
                            var xx = irandom_range(-2000, 2000)
                            var yy = (560 + (720 * floor((msp.y / 720))))
                            while (!(((abs(xx) > 400) && (!(collision_line(msp.x, yy, (msp.x + xx), yy, obj_wall, false, true))))))
                                xx = irandom_range(-1500, 1500)
                            instance_create_depth((msp.x + xx), yy, -1, mob)
                            //instance_create_layer((msp.x + xx), yy, _layer, mob)
                            break
                        }
                        else
                            break
                    }
                    else
                        loop++
                }
            }
            ds_list_destroy(list)
            mobSpawnCt = ((irandom_range(400, 700) * (1 + (instance_number(obj_p_mob) * 0.2))) * (1 - ((0.6 * global.clock_tk) / 360)))
        }
    }
}

function mob_play_ds(argument0) //gml_Script_mob_play_ds
{
    audio_falloff_set_model(4)
    if target_is_near()
    {
        var se = audio_play_sound_at(argument0, (obj_pkun.x + (obj_pkun.x - x)), y, 0, 100, 3000, 1, false, 1)
        audio_sound_gain(se, (global.vol_se / 100), 0)
    }
    else
    {
        var np = obj_pkun.np
        var lp = obj_pkun.lp
        if ((np != noone) && (lp != noone) && (!(collision_line(x, y, lp.x, lp.y, obj_wall, false, true))))
        {
            se = audio_play_sound_at(argument0, (obj_pkun.x + (1.5 * ((obj_pkun.x - np.x) + (lp.x - x)))), ((obj_pkun.y - 1600) - (2 * abs((lp.x - x)))), 300, 100, 6000, 1.5, false, 1)
            audio_sound_gain(se, (global.vol_se / 100), 0)
        }
    }
}

function mob_init_trace() //gml_Script_// mob_init_trace
{
	if struct_exists(global.targetting_cached, id)
		exit;
	
	trace_i = -1
	trace_p = -1
	trace_x = []
	trace_y = []
	for (var i = 0; i < global.mob_trace_count; i++)
	{
	    trace_x[i] = -1
	    trace_y[i] = -1
	}

}

function mob_track_trace() //gml_Script_mob_track_trace
{
    if ((trace_i > -1) && (trace_i < global.mob_trace_count) && (trace_x[trace_i] != 0) && (trace_x[trace_i] != -1))
    {
        if ((abs((x - trace_x[trace_i])) < 50) && (abs((y - trace_y[trace_i])) < 100))
            mob_use_portal()
        else
            target_x = trace_x[trace_i]
    }
    else
    {
        show_debug_message("mob lost trace! \n- trace_i = " + string(trace_i))
        mob_set_state(1)
        lostTarget = 1
        mob_wander(0)
//        // mob_init_trace()
    }
}

function mob_add_trace() //gml_Script_mob_add_trace
{
	var current_target = get_closest_target(x, y, id)
    if ((state == (2)) && (!lostTarget))// && (global.mob_trace_count > 0)
    {
        var i = 0
        while ((i < global.mob_trace_count))
        {
            if ((trace_x[i] == 0))
                break
            else if ((trace_x[i] == -1))
            {
                if chance((100 - (global.mob_trace_forget_chance * i)))
                {
                    trace_x[i] = current_target.x
                    trace_y[i] = current_target.y
                }
                else
                    trace_x[i] = 0
                if ((i == 0))
                    trace_i++
                break
            }
            else
                i++
        }
    }
}

function point_near_portal(_x, _y, dist) {
	with (obj_intr_portal) {
		if (abs(_x - x) <= dist) && (abs(_y - y) <= dist) {
			return id
		}
	}
	return false
}

function mob_use_portal() //gml_Script_mob_use_portal
{
	var current_target = get_closest_target(x, y, id)
    var in = instance_nearest(x, y, obj_intr_portal)
    var lp = current_target.lp
    trace_p = in.port
    with (obj_intr_portal)
    {
        if ((other.trace_p == port))
        {
            if ((id == in))
            {
				if !current_target.noclip
				{
					if (target_is_near() || (!(collision_line(x, y, lp.x, lp.y, obj_wall, false, true))))
						mob_play_ds(se)
				}
			}
            else
            {
				if !current_target.noclip
				{
					if (target_is_near() || (!(collision_line(x, y, lp.x, lp.y, obj_wall, false, true))))
						mob_play_ds(se)
				}
                other.x = x
                other.y = (560 + (720 * floor((y / 720))))
                other.trace_p = -1
                other.trace_i++
                other.dir = ((current_target.x > other.x) ? 1 : -1)
                show_debug_message("[" + object_get_name(object_index) + "]:" + " mob teleported!")
                for (var i = 0; i < global.mob_trace_count; i++)
                    show_debug_message(((((((("trace_x[" + string(i)) + "]=") + string(other.trace_x[i])) + ", trace_y[") + string(i)) + "]=") + string(other.trace_y[i])))
            }
        }
    }
}

function mob_find_portal() //gml_Script_mob_find_portal
{
    var list = ds_list_create()
    var portal = noone
    var result = 0
    with (obj_intr_portal)
    {
        if ((!(collision_line(x, y, other.x, other.y, obj_wall, false, false))) && (distance_to_object(other) < 6000))
            ds_list_add(list, id)
    }
    if (!ds_list_empty(list))
    {
        portal = ds_list_find_value(list, irandom_range(0, (ds_list_size(list) - 1)))
        show_debug_message((((((("[" + object_get_name(object_index) + "]: " + "gonna use portal " + string(portal)) + "(") + string(portal.x)) + ", ") + string(portal.y)) + ")"))
        trace_i = 0
		if (global.mob_trace_count > 0)
		{
			trace_x[0] = portal.x
			trace_y[0] = portal.y
		}
        result = 1
    }
    ds_list_destroy(list)
    return result;
}

function mob_wander(argument0) //gml_Script_mob_wander
{
	if (is_multiplayer()) && (!check_is_server())
		exit;
	
    var d = 0
    var len = 0
    var lp = 0
    if (argument0 && chance(40))
    {
        if mob_find_portal()
            mob_set_state(2)
    }
    else
    {
        do
        {
            d = choose(-1, 1)
            len = irandom_range(300, 4000)
            lp++
        } until ((lp >= 5000) || (!(collision_line(x, y, (x + (d * len)), y, obj_wall, false, true))));
        if ((lp >= 5000))
            instance_destroy()
        show_debug_message(((((((((((("d=" + string(d)) + " len=") + string(len)) + " state=") + string(state)) + " lostTarget=") + string(lostTarget)) + " i=") + string(trace_i)) + " usePortal=") + string(argument0)))
        target_x = (x + (d * len))
        mob_set_state(1)
    }
}

