var cam = view_camera[0]
var vx = camera_get_view_x(cam)
var vy = camera_get_view_y(cam)
draw_sprite_ext_safe(spr_title_1, 0, 0, 0, 1, 1, 0, c_white, (global.cowardOn ? 0.5 : 0.8))
if (zoom <= 0.1)
{
    if (global.trans_alp == 0)
    {
        if (menu_alp < 1)
            menu_alp += adjust_to_fps(0.005)
    }
    if (!global.setting_mode)
    {
        draw_sprite_ext_safe(spr_title_0, global.language, (vx + 640), (vy + 250), 1, 1, 0, c_white, menu_alp)
        for (var i = 0; i < 5; i++)
        {
            var s = 1
            var c = make_color_rgb(80, 80, 80)
            if (menu_ind == i)
            {
                s = 1.2
                c = c_white
            }
            if ((i == 1 && global.clock_hr_load == -1) || (i == 2 && global.gallery_lock))
                draw_sprite_ext_safe(spr_ui_title_menu, i, (vx + 640), (vy + 450 + 50 * i), s, s, 0, c, (menu_alp * 0.35))
            else if (i == 1 && menu_ind == 1)
            {
                draw_set_alpha(menu_alp)
                draw_set_color(c_white)
                draw_set_align(fa_center, fa_middle)
                setFont("B", 16)
                draw_text((vx + 640), (vy + 450 + 50 * i + 20), (string(global.clock_hr_load) + ":00 AM"))
                draw_set_alpha(1)
                draw_sprite_ext_safe(spr_ui_title_menu, i, (vx + 640), (vy + 450 + 50 * i - 10), s, s, 0, c, menu_alp)
            }
            else
                draw_sprite_ext_safe(spr_ui_title_menu, i, (vx + 640), (vy + 450 + 50 * i), s, s, 0, c, menu_alp)
        }
    }
    else
        draw_ui_setting((vx + 470), (vy + 260))
    layer_set_visible("title_3_1", global.end_leave)
    layer_set_visible("title_3_2", global.end_stay)
    layer_x(layer_get_id("title_2"), lerp(0, vx, 0.1))
    layer_x(layer_get_id("title_3"), lerp(10, vx, 0.4))
    layer_x(layer_get_id("title_3_1"), lerp(10, vx, 0.4))
    layer_x(layer_get_id("title_3_2"), lerp(10, vx, 0.4))
    layer_x(layer_get_id("title_4"), lerp(0, vx, 0.6))
    layer_y(layer_get_id("title_2"), lerp(0, vy, 0.1))
    layer_y(layer_get_id("title_3"), lerp(-10, vy, 0.5))
    layer_y(layer_get_id("title_3_1"), lerp(-10, vy, 0.5))
    layer_y(layer_get_id("title_3_2"), lerp(-10, vy, 0.5))
    layer_y(layer_get_id("title_4"), lerp(-60, vy, 0.6))
}
if (t > 0)
    t-= adjust_to_fps(1)
else
{
    t = irandom_range(30, 50)
    tx = room_width / 2 + (choose(-1, 1)) * irandom(400)
    ty = room_height / 2 + (choose(-1, 1)) * irandom(600)
}
cx += adjust_to_fps((tx - cx) / 60)
cy += adjust_to_fps((ty - cy) / 60)
if (cx >= 1320)
{
    cx = 1320
    t = 0
}
else if (cx <= 0)
{
    cx = 0
    t = 0
}
if (cy >= 760)
{
    cy = 760
    t = 0
}
else if (cy <= 0)
{
    cy = 0
    t = 0
}
draw_set_align(fa_left, fa_bottom)
draw_set_color(c_white)
setFont("B", 16)
draw_text(vx, (vy + 720), global.title_msg)
camera_set_view_pos(cam, (40 * (cx / 1320) + 480 * zoom / 20), (40 * (cy / 760) + 400 * zoom / 20))
camera_set_view_size(cam, (1280 - 960 * zoom / 20), (720 - 540 * zoom / 20))
