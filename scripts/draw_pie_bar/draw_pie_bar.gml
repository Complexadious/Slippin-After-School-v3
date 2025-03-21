function draw_pie_bar(argument0, argument1, argument2, argument3, argument4, argument5, argument6, argument7) //gml_Script_draw_pie_bar
{
    if ((argument2 > 0))
    {
        var numberofsections = 60
        var sizeofsection = (360 / numberofsections)
        var val = ((argument2 / argument3) * numberofsections)
        if ((val > 1))
        {
            piesurface = surface_create((argument5 * 2), (argument5 * 2))
            draw_set_colour(argument4)
            draw_set_alpha(argument6)
            surface_set_target(piesurface)
            draw_clear_alpha(c_blue, 0.7)
            draw_clear_alpha(c_black, 0)
            draw_primitive_begin(6)
            draw_vertex(argument5, argument5)
            for (var i = 0; i <= val; i++)
            {
                var len = ((i * sizeofsection) + 90)
                var tx = lengthdir_x(argument5, len)
                var ty = lengthdir_y(argument5, len)
                draw_vertex((argument5 + tx), (argument5 + ty))
            }
            draw_primitive_end()
            draw_set_alpha(1)
            gpu_set_blendmode(bm_subtract)
            draw_set_colour(c_black)
            draw_circle((argument5 - 1), (argument5 - 1), (argument5 - argument7), 0)
            gpu_set_blendmode(bm_normal)
            surface_reset_target()
            draw_surface(piesurface, (argument0 - argument5), (argument1 - argument5))
            surface_free(piesurface)
        }
    }
}

