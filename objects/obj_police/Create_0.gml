event_inherited()
/// @description Insert description here
// You can write your code in this editor
lifespan = irandom_range(3, 6)
mob_id = 5
dir = 1
alp = 1
soundDelay = 0
doTrack = 0
stop = 0
stopAt = -1
delay = 0
stopTimer = irandom_range(180, 270)
play_se(se_whistle_caught, 1)
current_target = obj_pkun

parent_pid = (variable_instance_exists(id, "parent_pid")) ? parent_pid : -1
parent_obj = (parent_pid > -1) ? pid_to_inst(parent_pid) : obj_pkun

x = parent_obj.x //(instance_exists(parent_obj)) ? parent_obj.x : obj_pkun.x
y = parent_obj.y //(instance_exists(parent_obj)) ? parent_obj.y : obj_pkun.y
