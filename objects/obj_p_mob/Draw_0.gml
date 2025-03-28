/// @description Insert description here
// You can write your code in this editor
if (controlled != 0) {
	draw_set_align(fa_center, fa_middle)
	draw_set_color(c_red)
	draw_set_font(fnt_minecraft)
	draw_text(x, y - sprite_height, "CONTROLLED: " + string(controlled))
}