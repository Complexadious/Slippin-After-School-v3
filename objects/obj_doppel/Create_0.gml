event_inherited()
/// @description Insert description here
// You can write your code in this editor
lifespan = 300
target_x = 0
// mob_init_trace()
mob_id = 6
dir = 1
mob_set_state(2)
alp = 0.5
soundDelay = 0
lostTarget = 1
doTrack = 1
image_speed = 0
spdMax = adjust_to_fps(7)
spdMin = adjust_to_fps(1)
spd = adjust_to_fps(1)

move_speed = spd
move = (can_client_mob_move()) ? move_speed : 0
current_target = obj_pkun