/// @description Insert description here
// You can write your code in this editor
alp = 1.2
image_angle = choose(0, 90, 180, 270)
xx = random_range(-4, 4)
yy = random_range(-3, 3)
image_speed = adjust_to_fps(0.5)
from_obj = obj_pkun
depth = from_obj.depth + 5
show_debug_message("[" + string(id) + "] efct pant created for " + string(object_get_name(from_obj.object_index)) + " at x" + string(x) + " y" + string(y))