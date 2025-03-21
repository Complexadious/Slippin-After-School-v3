/// @description Insert description here
// You can write your code in this editor
camera_set_view_size(view_camera[0], (zoom * 1280), (zoom * 720))
camera_get_view_width(view_camera[0])
camera_set_view_pos(view_camera[0],
	(x - (camera_get_view_width(view_camera[0]) / 2)),
	(y - camera_get_view_height(view_camera[0]) / 2)
)