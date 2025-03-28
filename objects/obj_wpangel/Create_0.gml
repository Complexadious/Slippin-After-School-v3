event_inherited()
/// @description Insert description here
// You can write your code in this editor
lifespan = 300
target_x = 0
// mob_init_trace()
mob_id = 1
dir = 1
mob_set_state(2)
alp = 0
soundDelay = 0
lostTarget = 1
doTrack = 1
image_speed = 0
stop = 0
heartRate = 0
heartTimer = 0

move_speed = 6

move = (can_client_mob_move()) ? move_speed : 0
//move = (can_client_mob_move())