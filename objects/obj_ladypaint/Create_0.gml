event_inherited()
/// @description Insert description here
// You can write your code in this editor
lifespan = 600
target_x = 0
// mob_init_trace()
mob_id = 2
dir = 1
mob_set_state(0)
soundDelay = 0
lostTarget = 1
doTrack = 1
image_speed = 0
alp = 1
timer = irandom_range(30, 60)
yy = 240
fall_timer = 10

move_speed = 7
move = (can_client_mob_move()) ? move_speed : 0
current_target = obj_pkun