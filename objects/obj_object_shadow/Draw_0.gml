/// @description Insert description here
// You can write your code in this editor
if ((!global.dialog_acting) && (!parent_obj.hiding) && (!global.hscene_target))
    draw_sprite_ext_safe(parent_obj.sprite_index, parent_obj.image_index, parent_obj.x, parent_obj.y, parent_obj.dir, 0.1, 0, c_black, 0.5)
