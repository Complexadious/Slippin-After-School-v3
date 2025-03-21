/// @description Insert description here
// You can write your code in this editor
if hide_spot
{
    if (!global.hscene_target)
    {
        depth = (hide_spot.depth - 1)
        if ((hide_spot.object_index == obj_intr_rstrmdoor))
            draw_sprite_ext_safe(spr_hanako_rstrdoor, ani_index, hide_spot.x, hide_spot.y, 1, 1, 0, c_white, 1, 1)
        else
            draw_sprite_ext_safe(spr_hanako_locker, ani_index, hide_spot.x, hide_spot.y, 1, 1, 0, c_white, 1, 1)
    }
    else if ((global.hscene_target == self))
    {
        depth = -9
        if (pit && (pit.object_index != obj_intr_hidebox))
        {
            var spr = pit.sprite_index
            if ((spr == spr_prop_rstrmdoor))
                draw_sprite_ext_safe(ts_restroom_frm_only, 0, ((pit.x < 2000) ? 928 : 4186), (4362 + (720 * (floor((obj_pkun.y / 720)) % 3))), 1, 1, 0, c_white, 0.65)
            draw_sprite_ext_safe(spr, (sprite_get_number(spr) - 1), pit.x, pit.y, 1, 1, 0, c_white, 0.65)
        }
    }
}
