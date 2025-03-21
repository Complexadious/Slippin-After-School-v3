function draw_flashlight(argument0) //gml_Script_draw_flashlight
{
    var fx = 0
    var fy = 0
    var i = -1
    if (argument0 && instance_exists(argument0))
    {
        i = floor(argument0.image_index)
        if ((global.hscene_target != -4))
        {
        }
        else if ((argument0.sprite_index == spr_pkun_idle))
        {
            if ((i == 0))
            {
                fx = 110
                fy = 196
            }
            else if ((i == 1))
            {
                fx = 110
                fy = 194
            }
            else if ((i == 2))
            {
                fx = 110
                fy = 196
            }
            else if ((i == 3))
            {
                fx = 110
                fy = 198
            }
        }
        else if ((argument0.sprite_index == spr_pkun_walk))
        {
            if ((i == 0))
            {
                fx = 108
                fy = 196
            }
            else if ((i == 1))
            {
                fx = 108
                fy = 198
            }
            else if ((i == 2))
            {
                fx = 110
                fy = 200
            }
            else if ((i == 3))
            {
                fx = 110
                fy = 196
            }
            else if ((i == 4))
            {
                fx = 110
                fy = 198
            }
            else if ((i == 5))
            {
                fx = 108
                fy = 200
            }
        }
        else if ((argument0.sprite_index == spr_pkun_dash))
        {
            if ((i == 0))
            {
                fx = 116
                fy = 202
            }
            else if ((i == 1))
            {
                fx = 116
                fy = 196
            }
            else if ((i == 2))
            {
                fx = 118
                fy = 198
            }
            else if ((i == 3))
            {
                fx = 118
                fy = 202
            }
            else if ((i == 4))
            {
                fx = 118
                fy = 196
            }
            else if ((i == 5))
            {
                fx = 116
                fy = 198
            }
        }
        draw_sprite_ext(spr_light_3, 0, (argument0.x + (fx * argument0.dir)), ((argument0.y - fy) + 16), argument0.dir, 0.6, 0, c_white, 0.5)
    }
}

