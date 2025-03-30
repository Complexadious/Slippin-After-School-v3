/// @description Insert description here
// You can write your code in this editor
draw_sprite(spr_prop_pendulum, 2, x, y)
if ((!global.menu_mode) && (!global.timeStop))
{
    if swing
    {
        if ((angle < 10))
            angle += adjust_to_fps(2/3)
        else
            swing = -1
    }
    else if ((angle > -10))
        angle -= adjust_to_fps(2/3)
    else
        swing = 1
}
draw_sprite_ext_safe(spr_prop_pendulum, 1, x, y, 1, 1, angle, c_white, 1)
draw_sprite(spr_prop_pendulum, 0, x, y)
