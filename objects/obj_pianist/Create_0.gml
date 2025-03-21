event_inherited()
/// @description Insert description here
// You can write your code in this editor
lifespan = 0
mob_id = 7
dir = 1
alp = 1
soundDelay = 0
doTrack = 0
timer = ((audio_sound_length(bgm_furelise) * 60) + 60)
piano = instance_create_depth(x, y, 0, obj_intr_piano)
distMax = 20000
dist = 0
p_emitter = audio_emitter_create()
p_elise = -4
playing = 1
with (obj_pkun)
{
    miniMsgTmr = 300
    miniMsgStr = getText("msg_piano")
}
np = portal_nearest()
lp = portal_linked(np)