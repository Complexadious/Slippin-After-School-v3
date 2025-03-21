function spawn_init() //gml_Script_spawn_init
{
	//audio_stop_all()
	//play_bgm(bgm_rain_inside)
	//show_debug_message("Spawninit Ran!!")
	//show_debug_message("Current room: " + room_get_name(room));
	//show_debug_message("Checking spawners in room: " + room_get_name(rm_game));
    var hr = (global.clock_hr + (global.clock_min == 59))
    show_debug_message(((("Current Time = " + string(global.clock_hr)) + ":") + string(global.clock_min)))
    if ((hr == -1))
    {
        global.transition = 2
		global.trans_alp = 1
        dialog_add_line_ext("", getText("intro_1"), spr_intro_3, gus_creaming, true, 5)
        dialog_add_line_ext("", getText("intro_2"), spr_intro_4, dialog_intro_2, true, 5)
        dialog_add_line(getText("friendA"), getText("intro_3"), dialog_intro_3, true, 5)
        dialog_add_line(getText("shotakun"), getText("intro_4"),dialog_intro_4, true, 5)
        dialog_add_line(getText("friendA"), getText("intro_5"), dialog_intro_5, true, 5)
        dialog_add_line(getText("shotakun"), getText("intro_6"), dialog_intro_6, true, 5)
        dialog_add_line(getText("friendA"), getText("intro_7"), dialog_intro_7, true, 5)
        dialog_add_line_ext("", getText("intro_8"), spr_intro_5, dialog_intro_8, true, 5)
        global.dialog_mode = 1
    }
    else if ((hr >= 6))
        instance_create_depth(x, y, 0, obj_ending_handler)
    if ((hr == -1) || (hr == 1))
    {
        mob_pool = [obj_kuchi, obj_wpangel, obj_ladypaint]
        mob_limit = 3
        item_limit = 20
        milk_limit = 5
    }
    else if ((hr == 2))
    {
        mob_pool = [obj_kuchi, obj_wpangel, obj_ladypaint, obj_police, obj_doppel, obj_hachi]
        mob_limit = 4
        item_limit = 25
        milk_limit = 4
    }
    else if ((hr == 3))
    {
        mob_pool = [obj_wpangel, obj_ladypaint, obj_police, obj_doppel, obj_jianshi, obj_mary, obj_hanako_hide]
        mob_limit = 4
        item_limit = 30
        milk_limit = 4
    }
    else if ((hr == 4))
    {
        mob_pool = [obj_doppel, obj_jianshi, obj_pianist, obj_mary, obj_hachi, obj_hanako_hide]
        mob_limit = 5
        item_limit = 35
        milk_limit = 3
    }
    else
    {
        mob_pool = [obj_kuchi, obj_ladypaint, obj_wpangel, obj_police, obj_doppel, obj_pianist, obj_jianshi, obj_hachi, obj_mary, obj_hanako_hide]
        mob_limit = 6
        item_limit = 40
        milk_limit = 3
    }
	
    if ((hr >= 3))
        item_pool = [1, 1, 1, 2, 2, 2, 4, 5, 6]
    else
        item_pool = [1, 1, 1, 2, 2, 2, 4, 5, 5]
    var spawned_numb = 0
    var spawned_milk = 0
    var spawned_memo = 0
    var spawning = 0
    
    var spawner_list = ds_list_create();
    // Get all spawners into a list
    with(obj_item_spawner) {
        ds_list_add(spawner_list, id);
    }
    
    var total_spawners = ds_list_size(spawner_list);
    //show_debug_message("Total spawners found: " + string(total_spawners));
    
    while (spawned_numb <= min(item_limit, total_spawners) && ds_list_size(spawner_list) > 0)
    {
        //show_debug_message("SPAWNING!!")
        randomise()
        
        // Get random spawner from list
        var spawner_index = irandom(ds_list_size(spawner_list) - 1);
        var spawner = ds_list_find_value(spawner_list, spawner_index);
        
        spawning = 0
        if (spawned_memo < 3)
        {
            spawned_memo++
            spawning = -1
        }
        else if (spawned_milk < milk_limit)
        {
            spawned_milk++
            spawning = 3
        }
        else
        {
            spawning = (chance(60) ? item_pool[irandom(8)] : 0)
            spawned_numb++
        }
        
        //show_debug_message("Using spawner at position: " + string(spawner.x) + "," + string(spawner.y));
        item_spawn_at(spawner, spawning)
        
        // Remove used spawner from list
        ds_list_delete(spawner_list, spawner_index);
    }
    
    ds_list_destroy(spawner_list);
    
    // Clean up any remaining spawners
    with (obj_item_spawner) {
        //show_debug_message("Destroying unused spawner at: " + string(x) + "," + string(y));
        instance_destroy();
    }
}

function memo_get_random() //gml_Script_memo_get_random
{
    var mmid = memo_get_need()
    if ((mmid == -1))
    {
        miniMsgTmr = 300
        miniMsgStr = getText("msg_fn")
    }
    else
    {
        play_se(se_paper, 1)
        global.memoRead[mmid] = 1
        global.dialog_mode = 1
        sys_save_player()
        dialog_add_line_ext("", getText(("memo_" + string((mmid + 1)))), choose(153, 7, 111, 110))
    }
}

function memo_get_need() //gml_Script_memo_get_need
{
    var need = -1
    var temp = 0
    var i = 0
    while ((i < array_length(mob_pool)))
    {
        temp = memo_get_index(mob_pool[i])
        if ((temp > 0) && (!(global.memoRead[(temp - 1)])))
        {
            need = (temp - 1)
            break
        }
        else
            i++
    }
    return need;
}

function memo_get_index(argument0)
{
    switch argument0
    {
        case obj_wpangel:
            return 1;
        case obj_ladypaint:
            return 2;
        case obj_kuchi:
            return 3;
        case obj_hachi:
            return 4;
        case obj_mary:
            return 5;
        case obj_police:
            return 6;
        case obj_jianshi:
            return 7;
        case obj_doppel:
            return 8;
        case obj_pianist:
            return 9;
        case obj_hanako_hide:
            return 10;
        default:
            return 0;
    }
}

