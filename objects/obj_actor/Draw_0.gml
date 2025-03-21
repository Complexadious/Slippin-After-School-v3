if (role == "custom") 
{
    if (state == "idle" && idle_sprite != -1)
    {
        draw_sprite_ext_safe(idle_sprite, image_index, x, (y - 20), 
            dir * x_scale, y_scale * 0.1, 0, c_black, 0.5);
        draw_sprite_ext_safe(idle_sprite, image_index, x, y, 
            dir * x_scale, y_scale, 0, c_white, 1);
    }
    else if (state == "move" && walk_sprite != -1)
    {
        draw_sprite_ext_safe(walk_sprite, image_index, x, (y - 20), 
            dir * x_scale, y_scale * 0.1, 0, c_black, 0.5);
        draw_sprite_ext_safe(walk_sprite, image_index, x, y, 
            dir * x_scale, y_scale, 0, c_white, 1);
    }
}
else if (role == "shota")
{
    if (!obj_pkun.hiding)
    {
        draw_sprite_ext_safe(sprite_index, image_index, x, y, 
            dir, 0.1, 0, c_black, 0.5);
        draw_sprite_ext_safe(sprite_index, image_index, x, (y + 14), 
            dir, 1, 0, c_white, 1);
    }
}
else
{
    draw_sprite_ext_safe(sprite_index, image_index, x, (y - 20), 
        dir, 0.1, 0, c_black, 0.5);
    draw_sprite_ext_safe(sprite_index, image_index, x, y, 
        dir, 1, 0, c_white, 1);
}