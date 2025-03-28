event_inherited()

/// @description Insert description here
// You can write your code in this editor
if ((!global.dialog_acting) && (global.hscene_target == -4))
{
    draw_sprite_ext_safe(sprite_index, image_index, x, (y - 20), dir, 0.1, 0, c_black, (0.5 * alp))
    draw_sprite_ext_safe(sprite_index, image_index, x, y, dir, 1, 0, ((controlled != 0) ? c_purple : c_white), (1 * alp))
}