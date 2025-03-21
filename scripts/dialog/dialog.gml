function game_is_paused() //gml_Script_game_is_paused
{
    return (global.menu_mode || global.dialog_mode || (global.hscene_target != -4) || global.setting_mode || global.transition || global.game_is_over);
}

function game_ring_bell(argument0) //gml_Script_game_ring_bell
{
    play_se(se_bell_chime, 1)
    global.bell_count = argument0
    global.bell_timer = 1380
}

function create_custom_actor(name, options) {
    if(!variable_global_exists("custom_actors"))
        global.custom_actors = ds_map_create();
        
    ds_map_set(global.custom_actors, name, {
        idle_sprite: options[$ "idle_sprite"] ?? -1,
        walk_sprite: options[$ "walk_sprite"] ?? -1,
        image_speed: options[$ "image_speed"] ?? 0.33,
        walk_sound: options[$ "walk_sound"] ?? -4,
        sound_index: options[$ "sound_index"] ?? [0],
        sound_delay: options[$ "sound_delay"] ?? 10,
        make_pkun_hide: options[$ "make_pkun_hide"] ?? 0,
        make_pkun_exit: options[$ "make_pkun_exit"] ?? 0,  // New property
        hide_se_in: options[$ "hide_se_in"] ?? -4,
        hide_se_out: options[$ "hide_se_out"] ?? -4,
        shake_amount_in: options[$ "shake_amount_in"] ?? 20,
        shake_amount_out: options[$ "shake_amount_out"] ?? 20,
        destroy_on_exit: options[$ "destroy_on_exit"] ?? true,
        x_scale: options[$ "x_scale"] ?? 1,
        y_scale: options[$ "y_scale"] ?? 1,
        depth: options[$ "depth"] ?? 0
    });
}

function Act(role, spd, tx, ty, custom_name = undefined) constructor {
    _num = global.dialog_num_total;
    _role = role;
    _spd = spd;
    _tx = tx;
    _ty = ty;
    
    if (custom_name != undefined && _role == "custom") {
        _custom_name = custom_name;
        var custom_data = ds_map_find_value(global.custom_actors, custom_name);
        if (custom_data != undefined) {
            // Basic properties
            _idle_sprite = custom_data.idle_sprite;
            _walk_sprite = custom_data.walk_sprite;
            _image_speed = custom_data.image_speed;
            _walk_sound = custom_data.walk_sound;
            _sound_index = custom_data.sound_index;
            _sound_delay = custom_data.sound_delay;
            _x_scale = custom_data.x_scale;
            _y_scale = custom_data.y_scale;
            _depth = custom_data.depth;
            
            // Hide properties
            _make_pkun_hide = custom_data.make_pkun_hide;
            _hide_se_in = custom_data.hide_se_in;
            _hide_se_out = custom_data.hide_se_out;
            _shake_amount_in = custom_data.shake_amount_in;
            _shake_amount_out = custom_data.shake_amount_out;
            _destroy_on_exit = custom_data.destroy_on_exit;
            _make_pkun_exit = custom_data.make_pkun_exit;
        }
    }
}

function dialog_play_act() {
	if global.dialog_disable_acts
		return;
    var act = noone;
    var actor = noone;
    
    while(true) {
        if (ds_list_size(d_acting) > 0 && ds_list_find_value(d_acting, 0)._num == curr) {
            act = ds_list_find_value(d_acting, 0);
            
            if (act._spd == -4) {
                actor = instance_create_depth(act._tx, act._ty, act._role == "custom" ? act._depth : 0, obj_actor);
                actor.role = act._role;
                if (actor.role == "custom") {
                    actor.custom_name = act._custom_name;
                    actor.idle_sprite = act._idle_sprite;
                    actor.walk_sprite = act._walk_sprite;
                    actor.image_speed = act._image_speed;
                    actor.walk_sound = act._walk_sound;
                    actor.sound_index = act._sound_index;
                    actor.sound_delay = act._sound_delay;
                    actor.make_pkun_hide = act._make_pkun_hide;
                    actor.hide_se_in = act._hide_se_in;
                    actor.hide_se_out = act._hide_se_out;
                    actor.shake_amount_in = act._shake_amount_in;
                    actor.shake_amount_out = act._shake_amount_out;
                    actor.destroy_on_exit = act._destroy_on_exit;
                    actor.x_scale = act._x_scale;
                    actor.y_scale = act._y_scale;
                    
                    var se_in = actor.hide_se_in;
                    var se_out = actor.hide_se_out;
                    var shake_in = actor.shake_amount_in;
                    var shake_out = actor.shake_amount_out;
                    
                    if (actor.make_pkun_hide) {
                        with(obj_pkun) {
                            hiding = 1;
                            x = actor.x;
                            if (se_in != -4) {
                                play_se(se_in, 1);
                            }
                            with(intrTarget) {
                                if (id != -4)
                                    shake = shake_in;
                            }
                        }
                    }
                    else if (actor.make_pkun_exit) {
                        with(obj_pkun) {
                            hiding = 0;
                            if (se_out != -4) {
                                play_se(se_out, 1);
                            }
                            with(intrTarget) {
                                if (id != -4)
                                    shake = shake_out;
                            }
                        }
                        if (actor.destroy_on_exit) {
                            instance_destroy(actor);
                        }
                    }
                }
                if (actor.role == "hanako")
                    global.trans_alp = 1;
            }
            else {
                actor = dialog_find_actor(act._role == "custom" ? act._custom_name : act._role);
                if (actor) {
                    if (act._spd < 0) {
                        // Store references before with block
                        var se_out = actor.hide_se_out;
                        var should_destroy = actor.destroy_on_exit;
                        
                        // Handle unhiding pkun if this was a hiding spot
                        if (actor.make_pkun_hide) {
                            with(obj_pkun) {
                                hiding = 0;
                                if (se_out != -4) {
                                    play_se(se_out, 1);
                                }
                            }
                        }
                        if (should_destroy) {
                            with(actor)
                                instance_destroy();
                        }
                    }
                    else {
                        actor.spd = act._spd;
                        // Handle movement direction based on target position
                        if (act._tx < actor.x) {
                            actor.dir = -1;
                            actor.len = actor.x - act._tx;
                        } else {
                            actor.dir = 1;
                            actor.len = act._tx - actor.x; 
                        }
                    }
                }
            }
            
            global.dialog_acting = 1;
            ds_list_delete(d_acting, 0);
            act = noone;
            continue;
        }
        else
            break;
    }
}

function actor_use_portal(argument0) //gml_Script_actor_use_portal
{
    var p = instance_nearest(x, y, obj_intr_portal)
    var result = 0
    if (p && (abs((x - p.x)) < 50) && (distance_to_object(p) < 50))
    {
        with (obj_intr_portal)
        {
            if ((p.port == port))
            {
                if ((!argument0) && target_is_near())
                    mob_play_ds(se)
                if ((!result) && (distance_to_object(other) > 200))
                {
                    result = 1
                    other.x = x
                    other.y = (560 + (720 * floor((y / 720))))
                    if argument0
                    {
                        play_se(se, 1)
                        global.trans_alp = 1
                        obj_pkun.x = other.x
                        obj_pkun.y = other.y
                        obj_camera.x = other.x
                        obj_camera.x = other.y
                    }
                }
            }
        }
    }
    return result;
}

function dialog_find_actor(identifier) {
    if (instance_number(obj_actor)) {
        with(obj_actor) {
            if ((role == identifier) || (role == "custom" && custom_name == identifier)) {
                show_debug_message(string(id));
                return id;
            }
        }
    }
    return -4;
}

function dialog_add_act(argument0) //gml_Script_dialog_add_act
{
    if (!instance_exists(obj_dialog))
        instance_create_depth(0, 0, 0, obj_dialog);
    ds_list_add(obj_dialog.d_acting, argument0)
}

function dialog_hscene(argument0, argument1) //gml_Script_dialog_hscene
{
    obj_dialog.d_hs_id[global.dialog_num_total] = argument0
    obj_dialog.d_hs_next[global.dialog_num_total] = argument1
}

function dialog_give_choice(argument0, argument1, argument2, argument3) //gml_Script_dialog_give_choice
{
    dialog_add_line(argument0, argument1)
    obj_dialog.d_choice_opt1 = argument2
    obj_dialog.d_choice_opt2 = argument3
    obj_dialog.d_choice_at = global.dialog_num_total
}

function dialog_add_line(argument0, argument1, argument2 = -4, argument3 = 0, argument4 = 0) //gml_Script_dialog_add_line
{
    dialog_add_line_ext(argument0, argument1, -4, argument2, argument3, argument4)
}

function dialog_add_line_ext(d_name, d_line, d_spr, d_se = -4, d_match_reveal_to_se = 0, d_se_start_delay = 0)
{
    if (!instance_exists(obj_dialog))
        instance_create_depth(0, 0, 0, obj_dialog);
    
    global.dialog_num_total++;
    obj_dialog.d_name[global.dialog_num_total] = d_name;
    obj_dialog.d_line[global.dialog_num_total] = d_line;
    obj_dialog.d_spr[global.dialog_num_total] = d_spr;
    obj_dialog.d_view[global.dialog_num_total] = -1;
    obj_dialog.d_hs_id[global.dialog_num_total] = 0;
    obj_dialog.d_hs_next[global.dialog_num_total] = 0;
    obj_dialog.d_trans[global.dialog_num_total] = -1;
    obj_dialog.d_se[global.dialog_num_total] = d_se;
    obj_dialog.d_se_start_delay[global.dialog_num_total] = d_se_start_delay;
    
    if ((d_se != -4) && d_match_reveal_to_se)
    {
        var sound_len = audio_sound_length(d_se) * game_get_speed(gamespeed_fps);
        var char_count = string_length(d_line);
        obj_dialog.d_reveal_time[global.dialog_num_total] = char_count / sound_len;
    }
	else
		obj_dialog.d_reveal_time[global.dialog_num_total] = 0.5
//	obj_dialog.bg_c = argument3
//	show_debug_message("IM JERKING OFF WITH " + string(argument3))
}

function dialog_set_view(argument0) //gml_Script_dialog_set_view
{
    obj_dialog.d_view[global.dialog_num_total] = argument0
}

function dialog_set_trans(argument0) //gml_Script_dialog_set_trans
{
    obj_dialog.d_trans[global.dialog_num_total] = argument0
}

function ctext_length(argument0) //gml_Script_ctext_length
{
    var ind = 0
    var count = 0
    var c = string_copy(argument0, 1, 1)
    while ((ind < (string_length(argument0) + 1)))
    {
        if ((c == "$"))
            ind += 6
        else if ((c == "#"))
        {
        }
        else
            count++
        ind++
        c = string_copy(argument0, ind, 1)
    }
    return count;
}

function ctext_draw_mid(argument0, argument1, argument2, argument3) //gml_Script_ctext_draw_mid
{
    var xx = argument0
    var yy = argument1
    var c = string_copy(argument2, 1, 1)
    var ind = 1
    var ind_max = argument3
    var txList = ds_list_create()
    draw_set_align(fa_left, fa_top)
    while ((ind < (string_length(argument2) + 1)))
    {
        if ((c == "$"))
        {
            ind += 6
            ind_max += 6
        }
        else if ((c == "#"))
        {
            ds_list_add(txList, ((xx - argument0) / 2))
            xx = argument0
        }
        else
            xx += (string_width(c) + 1)
        ind++
        c = string_copy(argument2, ind, 1)
    }
    ds_list_add(txList, ((xx - argument0) / 2))
    yy = (argument1 - (((string_height(argument2) + 1) / 2) * ds_list_size(txList)))
    xx = (argument0 - ds_list_find_value(txList, 0))
    ds_list_delete(txList, 0)
    c = string_copy(argument2, 1, 1)
    ind = 1
    ind_max = argument3
    while ((ind < (string_length(argument2) + 1)))
    {
        if ((c == "$"))
        {
            draw_set_color(col_hex(string_copy(argument2, (ind + 1), 6)))
            ind += 6
            ind_max += 6
        }
        else if ((c == "#"))
        {
            xx = (argument0 - ds_list_find_value(txList, 0))
            ds_list_delete(txList, 0)
            yy += (string_height(argument2) + 1)
        }
        else
        {
            if ((ind < (ind_max + 1)))
                draw_text(xx, yy, c)
            xx += (string_width(c) + 1)
        }
        ind++
        c = string_copy(argument2, ind, 1)
    }
    ds_list_destroy(txList)
}

function ctext_draw(argument0, argument1, argument2, argument3) //gml_Script_ctext_draw
{
    var xx = argument0
    var yy = argument1
    var c = string_copy(argument2, 1, 1)
    var ind = 1
    var ind_max = argument3
    draw_set_align(fa_left, fa_top)
    while ((ind < (string_length(argument2) + 1)))
    {
        if ((c == "$"))
        {
            draw_set_color(col_hex(string_copy(argument2, (ind + 1), 6)))
            ind += 6
            ind_max += 6
        }
        else if ((c == "#"))
        {
            xx = argument0
            yy += (string_height(argument2) + 1)
        }
        else
        {
            if ((ind < (ind_max + 1)))
                draw_text(xx, yy, c)
            xx += (string_width(c) + 1)
        }
        ind++
        c = string_copy(argument2, ind, 1)
    }
}

function hex_to_dec(argument0) //gml_Script_hex_to_dec
{
    switch string_lower(argument0)
    {
        case "0":
            _id = 0
            return _id;
        case "1":
            _id = 1
            return _id;
        case "2":
            _id = 2
            return _id;
        case "3":
            _id = 3
            return _id;
        case "4":
            _id = 4
            return _id;
        case "5":
            _id = 5
            return _id;
        case "6":
            _id = 6
            return _id;
        case "7":
            _id = 7
            return _id;
        case "8":
            _id = 8
            return _id;
        case "9":
            _id = 9
            return _id;
        case "a":
            _id = 10
            return _id;
        case "b":
            _id = 11
            return _id;
        case "c":
            _id = 12
            return _id;
        case "d":
            _id = 13
            return _id;
        case "e":
            _id = 14
            return _id;
        case "f":
            _id = 15
            return _id;
        default:
            show_error(("invalid hex code: " + string(argument0)), 1)
            break
    }

}

function col_hex(argument0) //gml_Script_col_hex
{
    if ((string_length(argument0) != 6))
        show_error(("invalid hex code: " + string(argument0)), 1)
    return make_color_rgb(((15 * hex_to_dec(string_copy(argument0, 1, 1))) + hex_to_dec(string_copy(argument0, 2, 1))), ((15 * hex_to_dec(string_copy(argument0, 3, 1))) + hex_to_dec(string_copy(argument0, 4, 1))), ((15 * hex_to_dec(string_copy(argument0, 5, 1))) + hex_to_dec(string_copy(argument0, 6, 1))));
}

