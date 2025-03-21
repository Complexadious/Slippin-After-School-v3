function clock_init() //gml_Script_clock_init
{
    global.clock_hr_load = -1
	sys_load_stage(1)
    global.clock_hr = -1
    global.clock_min = 0
    global.clock_tk = -1
    global.clock_tk_spd = adjust_to_fps(1)
    global.clock_trans_t = -1
    global.clock_reset_rm = 0
}

function clock_transition() //gml_Script_clock_transition
{
    if ((global.clock_hr == 1))
        global.clock_hr = 12
    else
        global.clock_hr--
    global.clock_min = 59
    global.clock_tk = 300
    global.clock_tk_spd = adjust_to_fps(0.75)
    global.clock_trans_t = 300
    global.transition = 2
    global.trans_alp = 1
}

function clock_tick() //gml_Script_clock_tick
{
    if ((global.clock_tk == -1))
    {
        if ((global.clock_hr == -1))
        {
            clock_begin_dialog()
            global.clock_hr = 12
        }
        else if ((global.clock_hr == 1))
            global.clock_hr = 12
        else
            global.clock_hr--
        global.clock_min = 59
        global.clock_tk = 360
    }
    else if ((global.clock_tk < 360))
        global.clock_tk += global.clock_tk_spd
    else
    {
        global.clock_tk = 0
        if ((global.clock_min < 59))
            global.clock_min++
        else
        {
            global.clock_min = 0
            if ((global.clock_hr < 12))
                global.clock_hr++
            else
                global.clock_hr = 1
            if ((global.clock_trans_t == -1))
            {
                sys_save_stage()
                if global.clock_reset_rm
                {
                    global.lastX = obj_pkun.x
                    global.lastY = obj_pkun.y
                    room_restart()
                }
                else
                    global.clock_reset_rm = 1
                clock_transition()
            }
            else
            {
                game_ring_bell(global.clock_hr)
                clock_begin_dialog()
            }
        }
    }
}

function draw_ui_clock(argument0, argument1, argument2) //gml_Script_draw_ui_clock
{
    if global.clock_hr
    {
        draw_sprite_ext(spr_ui_clock_frm, (floor((global.clock_tk / 30)) % 2), argument0, argument1, argument2, argument2, 0, c_white, 1)
        draw_sprite_ext(spr_ui_clock_num, floor((global.clock_hr / 10)), argument0, argument1, argument2, argument2, 0, c_white, 1)
        draw_sprite_ext(spr_ui_clock_num, (global.clock_hr % 10), (argument0 + (25 * argument2)), argument1, argument2, argument2, 0, c_white, 1)
        draw_sprite_ext(spr_ui_clock_num, floor((global.clock_min / 10)), (argument0 + (65 * argument2)), argument1, argument2, argument2, 0, c_white, 1)
        draw_sprite_ext(spr_ui_clock_num, (global.clock_min % 10), (argument0 + (90 * argument2)), argument1, argument2, argument2, 0, c_white, 1)
    }
}

function clock_begin_dialog() //gml_Script_clock_begin_dialog
{
    global.dialog_show_box = 1
    if ((global.clock_hr == -1)) && !global.dialog_disable_acts
    {
        dialog_add_line(getText("shotakun"), getText("ch1_1"))
        dialog_add_act(new Act("shota", -4, obj_pkun.x, obj_pkun.y))
        dialog_add_act(new Act("item", -4, (obj_pkun.x + 900), obj_pkun.y))
        dialog_add_line(getText("shotakun"), getText("ch1_2"))
        dialog_add_line(getText("shotakun"), getText("ch1_3"))
        dialog_add_line("", " ")
        dialog_add_act(new Act("shota", 4, 1, 550))
        dialog_add_line(getText("shotakun"), "?")
        dialog_add_line("", " ")
        dialog_add_act(new Act("shota", 4, 1, 250))
        dialog_add_line(getText("shotakun"), getText("ch1_4"))
        dialog_add_act(new Act("item", -1, 0, 0))
        dialog_add_line(getText("shotakun"), getText("ch1_5"))
        dialog_add_line(getText("shotakun"), "!")
        dialog_add_act(new Act("shota", 0, -1, 0))
        dialog_add_line(getText("shotakun"), getText("ch1_6"))
        dialog_add_line("", " ")
        dialog_add_act(new Act("shota", 12, 1, 250))
        dialog_add_line("", " ")
        dialog_add_act(new Act("shota", 12, 1, 1100))
        dialog_add_line("", " ")
//        dialog_add_act(new Act("redmask", -4, 3424, 4880))
		dialog_add_act(new Act("custom", -4, 3424, 4880, {
		    idle_sprite: spr_hachi_idle,
		    walk_sprite: spr_hachi_walk,
		    image_speed: 0.5,
		    walk_sound: choose(se_step_b_1, se_step_b_2, se_step_b_3),
		    sound_index: [0, 3],
		    sound_delay: 10,
			make_pkun_hide: 1
		}));
//        dialog_add_act(new Act("custom", 8, 1, 1100))
		dialog_add_act(new Act("custom", 4, 1, 1100, {
		    idle_sprite: spr_hachi_idle,
		    walk_sprite: spr_hachi_walk,
		    image_speed: 0.5,
		    walk_sound: choose(se_step_b_1, se_step_b_2, se_step_b_3),
		    sound_index: [0, 3],
		    sound_delay: 10,
			make_pkun_hide: 1
		}));
        dialog_add_line("???", "...")
        dialog_add_line("", " ")
//        dialog_add_act(new Act("redmask", 8, -1, 1100))
		dialog_add_act(new Act("custom", 4, -1, 1100, {
		    idle_sprite: spr_hachi_idle,
		    walk_sprite: spr_hachi_walk,
		    image_speed: 0.5,
		    walk_sound: choose(se_step_b_1, se_step_b_2, se_step_b_3),
		    sound_index: [0, 3],
		    sound_delay: 10,
			make_pkun_hide: 1
		}));
        dialog_add_line(getText("shotakun"), "...")
        dialog_add_line(getText("shotakun"), getText("ch1_7"))
//        dialog_add_act(new Act("redmask", -1, 0, 0))
		dialog_add_act(new Act("custom", -1, 0, 0, {
		    idle_sprite: spr_hachi_idle,
		    walk_sprite: spr_hachi_walk,
		    image_speed: 0.5,
		    walk_sound: choose(se_step_b_1, se_step_b_2, se_step_b_3),
		    sound_index: [0, 3],
		    sound_delay: 10,
			make_pkun_hide: 1
		}));
        dialog_add_act(new Act("shota", 0, -1, 0))
        dialog_add_line(getText("shotakun"), getText("ch1_8"))
        dialog_add_line(getText("hanako"), getText("ch1_9"))
        dialog_add_act(new Act("hanako", -4, 4874, 4880))
        dialog_add_act(new Act("hanako", 0, -1, 0))
        dialog_set_view("hanako")
        dialog_add_line(getText("shotakun"), getText("ch1_10"))
        dialog_add_act(new Act("shota", 0, 1, 0))
        dialog_set_view("shota")
        dialog_add_line(getText("hanako"), getText("ch1_11"))
        dialog_set_view("hanako")
        dialog_add_line(getText("hanako"), getText("ch1_12"))
        dialog_add_line(getText("hanako"), getText("ch1_13"))
        dialog_add_line(getText("shotakun"), getText("ch1_14"))
        dialog_set_view("shota")
        dialog_add_line(getText("hanako"), getText("ch1_15"))
        dialog_set_view("hanako")
        dialog_add_line(getText("shotakun"), getText("ch1_16"))
        dialog_set_view(-4)
        dialog_hscene(10, 0)
        dialog_add_line(getText("hanako"), getText("ch1_17"))
        dialog_hscene(10, 1)
        dialog_add_line(getText("shotakun"), getText("ch1_18"))
        dialog_hscene(10, 1)
        dialog_add_line(getText("shotakun"), getText("ch1_19"))
        dialog_hscene(10, 1)
        dialog_add_line(getText("hanako"), getText("ch1_20"))
    }
    else if ((global.clock_hr == 1))
    {
        dialog_add_line("", getText("tut_1"))
        dialog_add_line("", getText("tut_2"))
    }
    global.dialog_mode = 1
}

