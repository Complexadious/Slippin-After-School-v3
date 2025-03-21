/// @description Insert description here
// You can write your code in this editor
var cam = view_camera[0]
var width = camera_get_view_width(cam)
var height = camera_get_view_height(cam)
var vx = camera_get_view_x(cam)
var vy = camera_get_view_y(cam)

draw_sprite_stretched(spr, 0, vx, vy, width, height)