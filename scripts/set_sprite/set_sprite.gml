function set_sprite(argument0, argument1) //gml_Script_set_sprite
{
	//argument1 = adjust_to_fps(argument1)
    if ((sprite_index != argument0) || (image_speed != argument1))
    {
        sprite_index = argument0
        image_speed = argument1
    }
}

