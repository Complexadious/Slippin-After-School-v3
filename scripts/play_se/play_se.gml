function play_se(argument0, argument1 = 1) //gml_Script_play_se
{
    if ((argument0 != -4))
    {
        var s = audio_play_sound(argument0, 0, false)
        audio_sound_gain(s, (argument1 * (global.vol_se / 100)), 0)
    }
}

