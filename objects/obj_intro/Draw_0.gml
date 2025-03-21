/// @description Insert description here
// You can write your code in this editor
if ((s == 0))
{
    draw_sprite_ext_safe(spr_logo, 0, x, y, 1, 1, 0, c_white, ((200 - t) / 80))
    if ((t >= 200) || keyboard_check_pressed(vk_return))
    {
        t = 0
        s++
    }
    else
        t+= adjust_to_fps(1)
}
else if ((s == 1))
{
    global.transition = 1
    global.trans_goto = rm_title
    global.trans_alp = 1
}
