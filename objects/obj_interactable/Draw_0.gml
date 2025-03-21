var vx = instance_exists(obj_camera) ? global.obj_cam_vx : camera_get_view_x(view_camera[0])
var vy = instance_exists(obj_camera) ? global.obj_cam_vy : camera_get_view_y(view_camera[0])

if instance_exists(obj_pkun) && (obj_pkun.intrTarget == id) {
	draw_set_font(fnt_minecraft)
	draw_set_color(c_purple)
	draw_text(vx + 100, vy + 100, string(m_intr_id))
}
