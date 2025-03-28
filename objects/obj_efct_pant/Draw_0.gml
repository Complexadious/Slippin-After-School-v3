/// @description Insert description here
// You can write your code in this editor
if ((alp > 0))
    alp -= adjust_to_fps(0.01)
if instance_exists(from_obj)
    draw_sprite_ext_safe(sprite_index, image_index, ((from_obj.x + xx) + (from_obj.dir * 12)), ((from_obj.y + yy) - 308), 1, 1, image_angle, c_white, alp)
