/// @description Insert description here
// You can write your code in this editor
if !played_sound
{
	play_se(reveal_sound, 1)
	if spr_sound
		play_se(spr_sound, 1)
	played_sound = 1
	
	// timer shit
	timer = (spr_sound) ? audio_sound_length(spr_sound) : audio_sound_length(reveal_sound)
	timer *= fps
}

if timer > 0
	timer--
else
	instance_destroy();