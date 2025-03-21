var cam = view_camera[0]
var vx = camera_get_view_x(cam)
var vy = camera_get_view_y(cam)

// Set text properties
draw_set_halign(fa_center); // Center horizontally
draw_set_valign(fa_middle); // Center vertically
draw_set_color(c_olive);
draw_set_alpha(alp)

// Determine center of the view
var text_x = vx + 880; // Horizontal center
var text_y = vy + 295; // Vertical center

// Draw the text with scaling and static rotation
draw_text_transformed(text_x + sec_text_offset, text_y + sec_text_offset, text, scale, scale, rotation);
draw_set_color(c_yellow);
draw_text_transformed(text_x, text_y, text, scale, scale, rotation);
