if (!instance_exists(obj_sys)) {
    instance_create_depth(0, 0, 0, obj_sys);
}

// In obj_title Create event
if (!view_enabled)
{
    view_enabled = true;
    view_visible[0] = true;
}

var cam = view_camera[0];
camera_set_view_size(cam, 1280, 720);
camera_set_view_pos(cam, 0, 0);

play_bgm(bgm_rain_outside)
//show_debug_message("Playing BGM asset index: " + string(int64(bgm_rain_outside)));
//show_debug_message("Current BGM asset index: " + string(int64(global.bgm_curr)));
//show_debug_message("BGM Volume: " + string(real(global.vol_bgm)));
global.trans_spd = adjust_to_fps(0.01)
menu_ind = global.clock_hr_load
menu_alp = 0
t = 0
tx = 0
ty = 0
cx = 0
cy = 0
zoom = 0
zspd = 100

trans_alp_intro_correction_timer = 132 //132
trans_alp_intro_correction_active = 1