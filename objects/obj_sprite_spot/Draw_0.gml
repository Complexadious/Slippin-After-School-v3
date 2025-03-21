/// obj_sprite_spot Draw Event
if (sprite != noone) {
    // Draw with color blending for darkness
    draw_sprite_ext_safe(sprite, 
                   index, 
                   x, 
                   y, 
                   sprite_xscale, 
                   sprite_yscale, 
                   0, 
                   merge_color(c_white, blend_color, darkness), 
                   sprite_alpha);
}