/// @description Insert description here
// You can write your code in this editor
if ((alp > 0))
    alp -= adjust_to_fps(0.01)
if instance_exists(from_obj)
    draw_sprite_ext_safe(sprite_index, image_index, ((from_obj.x + xx) + (from_obj.dir * 12)), ((from_obj.y + yy) - 308), 1, 1, image_angle, c_white, alp)
show_debug_message("[" + string(id) + "] efct pant draw for " + string(object_get_name(from_obj.object_index)) + " at X:" + string(((from_obj.x + xx) + (from_obj.dir * 12))) + " Y:" + string(((from_obj.y + yy) - 308)) + " alp: " + string(alp))