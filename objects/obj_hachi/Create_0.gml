event_inherited()
/// @description Insert description here
// You can write your code in this editor
lifespan = 0
mob_id = 9
state = (2)
dir = 1
soundDelay = 0
doTrack = 1
// mob_init_trace()
target_x = 0
timer = 0
lostTarget = 1
image_speed = 0
alp = 1
warpDelay = 300

// supports actor role
actor = 0

move_speed = 4
move = (can_client_mob_move()) ? move_speed : 0

show_debug_message("hachi created")