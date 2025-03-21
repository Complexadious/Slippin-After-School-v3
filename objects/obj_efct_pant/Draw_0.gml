/// @description Insert description here
// You can write your code in this editor
if ((alp > 0))
    alp -= 0.01
if instance_exists(obj_pkun)
    draw_sprite_ext_safe(sprite_index, image_index, ((obj_pkun.x + xx) + (obj_pkun.dir * 12)), ((obj_pkun.y + yy) - 308), 1, 1, image_angle, c_white, alp)
