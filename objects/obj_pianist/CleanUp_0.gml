/// @description Insert description here
// You can write your code in this editor
if ((p_elise != -4))
{
    audio_stop_sound(p_elise)
    p_elise = -4
}
with (piano)
    instance_destroy()
if audio_emitter_exists(p_emitter)
    audio_emitter_free(p_emitter)
