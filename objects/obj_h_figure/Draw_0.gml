/// @description Insert description here
// You can write your code in this editor
if ((global.hscene_target != id))
{
    if ((sprite_index == spr_h_figure))
    {
        if ((mob_id == 1))
            set_sprite(spr_wpangel_idle, 0)
        else if ((mob_id == 2))
            set_sprite(spr_ladypaint_walk, 0)
        else if ((mob_id == 3))
        {
            set_sprite(spr_kuchi_idle, (1/3))
            hide_fl = 1
        }
        else if ((mob_id == 4))
        {
            set_sprite(spr_jianshi_jump, 1)
            hide_fl = 1
        }
        else if ((mob_id == 5))
        {
            set_sprite(spr_police_idle, 0.5)
            shadow = 0
            ry = 100
        }
        else if ((mob_id == 6))
        {
            sprite_index = spr_doppel_appear
            image_index = 7
            hide_fl = 1
        }
        else if ((mob_id == 7))
            set_sprite(spr_pianist_play, 1)
        else if ((mob_id == 8))
            sprite_index = spr_mary_h
        else if ((mob_id == 9))
        {
            set_sprite(spr_hachi_idle, (1/3))
            hide_fl = 1
        }
        else if ((mob_id == 10))
            set_sprite(spr_hanako_idle, (1/3))
        else if ((mob_id == 11))
        {
            set_sprite(spr_hanako_idle, (1/3))
            hide_fl = 1
        }
        else if ((mob_id == 12))
        {
            set_sprite(spr_hanako_idle, (1/3))
            hide_fl = 1
        }
    }
    else
    {
        if ((x > obj_pkun.x))
            dir = -1
        else
            dir = 1
        depth = -1
        if shadow
            draw_sprite_ext_safe(sprite_index, image_index, x, ((y - 20) - ry), dir, 0.1, 0, c_black, 0.5)
        draw_sprite_ext_safe(sprite_index, image_index, x, (y - ry), dir, 1, 0, c_white, 1)
    }
}
else if ((mob_id == 11))
{
    depth = -9
    var nd = instance_nearest(x, y, obj_intr_rstrmdoor)
    obj_pkun.x = nd.x
    draw_sprite_ext_safe(ts_restroom_frm_only, 0, 6176, 42, 1, 1, 0, c_white, 0.65)
    draw_sprite_ext_safe(spr_prop_rstrmdoor, 1, nd.x, nd.y, 1, 1, 0, c_white, 0.65)
}
