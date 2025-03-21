/// Rain Draw Event
// For rain effect, we want to rotate the opposite direction of movement
var visual_rot = rot;  // Use the same angle for visual rotation

draw_sprite_ext_safe(sprite_index, 0, x, y, 1, ys, visual_rot, c_white, alp);
draw_sprite_ext_safe(sprite_index, 0, (x + x1), (y + y1), 1, ys, visual_rot, c_white, alp);
draw_sprite_ext_safe(sprite_index, 0, (x + x2), (y + y2), 1, ys, visual_rot, c_white, alp);