/// @description Insert description here
// You can write your code in this editor
show_debug_message("CREATING CAMERA!!");
show_debug_message("Camera created at: " + string(x) + ", " + string(y));


depth = -99999
surf = surface_create(1280, 720)
camTarget = -4
camZoom = 0
shotaActor = -4
intrText = ""
lifeloss_t = 0
elps_s = 1
elps_m = 1

freecam = 0
reset_cam_target = 0
oldCamTarget = -4

zoom = 1
max_zoom = 10
min_zoom = 0.1

ui_alp = 1

if room == rm_game
{
for (var d = 100; d > 0; d--)
    instance_create_depth(x, y, -999, obj_efct_dust)
}
