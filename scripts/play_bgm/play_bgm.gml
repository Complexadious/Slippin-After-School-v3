function play_bgm(argument0) //gml_Script_play_bgm
{
    if ((global.bgm_curr != argument0))
    {
        global.bgm_prev = global.bgm_curr
        global.bgm_curr = argument0
        if ((global.bgm_prev != -4) && audio_is_playing(global.bgm_prev))
            audio_stop_sound(global.bgm_prev)
    }
}

