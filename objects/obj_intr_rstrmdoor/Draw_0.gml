/// @description Insert description here
// You can write your code in this editor
if (instance_exists(obj_pkun)) && ((obj_pkun.intrTarget == id) && obj_pkun.hiding)
    draw_sprite(sprite_index, 1, (x + (choose(-1, 1) * shake)), y)
else
    draw_sprite(sprite_index, locked, (x + (choose(-1, 1) * shake)), y)
event_inherited()