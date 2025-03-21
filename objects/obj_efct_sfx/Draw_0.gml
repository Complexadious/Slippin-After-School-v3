/// @description Insert description here
// You can write your code in this editor
x -= adjust_to_fps((x - tx) / 30)
if (alp > 0)
    alp -= adjust_to_fps(0.02)
else
    instance_destroy()
if (ind != -1)
    draw_sprite_ext_safe(sprite_index, ind, x, y, 1, 1, 0, c_white, alp)
