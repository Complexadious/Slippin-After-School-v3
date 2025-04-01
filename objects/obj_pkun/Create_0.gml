/// @description Insert description here
// You can write your code in this editor

// multiplayer stuff
__cache = {}
hidebox = -4
player_id = 0

flashOn = global.flashOn
hscene_target = global.hscene_target
pressing_interact = keyboard_check(vk_return)
lifeCur = global.lifeCur
lifeMax = global.lifeMax
charmed = global.charmed
itemSlot = global.itemSlot
dx = 0

move_speed = 0

last_movement_key = -4
last_move_speed = 0

entity_uuid = ""

audio_stop_all()
show_debug_message("CREATING PKUN!!");
//depth = -3
if (!instance_exists(obj_camera))
    cam = instance_create_depth((x - 400), (y - 200), 0, obj_camera)
if room != rm_forest
	depth = -3
shadow = instance_create_depth(x, y, 1, obj_pkun_shadow)
item_pool = -1
item_limit = 0
mob_poxol = -1
mob_limit = 0
milk_limit = 0
mobSpawnCt = 300
if (room == rm_game) {
	play_bgm(bgm_rain_inside)
//    show_debug_message("Running spawn_init in room: " + room_get_name(room));
    spawn_init();
}
image_speed = adjust_to_fps(0.25)
dir = 1
soundDelay = 0
global.hscene_target = -4

hs_stp = 0
hs_spr = -4
hs_ind = 0
hs_spd = 0
hs_lp = -1
hs_tmr = 0
hs_snd_delay = 0
hs_snd_prev = -4
hs_snd_efct = -1
hs_trans = 0
hs_cum = 0

hs_hide_fl = 0
hs_mob_id = 0

immortal = 0
global.trans_spd = adjust_to_fps(0.05)
running = 0
hiding = 0
stamina = 100
stmRegen = 0
exhaust = 0
runCost = ((room == rm_game) ? 0.25 : 0)
timeStop = 0
pantDelay = 0
nearestMob = -4
intrTarget = -4
intrDone = 0
intrNeed = 0
np = -4
lp = -4
portalPort = -1
miniMsgStr = ""
miniMsgTmr = 0

se_step = [se_step_a_1, se_step_a_2, se_step_a_3]
se_creak = [se_creak_1, se_creak_2, se_creak_3, se_creak_4]

sliding = 0
sliding_momentum = 0
slideCost = 0.1
slideSound = se_slide

noclip = 0

speed_multiplier = 1
//sliding_se_in = se_slide_in
//sliding_se_during = se_slide_during
//sliding_se_out = se_sliding_out

event_inherited()