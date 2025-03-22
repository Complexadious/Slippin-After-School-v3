function hscene_animate() //gml_Script_hscene_animate
{
	//instance_destroy(global.hscene_target)
	if !global.enable_nsfw
	{
		hscene_cum()
		hscene_end()
		return;
	}

    image_speed = 0
    if ((hs_snd_delay > 0))
        hs_snd_delay--
    if ((global.hscene_target.mob_id == 1))
    {
        if ((hs_stp == 0))
        {
            hscene_play(spr_wpangel_hs_res, 0.16666666666666666, 0)
            hscene_snd_at(se_resist, 1, 1)
        }
        else if ((hs_stp == 1))
        {
            hscene_play(spr_wpangel_hs_dwn, 0.16666666666666666, 0)
            hscene_snd_at(se_bodyfall, 1, 4)
        }
        else if ((hs_stp == 2))
        {
            hscene_play(spr_wpangel_hs_sex, 0.125, 8)
            hscene_snd_at(rand_hse("piston", 1), 0.6, 1)
        }
        else if ((hs_stp == 3))
        {
            hscene_play(spr_wpangel_hs_sex, 0.25, 14)
            hscene_snd_at(rand_hse("piston", 1), 1, 1)
        }
        else if ((hs_stp == 4))
        {
            hscene_cum()
            hscene_play_ext(spr_wpangel_hs_cum, 0.16666666666666666, 0, 100)
            hscene_snd_at(rand_hse("cum", 1), 1, 4)
            hscene_snd_at(rand_hse("cum", 1), 1, 8)
            hscene_snd_at(rand_hse("cum", 0), 1, 13)
            hscene_snd_at(rand_hse("cum", 0), 1, 21)
        }
        else
            hscene_end()
    }
    else if ((global.hscene_target.mob_id == 2))
    {
        if ((hs_stp == 0))
        {
            hscene_play(spr_ladypaint_hs_bj, 0.125, 8)
            hscene_snd_at(rand_hse("fera", 0), 0.6, 0)
        }
        else if ((hs_stp == 1))
        {
            hscene_play(spr_ladypaint_hs_bj, 0.25, 14)
            hscene_snd_at(rand_hse("deepfera", 0), 1, 0)
        }
        else if ((hs_stp == 2))
        {
            hscene_cum()
            hscene_play_ext(spr_ladypaint_hs_cum, 0.16666666666666666, 0, 100)
            hscene_snd_at(rand_hse("cum", 1), 1, 4)
            hscene_snd_at(rand_hse("cum", 1), 1, 8)
            hscene_snd_at(rand_hse("cum", 0), 1, 13)
            hscene_snd_at(rand_hse("cum", 0), 1, 21)
        }
        else
            hscene_end()
    }
    else if ((global.hscene_target.mob_id == 3))
    {
        if ((hs_stp == 0))
        {
            hscene_play(spr_kuchi_h_a, 0.125, 8)
            hscene_snd_at(rand_hse("piston", 1), 0.6, 2)
        }
        else if ((hs_stp == 1))
        {
            hscene_play(spr_kuchi_h_a, 0.25, 14)
            hscene_snd_at(rand_hse("piston", 1), 1, 2)
        }
        else if ((hs_stp == 2))
        {
            hscene_cum()
            hscene_play_ext(spr_kuchi_h_a_cum, 0.16666666666666666, 0, 100)
            hscene_snd_at(rand_hse("cum", 1), 1, 4)
            hscene_snd_at(rand_hse("cum", 1), 1, 8)
            hscene_snd_at(rand_hse("cum", 0), 1, 13)
            hscene_snd_at(rand_hse("cum", 0), 1, 21)
        }
        else
            hscene_end()
    }
    else if ((global.hscene_target.mob_id == 4))
    {
        if ((hs_stp == 0))
        {
            hscene_play(spr_jianshi_hs_sex, 0.125, 8)
            hscene_snd_at(rand_hse("piston", 1), 0.6, 2)
        }
        else if ((hs_stp == 1))
        {
            hscene_play(spr_jianshi_hs_sex, 0.25, 14)
            hscene_snd_at(rand_hse("piston", 1), 1, 2)
        }
        else if ((hs_stp == 2))
        {
            hscene_cum()
            hscene_play_ext(spr_jianshi_hs_cum, 0.16666666666666666, 0, 100)
            hscene_snd_at(rand_hse("cum", 1), 1, 4)
            hscene_snd_at(rand_hse("cum", 1), 1, 8)
            hscene_snd_at(rand_hse("cum", 0), 1, 13)
            hscene_snd_at(rand_hse("cum", 0), 1, 21)
        }
        else
            hscene_end()
    }
    else if ((global.hscene_target.mob_id == 5))
    {
        if ((hs_stp == 0))
        {
            hscene_play(spr_police_hs_res, 0.25, 0)
            hscene_snd_at(se_resist, 1, 4)
        }
        else if ((hs_stp == 1))
        {
            hscene_play(spr_police_hs_a, 0.125, 8)
            hscene_snd_at(rand_hse("rub", 1), 0.6, 2)
        }
        else if ((hs_stp == 2))
        {
            hscene_play(spr_police_hs_a, 0.25, 14)
            hscene_snd_at(rand_hse("rub", 1), 1, 2)
        }
        else if ((hs_stp == 3))
        {
            hscene_cum()
            hscene_play_ext(spr_police_hs_a_cum, 0.16666666666666666, 0, 100)
            hscene_snd_at(rand_hse("cum", 1), 1, 4)
            hscene_snd_at(rand_hse("cum", 1), 1, 8)
            hscene_snd_at(rand_hse("cum", 0), 1, 13)
            hscene_snd_at(rand_hse("cum", 0), 1, 21)
        }
        else
            hscene_end()
    }
    else if ((global.hscene_target.mob_id == 6))
    {
        if ((hs_stp == 0))
        {
            hs_trans = 1
            hscene_play(spr_doppel_sink, 0.25, 0)
            hscene_snd_at(se_resist, 1, 4)
        }
        else if ((hs_stp == 1))
        {
            hscene_play(spr_doppel_h1, 0.125, 8)
            hscene_snd_at(rand_hse("piston", 1), 0.6, 2)
        }
        else if ((hs_stp == 2))
        {
            hscene_play(spr_doppel_h1, 0.25, 14)
            hscene_snd_at(rand_hse("piston", 1), 1, 2)
        }
        else if ((hs_stp == 3))
        {
            hscene_cum()
            hscene_play_ext(spr_doppel_c1, 0.16666666666666666, 0, 100)
            hscene_snd_at(rand_hse("cum", 1), 1, 4)
            hscene_snd_at(rand_hse("cum", 1), 1, 8)
            hscene_snd_at(rand_hse("cum", 0), 1, 13)
            hscene_snd_at(rand_hse("cum", 0), 1, 21)
        }
        else
            hscene_end()
    }
    else if ((global.hscene_target.mob_id == 7))
    {
        if ((hs_stp == 0))
        {
            hscene_play(spr_pianist_h, 0.125, 8)
            hscene_snd_at(rand_hse("piston", 1), 0.6, 2)
        }
        else if ((hs_stp == 1))
        {
            hscene_play(spr_pianist_h, 0.25, 14)
            hscene_snd_at(rand_hse("piston", 1), 1, 2)
        }
        else if ((hs_stp == 2))
        {
            hscene_cum()
            hscene_play_ext(spr_pianist_h_c, 0.16666666666666666, 0, 100)
            hscene_snd_at(rand_hse("cum", 1), 1, 4)
            hscene_snd_at(rand_hse("cum", 1), 1, 8)
            hscene_snd_at(rand_hse("cum", 0), 1, 13)
            hscene_snd_at(rand_hse("cum", 0), 1, 21)
        }
        else
            hscene_end()
    }
    else if ((global.hscene_target.mob_id == 8))
    {
        if ((hs_stp == 0))
        {
            hscene_play(spr_mary_h, 0.125, 8)
            hscene_snd_at(rand_hse("piston", 1), 0.6, 2)
        }
        else if ((hs_stp == 1))
        {
            hscene_play(spr_mary_h, 0.25, 14)
            hscene_snd_at(rand_hse("piston", 1), 1, 2)
        }
        else if ((hs_stp == 2))
        {
            hscene_cum()
            hscene_play_ext(spr_mary_c, 0.16666666666666666, 0, 100)
            hscene_snd_at(rand_hse("cum", 1), 1, 4)
            hscene_snd_at(rand_hse("cum", 1), 1, 8)
            hscene_snd_at(rand_hse("cum", 0), 1, 13)
            hscene_snd_at(rand_hse("cum", 0), 1, 21)
        }
        else
            hscene_end()
    }
    else if ((global.hscene_target.mob_id == 9))
    {
        if ((hs_stp == 0))
        {
            hscene_play(spr_hachi_h1, 0.125, 8)
            hscene_snd_at(rand_hse("rub", 1), 0.6, 2)
        }
        else if ((hs_stp == 1))
        {
            hscene_play(spr_hachi_h2, 0.25, 14)
            hscene_snd_at(rand_hse("rub", 1), 1, 2)
        }
        else if ((hs_stp == 2))
        {
            hscene_cum()
            hscene_play_ext(spr_hachi_c2, 0.16666666666666666, 0, 100)
            hscene_snd_at(rand_hse("cum", 1), 1, 4)
            hscene_snd_at(rand_hse("cum", 1), 1, 8)
            hscene_snd_at(rand_hse("cum", 0), 1, 13)
            hscene_snd_at(rand_hse("cum", 0), 1, 21)
        }
        else
            hscene_end()
    }
    else if ((global.hscene_target.mob_id == 10))
    {
        if ((hs_stp == 0))
            hscene_play(spr_hanako_hs_a, 0, 0)
        else if ((hs_stp == 1))
        {
            hscene_play(spr_hanako_hs_a, 0.125, 8)
            hscene_snd_at(rand_hse("rub", 1), 0.6, 2)
        }
        else if ((hs_stp == 2))
        {
            hscene_play(spr_hanako_hs_a, 0.25, 14)
            hscene_snd_at(rand_hse("rub", 1), 1, 2)
        }
        else if ((hs_stp == 3))
        {
            hscene_play_ext(spr_hanako_hs_a_cum, 0.16666666666666666, 0, 100)
            hscene_snd_at(rand_hse("cum", 1), 1, 4)
            hscene_snd_at(rand_hse("cum", 1), 1, 8)
            hscene_snd_at(rand_hse("cum", 0), 1, 13)
            hscene_snd_at(rand_hse("cum", 0), 1, 21)
        }
        else
            hscene_end()
    }
    else if ((global.hscene_target.mob_id == 11))
    {
        if ((hs_stp == 0))
        {
            hscene_play(spr_hanako_hs_b, 0.125, 8)
            hscene_snd_at(rand_hse("piston", 1), 0.6, 2)
        }
        else if ((hs_stp == 1))
        {
            hscene_play(spr_hanako_hs_b, 0.25, 14)
            hscene_snd_at(rand_hse("piston", 1), 1, 2)
        }
        else if ((hs_stp == 2))
        {
            hscene_cum()
            hscene_play_ext(spr_hanako_hs_b_c, 0.16666666666666666, 0, 100)
            hscene_snd_at(rand_hse("cum", 1), 1, 4)
            hscene_snd_at(rand_hse("cum", 1), 1, 8)
            hscene_snd_at(rand_hse("cum", 0), 1, 13)
            hscene_snd_at(rand_hse("cum", 0), 1, 21)
        }
        else
            hscene_end()
    }
    else if ((global.hscene_target.mob_id == 12))
    {
        if ((hs_stp == 0))
        {
            hscene_play(spr_hanako_hs_c_lick, 0.125, 6)
            hscene_snd_at(rand_hse("fera", 1), 0.6, 2)
        }
        else if ((hs_stp == 1))
        {
            hscene_play(spr_hanako_hs_c_blow1, 0.125, 10)
            hscene_snd_at(rand_hse("fera", 1), 1, 2)
        }
        else if ((hs_stp == 2))
        {
            hscene_play(spr_hanako_hs_c_blow2, 0.25, 10)
            hscene_snd_at(rand_hse("deepfera", 1), 1, 2)
        }
        else if ((hs_stp == 3))
        {
            hscene_play_ext(spr_hanako_hs_c_cum, 0.16666666666666666, 0, 100)
            hscene_snd_at(rand_hse("cum", 1), 1, 6)
            hscene_snd_at(rand_hse("cum", 1), 1, 11)
            hscene_snd_at(rand_hse("cum", 0), 1, 17)
            hscene_snd_at(rand_hse("cum", 0), 1, 26)
        }
        else if ((hs_stp == 4))
        {
            hscene_play(spr_hanako_hs_d_blow, 0.25, 16)
            hscene_snd_at(rand_hse("deepfera", 1), 1, 2)
        }
        else if ((hs_stp == 5))
        {
            hscene_play_ext(spr_hanako_hs_d_cum, 0.16666666666666666, 0, 100)
            hscene_snd_at(rand_hse("cum", 1), 1, 6)
            hscene_snd_at(rand_hse("cum", 1), 1, 11)
            hscene_snd_at(rand_hse("cum", 0), 1, 17)
            hscene_snd_at(rand_hse("cum", 0), 1, 26)
        }
        else
            hscene_end()
    }
    else
        hscene_end()
    if ((!global.dialog_mode) && keyboard_check_pressed(vk_return))
    {
        hs_stp++
        hs_lp = -1
        hs_snd_delay = 0
    }
}

function hscene_play_ext(argument0, argument1, argument2, argument3) //gml_Script_hscene_play_ext
{
    hs_spd = adjust_to_fps(argument1)
    if ((hs_spr != argument0))
    {
        hs_spr = argument0
        hs_tmr = argument3
        hs_ind = 0
    }
    if ((hs_lp == -1) && (argument2 > 0))
        hs_lp = argument2
    if (((hs_ind + hs_spd) < sprite_get_number(argument0)))
        hs_ind += hs_spd
    else if ((hs_lp > 0))
    {
        if (!global.dialog_mode)
            hs_lp--
        hs_ind -= sprite_get_number(argument0)
    }
    else if ((hs_tmr > 0))
        hs_tmr--
    else
    {
        if (!global.dialog_mode)
            hs_stp++
        hs_lp = -1
        hs_snd_delay = 0
        if ((hs_trans == 1))
        {
            global.trans_alp = 1
            hs_trans = 0
        }
    }
}

function hscene_play(argument0, argument1, argument2) //gml_Script_hscene_play
{
    hscene_play_ext(argument0, argument1, argument2, 0)
}

function rand_hse(argument0, argument1) //gml_Script_rand_hse
{
    var snd = -4
    if argument1
        snd = asset_get_index(((("se_h_" + argument0) + "_") + string(irandom_range(1, 4))))
    else
    {
        do
        {
            snd = asset_get_index(((("se_h_" + argument0) + "_") + string(irandom_range(1, 4))))
        } until ((snd != -4) && (snd != hs_snd_prev));
    }
    return snd;
}

function hscene_snd_at(argument0, argument1, argument2) //gml_Script_hscene_snd_at
{
    if ((!hs_snd_delay) && (floor(hs_ind) == argument2))
    {
        hs_snd_delay = (1 / hs_spd)
        play_se(argument0, argument1)
        hs_snd_prev = argument0
        var efct = instance_create_depth((x + (irandom_range(120, 150) * hs_snd_efct)), (y - irandom_range(30, 150)), -9999999, obj_efct_sfx)
        with (efct)
        {
            tx = (x + (other.hs_snd_efct * 50))
            sndstr = audio_get_name(other.hs_snd_prev)
            if string_pos("piston", sndstr)
                ind = 0
            else if string_pos("fera", sndstr)
                ind = 1
            else if string_pos("cum", sndstr)
                ind = 2
            else if string_pos("rub", sndstr)
                ind = 3
        }
        hs_snd_efct *= -1
    }
}

function hscene_end() //gml_Script_hscene_end
{
    if (!global.game_is_over)
    {
        global.hscene_target = -4
        global.trans_alp = 1
        global.hscene_hide_fl = 0
        hs_stp = 0
        hs_lp = -1
        hs_ind = 0
        hs_spd = 0
        hs_spr = -4
        hs_tmr = 0
        hs_snd_delay = 0
        hs_snd_prev = -4
        hs_snd_efct = -1
        hs_trans = 0
        hs_cum = 0
        immortal = 180
        with (obj_p_mob)
            instance_destroy()
        if hiding
        {
            hiding = 0
            intrTarget.shake = 20
            play_se(intrTarget.se_out, 1)
            if ((intrTarget.object_index == obj_intr_hidebox))
            {
                with (intrTarget)
                    instance_destroy()
                intrTarget = -4
            }
        }
        mobSpawnCt = (irandom_range(400, 600) * (1 - ((0.4 * global.clock_tk) / 360)))
    }
}

function hscene_cum() //gml_Script_hscene_cum
{
    if ((room == rm_game) && (!hs_cum))
    {
        hs_cum = 1
        global.charmed = 0
        if ((global.lifeCur > 0))
            global.lifeCur--
        obj_camera.lifeloss_t = 60
        if ((global.lifeCur <= 0))
            global.game_is_over = 1
    }
}

