var vx = camera_get_view_x(view_camera[0])
var vy = camera_get_view_y(view_camera[0])

ui_alp = (freecam) ? 0.25 : 1

// why do i need to do this :(
global.obj_cam_vx = vx
global.obj_cam_vy = vy

var c_g = make_color_rgb(36, 36, 36)
var c_r = make_color_rgb(100, 0, 0)
var c_p = make_color_hsv(225, (130 + (20 * global.shaderOn)), 255)
var p = obj_pkun

if !instance_exists(camTarget)
	camTarget = -4

// free_cam
if keyboard_check_pressed(global.keybinds[$ "freecamToggle"]) { 
	freecam = !freecam
	if freecam {
		// on enabling freecam
		oldCamTarget = camTarget
		camTarget = noone
	} else {
		// on disabling freecam
		reset_cam_target = 1 // go to old target
		zoom = 1
	} 
	show_debug_message("Freecam " + (freecam ? "enabled" : "disabled"))	
	
	//	if (instance_exists(obj_camera) && obj_camera.freecam) && global.freecam_highlight_mobs
	//		colour = global.freecam_highlight_color
}

if freecam {
	// draw crosshair in the middle of the screen
	var _x = (vx + ((zoom * 1280) / 2))
	var _y = (vy + ((zoom * 720) / 2))
	draw_sprite_ext(spr_crosshair, 0, _x, _y, (2 * zoom), (2 * zoom), 0, c_white, 1)
	
	if camTarget {camTarget = noone} // only switch it if it isnt noone ig
	var move_speed = (keyboard_check(vk_shift) ? 24 : 12)

	// listen for movement
	if keyboard_check(vk_left) && !global.disable_game_keyboard_input {
		x -= move_speed * zoom
	}
	if keyboard_check(vk_right) && !global.disable_game_keyboard_input {
		x += move_speed	* zoom
	}
	if keyboard_check(vk_up) && !global.disable_game_keyboard_input {
		y -= move_speed * zoom
	}
	if keyboard_check(vk_down) && !global.disable_game_keyboard_input {
		y += move_speed * zoom
	}
	
	// keep camera within room bounds
	if (x < ((1280 * zoom) / 2))
		x = ((1280 * zoom) / 2)
	if ((x + ((1280 * zoom) / 2)) > room_width)
		x = (room_width - ((1280 * zoom) / 2))
	if (y < ((720 * zoom) / 2))
		y = ((720 * zoom) / 2)
	if ((((y + (720 * zoom) / 2)) > room_height))
		y = (room_height - ((720 * zoom) / 2))
	
	if keyboard_check_pressed(ord("R")) && !global.disable_game_keyboard_input
	{
		show_debug_message("reset zoom")
		zoom = 1
	}
	if keyboard_check(vk_subtract) && !global.disable_game_keyboard_input // zoom out
	{
		show_debug_message("zooming out")
		zoom += (zoom * 0.1)
	}
	if keyboard_check(vk_add) && !global.disable_game_keyboard_input // zoom in
	{
		show_debug_message("zooming in")
		zoom -= (zoom * 0.1)
	}
	
	// handle zooming limits
	if zoom > max_zoom
		zoom = max_zoom
	if zoom < min_zoom
		zoom = min_zoom
}

if instance_exists(p)
{
	// reset the cam to the last/old cam target
	if (reset_cam_target) {
		camTarget = (oldCamTarget ? oldCamTarget : noone);
		reset_cam_target = 0
	}
	
    camera_set_view_size(view_camera[0], (1280 - ((320 * camZoom) / 100)), (720 - ((180 * camZoom) / 100)))
    if (!global.dialog_mode)
    {
        //if (keyboard_check(vk_tab) && (p.nearestMob != noone))
		//{
		//	draw_ui_mob_spectate_list()
        //    camTarget = p.nearestMob
		//}
        //else
		//{
        //    camTarget = noone
		//}
		
		//if (keyboard_check(vk_tab))
		//{
		//	if (p.nearestMob != noone)
		//		camTarget = p.nearestMob
				
		//	draw_ui_mob_spectate_list()
		//}
		//else
		//	camTarget = noone
	}
    if ((global.transition != 2)) && !freecam
    {
        if ((camTarget != noone) && instance_exists(camTarget))
        {
            x -= adjust_to_fps((x - camTarget.x) / 10)
            y -= adjust_to_fps(((y - (560 + (720 * floor((camTarget.y / 720))))) + 200) / 10)
        }
        else
        {
            if (p.hiding || (global.hscene_target != -4))
                x -= adjust_to_fps((x - p.x) / 10)
            else
                x -= adjust_to_fps((x - (p.x + (p.dir * 100))) / 10)
            y = (p.y - 200)
        }
    }
    if ((p.timeStop > 0))
    {
        draw_set_alpha(0.2)
        draw_set_color(make_color_rgb(255, 130, 0))
        draw_rectangle(vx, vy, (vx + 1280), (vy + 720), false)
    }
    if surface_exists(surf) && !freecam && !global.camera_hide_ui
    {
        surface_set_target(surf)
        draw_set_color(c_black)
        draw_set_alpha((global.cowardOn ? 0.6 : 0.96))
        draw_rectangle(0, 0, 1280, 720, false)
        draw_set_alpha(1)
        draw_set_color(c_white)
        gpu_set_blendmode(bm_subtract)
		
		// draw other network pkun stuff
		with (obj_network_object) {
			if (network_obj_type == "player") {
				// draw glow when flashlight is on
				if (flashOn[1] && (!hiding))
					draw_sprite_ext_safe(spr_light_2_w, 0, ((x - vx) - (dir * -650)), ((y - vy) - 200), 1, 1, 0, c_white, 0.6)
		        else
		            draw_sprite_ext_safe(spr_light_1, 0, (x - vx), ((y - vy) - 200), 1, 1, 0, c_white, 0.5)
			}
		}
		
        if global.hscene_target
            draw_sprite_ext_safe(spr_light_1, 0, (p.x - vx), ((p.y - vy) - 200), 2, 1, 0, c_white, 0.5)
        else if instance_exists(obj_police)
            draw_sprite_ext_safe(spr_light_1, 0, (obj_police.x - vx), ((obj_police.y - vy) - 300), 2, 1, 0, c_white, 1)
        if (!global.hscene_hide_fl)
        {
            if (global.flashOn && (!p.hiding))
                draw_sprite_ext_safe(spr_light_2_w, 0, ((p.x - vx) - (p.dir * -650)), ((p.y - vy) - 200), 1, 1, 0, c_white, 0.6)
            else
                draw_sprite_ext_safe(spr_light_1, 0, (p.x - vx), ((p.y - vy) - 200), 1, 1, 0, c_white, 0.5)
        }
        gpu_set_blendmode(bm_normal)
        surface_reset_target()
        draw_surface(surf, vx, vy)
        draw_set_alpha(1)
        draw_set_color(c_white)
    }
    else
        surf = surface_create(1280, 720)
    if (global.flashOn && (!global.hscene_hide_fl) && (!p.hiding))
    {
        if global.dialog_acting
        {
            if (!shotaActor)
                shotaActor = dialog_find_actor("shota")
            else
                draw_flashlight(shotaActor)
        }
        else
        {
            draw_flashlight(p)
            shotaActor = noone
        }
    }
//	if global.enable_ui_cutter
//		draw_sprite_ext_safe(spr_ui_cutter, 0, vx, (vy - ((90 * camZoom) / 100)), 1, 1, 0, c_white, 1)
    if (!game_is_paused()) && !global.camera_hide_ui
    {
        if ((room == rm_game))
        {
			with (obj_network_object) {
				if (network_obj_type == "player") {
					// draw hearts
					var heart_scale = 0.5
					var spr_width = sprite_get_width(spr_ui_heart) * heart_scale
					var heart_padding = 30
					var _ui_alp = 1
//					var c_g = make_color_rgb(36, 36, 36)
//					var c_p = make_color_hsv(225, (130 + (20 * global.shaderOn)), 255)
					var start_x_offset = ((lifeMax * spr_width) + (lifeMax - 1 * heart_padding)) / 2
					var _vx = x - start_x_offset
					var _vy = y - (sprite_height - 20)
		
					for (var l = 0; l < lifeMax; l++)
				    {
				        draw_sprite_ext_safe(spr_ui_heart_mid, (l % 2), ((_vx) + (heart_padding * l)), (_vy), heart_scale, heart_scale, 0, c_g, _ui_alp)
				        if ((l < lifeCur))
				        {
				            draw_sprite_ext_safe(spr_ui_heart_mid, (l % 2), ((_vx) + (heart_padding * l)), (_vy), heart_scale, heart_scale, 0, c_p, _ui_alp)
				            //draw_sprite_part_ext(spr_ui_heart, (l % 2), _vx - (spr_width / 2), _vy - (spr_width / 2), spr_width, max(0, ((0.8125 * spr_width) - (((0.8125 * spr_width) * global.charmed) / 100))), ((((_vx) + (heart_padding * l)) - (spr_width / 2)) + 4), (((_vy) - (spr_width / 2)) + 6), heart_scale, heart_scale, c_white, _ui_alp)
							draw_sprite_part_ext(spr_ui_heart, (l % 2), 4, 6, (spr_width * 2), max(0, (2 * ((52 * heart_scale) - (((52 * heart_scale) * global.charmed) / 100)))), ((((_vx) + (heart_padding * l)) - (spr_width / 2)) + (4 * heart_scale)), (((_vy) - (spr_width / 2)) + (6 * heart_scale)), heart_scale, heart_scale, c_white, _ui_alp)
							//draw_sprite_part_ext(spr_ui_heart, (l % 2), 4, 6, 64, max(0, (52 - ((52 * global.charmed) / 100))), ((((vx + 40) + (64 * l)) - 32) + 4), (((vy + 664) - 32) + 6), 1, 1, c_white, ui_alp)
						}
				        else if ((l == lifeCur) && (lifeloss_t > 0))
				        {
				            draw_sprite_ext_safe(spr_ui_heart_mid, (l % 2), ((_vx) + (heart_padding * l)), (_vy), (2 - (lifeloss_t / 60)) * heart_scale, (2 - (lifeloss_t / 60)) * heart_scale, 0, c_white, (lifeloss_t / 60) * _ui_alp)
				            lifeloss_t -= (lifeloss_t / 10)
				        }
					}
					
					//// draw nametag
					//if (nametag != "") {
					//	var tx = x;
					//	var ty = y;

					//	var sh = string_height(nametag);
					//	var sw = string_width(nametag);
					//	var txtpad = 4;
					//	var y_offset = -20;

					//	gpu_set_blendmode(bm_normal);
					//	draw_set_alpha(0.5);
					//	draw_set_color(c_black);
					//	draw_set_font(fnt_minecraft);

					//	var x1 = ((tx - (sw / 2)) - txtpad);
					//	var x2 = (x1 + (2 * txtpad) + sw);
					//	var y1 = (((ty - sprite_height) + y_offset) - txtpad);
					//	var y2 = (y1 + (2 * txtpad) + sh);
					//	draw_rectangle(x1, y1, x2, y2, 0);

					//	draw_set_alpha(1);
					//	draw_set_color(c_white);
					//	draw_text((tx - (sw / 2)), ((ty - sprite_height) + y_offset), nametag);	
					//}
				}
			}
            if elps_m
            {
                if ((elps_s < 2))
                    elps_s += 0.02
                else
                    elps_m = 1
            }
            else if ((elps_s > 1))
                elps_s -= 0.02
            else
                elps_m = 0
            draw_sprite_ext_safe(spr_ui_gradelipse, 0, (vx + 640), (vy + 360), elps_s, elps_s, 0, c_p, min(0.7, (global.charmed / 100)))
            draw_ui_clock((vx + 2), (vy + 2), 1)
            draw_set_align(fa_right, fa_top)
            draw_set_color(c_white)
            setFont("A", 21)
            draw_text((vx + 1274), (vy + 6), pkun_get_location(1))
            draw_sprite_ext(spr_ui_itemslot_frm, 0, (vx + 1078), (vy + 612), 1, 1, 0, c_white, ui_alp)
            if ((global.itemSwap > 0))
                global.itemSwap -= (global.itemSwap / 5)
            else
                global.itemSwap = 0
            if ((obj_sys.itemDescA > 0) && obj_sys.itemDescI)
            {
                obj_sys.itemDescA--
                draw_set_alpha((obj_sys.itemDescA / 60) * ui_alp)
                draw_set_align(fa_right, fa_bottom)
                draw_set_color(c_white)
                setFont("B", 16)
                draw_text(((vx + 1280) - 210), ((vy + 720) - 8), getText(("idesc_" + string(obj_sys.itemDescI))))
            }
            draw_set_alpha(ui_alp)
            if ((obj_sys.itemScale[0] < 100))
                obj_sys.itemScale[0] += adjust_to_fps((100 - obj_sys.itemScale[0]) / 5)
            else
                obj_sys.itemScale[0] = 100
            if ((obj_sys.itemScale[1] < 100))
                obj_sys.itemScale[1] += adjust_to_fps((100 - obj_sys.itemScale[1]) / 5)
            else
                obj_sys.itemScale[1] = 100
            draw_sprite_ext_safe(spr_ui_itemslot, 0, (((vx + 1078) + 167) - ((83 * global.itemSwap) / 100)), (((vy + 612) + 73) - ((25 * global.itemSwap) / 100)), (1 + (global.itemSwap / 100)), (1 + (global.itemSwap / 100)), 0, c_white, 0.5 * ui_alp)
            draw_sprite_ext_safe(spr_item, global.itemSlot[1], (((vx + 1078) + 167) - ((83 * global.itemSwap) / 100)), (((vy + 612) + 73) - ((25 * global.itemSwap) / 100)), ((obj_sys.itemScale[1] / 100) + (global.itemSwap / 100)), ((obj_sys.itemScale[1] / 100) + (global.itemSwap / 100)), 0, c_white, 0.5 * ui_alp)
            draw_sprite_ext_safe(spr_ui_itemslot, 0, (((vx + 1078) + 84) + ((83 * global.itemSwap) / 100)), (((vy + 612) + 48) + ((25 * global.itemSwap) / 100)), (2 - (global.itemSwap / 100)), (2 - (global.itemSwap / 100)), 0, c_white, 1)
            draw_sprite_ext_safe(spr_item, global.itemSlot[0], (((vx + 1078) + 84) + ((83 * global.itemSwap) / 100)), (((vy + 612) + 48) + ((25 * global.itemSwap) / 100)), ((2 * (obj_sys.itemScale[0] / 100)) - (global.itemSwap / 100)), ((2 * (obj_sys.itemScale[0] / 100)) - (global.itemSwap / 100)), 0, c_white, ui_alp)
            draw_sprite_ext_safe(spr_ui_stamina, 0, (vx + 10), (vy + 700), 1, 1, 0, c_g, 1)
            if p.exhaust
                draw_sprite_part_ext(spr_ui_stamina, 0, 0, 0, (324 * (p.stamina / 100)), 12, (vx + 10), (vy + 700), 1, 1, c_r, ui_alp)
            else
                draw_sprite_part_ext(spr_ui_stamina, 0, 0, 0, (324 * (p.stamina / 100)), 12, (vx + 10), (vy + 700), 1, 1, c_white, ui_alp)
            var col = ((p.hiding || (!global.flashOn) || (!global.flashPow)) ? c_g : c_white)
            if ((global.flashPow > 0))
                draw_sprite_ext_safe(spr_ui_battery, ceil((global.flashPow / 20)), (vx + 12), (vy + 598), 1, 1, 0, col, ui_alp)
            else
                draw_sprite_ext_safe(spr_ui_battery, 0, (vx + 12), (vy + 598), 1, 1, 0, col, ui_alp)
        }
        draw_set_alpha(ui_alp)
        if ((p.intrTarget != noone))
        {
            draw_set_align(fa_center, fa_middle)
            draw_set_color(c_white)
            setFont("B", 16)
            if ((p.intrDone == 0))
                draw_sprite(spr_ui_intr, p.intrTarget.icon, p.intrTarget.xx, p.intrTarget.yy)
            else
            {
                draw_text_blur(p.intrTarget.xx, p.intrTarget.yy, (string_format(((p.intrNeed - p.intrDone) / 60), 0, 1) + "s"))
                draw_pie_bar(p.intrTarget.xx, p.intrTarget.yy, 1, 1, c_white, 35, 1, 6)
                draw_pie_bar(p.intrTarget.xx, p.intrTarget.yy, (p.intrNeed - p.intrDone), p.intrNeed, c_black, 35, 1, 6)
            }
            draw_text_blur((vx + 640), (vy + 410), ("(Z)" + intr_get_text(p.intrTarget)))
        }
        if ((p.miniMsgTmr > 0))
        {
            p.miniMsgTmr-= adjust_to_fps(1)
            draw_set_align(fa_center, fa_middle)
            setFont("B", 16)
            draw_text_blur(p.x, (p.y - 400), p.miniMsgStr)
        }
    }
    if ((room == rm_game) && (!((global.menu_mode || global.dialog_mode || global.setting_mode || global.transition))))
    {
        for (var l = 0; l < global.lifeMax; l++)
        {
            draw_sprite_ext_safe(spr_ui_heart_mid, (l % 2), ((vx + 40) + (64 * l)), (vy + 664), 1, 1, 0, c_g, ui_alp)
            if ((l < global.lifeCur))
            {
                draw_sprite_ext_safe(spr_ui_heart_mid, (l % 2), ((vx + 40) + (64 * l)), (vy + 664), 1, 1, 0, c_p, ui_alp)
                draw_sprite_part_ext(spr_ui_heart, (l % 2), 4, 6, 64, max(0, (52 - ((52 * global.charmed) / 100))), ((((vx + 40) + (64 * l)) - 32) + 4), (((vy + 664) - 32) + 6), 1, 1, c_white, ui_alp)
            }
            else if ((l == global.lifeCur) && (lifeloss_t > 0))
            {
                draw_sprite_ext_safe(spr_ui_heart_mid, (l % 2), ((vx + 40) + (64 * l)), (vy + 664), (2 - (lifeloss_t / 60)), (2 - (lifeloss_t / 60)), 0, c_white, (lifeloss_t / 60) * ui_alp)
                lifeloss_t -= (lifeloss_t / 10)
            }
        }
    }
}
else
{
    if surface_exists(surf)
    {
        surface_reset_target()
        surface_free(surf)
    }
	if surface_exists(no_surf)
    {
        surface_reset_target()
        surface_free(no_surf)
    }
    instance_destroy()
}

var cam = view_camera[0];
camera_set_view_pos(cam, 
    x - (camera_get_view_width(cam)/2), 
    y - (camera_get_view_height(cam)/2)
);

//show_debug_message("Camera position: " + string(x) + ", " + string(y));
//show_debug_message("Player position: " + string(obj_pkun.x) + ", " + string(obj_pkun.y));