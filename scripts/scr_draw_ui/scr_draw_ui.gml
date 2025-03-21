function draw_ui_mob_spectate_list()
{
	var vx = instance_exists(obj_camera) ? global.obj_cam_vx : camera_get_view_x(view_camera[0])
	var vy = instance_exists(obj_camera) ? global.obj_cam_vy : camera_get_view_y(view_camera[0])
	var _prefix = "scr_draw_ui: (draw_ui_mob_spectate_list) "
	var _mobs = []
	
	// settings
	var mob_frame_width = 100
	var mob_frame_height = 100
	var mob_frame_padding = 10
	
	// add pkun as an option
	array_push(_mobs, obj_pkun.object_index)
	array_push(_mobs, obj_network_object.object_index)
	
	// add all mob instances to the _mobs list with icons in _icons
	with (obj_p_mob) {
		array_push(_mobs, object_index)
	}
	
	var mob_frames_count = array_length(_mobs)
	
	// wrapping
	if global.ui_spectate_list_index >= mob_frames_count
		global.ui_spectate_list_index = 0
	if global.ui_spectate_list_index < 0
		global.ui_spectate_list_index = (mob_frames_count - 1)
	
//	show_debug_message(_prefix + string(_mobs))
	
	//render boxes and stuff
	for (var i = 0; i < mob_frames_count; i++) {
		var sprite = _mobs[i].sprite_index
		var img_index = _mobs[i].image_index
		var alpha = variable_instance_exists(_mobs[i].id, "alp") ? _mobs[i].alp : 1
		var setback = -(mob_frames_count / 2) * (mob_frame_width + mob_frame_padding)
		var _x = ((vx + 640) + (i * (mob_frame_width + mob_frame_padding)) + setback)
		var _y = (vy + (360 - mob_frame_height))
		
		draw_sprite_stretched_ext(spr_ui_dialog_box, 0, _x, _y, mob_frame_width, mob_frame_height, c_white, 1)
		draw_sprite_stretched_ext(sprite, img_index, _x, _y, mob_frame_width, mob_frame_height, c_white, 1)
		
		// draw arrow above selected thing
		if (i == global.ui_spectate_list_index) {
			draw_sprite_ext(spr_ui_dialog_arr, image_index, _x + (mob_frame_width / 2), _y - 10, 1, 1, 0, c_white, 1)
			obj_camera.camTarget = (_mobs[i] == obj_pkun) ? noone : _mobs[i]
		}
	}
}

function draw_ui_memolist() //gml_Script_draw_ui_memolist
{
    var vx = camera_get_view_x(view_camera[0])
    var vy = camera_get_view_y(view_camera[0])
    var spr = -4
    var scl = 0
    var str = ""
    if ((memo_move > 0))
        memo_move -= adjust_to_fps(memo_move / 5)
    else
        memo_move = 0
    scl = (memo_move / 100)
    draw_set_alpha(1)
    draw_set_align(fa_center, fa_middle)
    setFont("B", 21)
    draw_set_color(c_white)
    draw_text((vx + 640), (vy + 560), (string((memo_ind_curr + 1)) + " / 10"))
    for (var i = 0; i < 5; i++)
    {
        if ((((memo_ind_curr + i) - 2) >= 0) && (((memo_ind_curr + i) - 2) <= 9))
        {
            spr = asset_get_index(("spr_memo_" + string(((((memo_ind_curr + i) + 2) % 4) + 1))))
            draw_sprite_ext(spr, 0, (((vx - 560) + (600 * i)) + ((600 * memo_dir) * scl)), (vy + 360), 1, 1, 0, c_white, 1)
            draw_sprite_ext(spr, 0, (((vx - 560) + (600 * i)) + ((600 * memo_dir) * scl)), (vy + 360), 1, 1, 0, c_black, (global.shaderOn ? 0.3 : 0))
            draw_set_align(fa_center, fa_middle)
            draw_sprite(spr_ui_setting_arrow, 0, (vx + 640), (vy + 550))
            setFont("C", 21)
            draw_set_color(make_color_rgb(50, 50, 50))
            str = (global.memoRead[((memo_ind_curr + i) - 2)] ? getText(("memo_" + string(((memo_ind_curr + i) - 1)))) : "???")
            ctext_draw_mid((((vx - 560) + (600 * i)) + ((600 * memo_dir) * scl)), (vy + 360), str, ctext_length(str))
        }
    }
    if ((global.key_delay > 0))
        global.key_delay-= adjust_to_fps(1)
    else if keyboard_check(vk_left)
    {
        if ((memo_ind_curr > 0))
        {
            global.key_delay = 20
            play_se(se_select, 1)
            memo_ind_curr--
            memo_move = 100
            memo_dir = -1
        }
    }
    else if keyboard_check(vk_right)
    {
        if ((memo_ind_curr < 9))
        {
            global.key_delay = 20
            play_se(se_select, 1)
            memo_ind_curr++
            memo_move = 100
            memo_dir = 1
        }
    }
    else if keyboard_check_pressed(vk_backspace)
    {
        play_se(se_select, 1)
        global.menu_mode = 0
        memo_move = 0
    }
}

function draw_ui_map() //gml_Script_draw_ui_map
{
    var vx = camera_get_view_x(view_camera[0])
    var vy = camera_get_view_y(view_camera[0])
    var flr = ((floor((obj_pkun.y / 720)) % 3) + 1)
    var ix = 150
    var iy = 240
    draw_sprite(spr_ui_map, 0, vx, vy)
    setFont("B", 16)
    draw_set_align(fa_center, fa_middle)
    draw_set_color(c_white)
    draw_text((vx + 640), (vy + 640), ("(X)" + getText("sett_back")))
    draw_text((vx + 304), (vy + 314), ("3-A" + getText("map_class")))
    draw_text((vx + 432), (vy + 314), ("3-B" + getText("map_class")))
    draw_text((vx + 554), (vy + 314), getText("map_toilet_m"))
    draw_text((vx + 770), (vy + 314), getText("map_toilet_f"))
    draw_text((vx + 894), (vy + 314), ("3-C" + getText("map_class")))
    draw_text((vx + 1024), (vy + 314), getText("map_art"))
    draw_text((vx + 304), (vy + 430), ("2-A" + getText("map_class")))
    draw_text((vx + 432), (vy + 430), ("2-B" + getText("map_class")))
    draw_text((vx + 554), (vy + 430), getText("map_toilet_m"))
    draw_text((vx + 770), (vy + 430), getText("map_toilet_f"))
    draw_text((vx + 894), (vy + 430), ("2-C" + getText("map_class")))
    draw_text((vx + 1024), (vy + 430), getText("map_lab"))
    draw_text((vx + 304), (vy + 542), ("1-A" + getText("map_class")))
    draw_text((vx + 432), (vy + 542), ("1-B" + getText("map_class")))
    draw_text((vx + 554), (vy + 542), getText("map_toilet_m"))
    draw_text((vx + 770), (vy + 542), getText("map_toilet_f"))
    draw_text((vx + 894), (vy + 542), ("1-C" + getText("map_class")))
    draw_text((vx + 1024), (vy + 542), getText("map_staff"))
    iy = (240 + (114 * (3 - flr)))
    if ((obj_pkun.y < 2160))
        ix = (150 + (1030 * ((obj_pkun.x - 700) / 13950)))
    else if ((obj_pkun.y < 4320))
    {
        if ((obj_pkun.x < 3300))
            ix = 304
        else if ((obj_pkun.x < 6600))
            ix = 432
        else if ((obj_pkun.x < 9600))
            ix = 894
        else
            ix = 1024
    }
    else if ((obj_pkun.x < 2900))
        ix = 544
    else
        ix = 770
    draw_sprite(spr_ui_map_mark, 0, (vx + ix), (vy + iy))
}

function draw_ui_setting(_arg0, _arg1) {
    setFont("A", 21);
    draw_sprite(spr_ui_title_menu, 3, (_arg0 + 190), (_arg1 - 30));

    var max_lines = global.max_settings_lines_per_page;

    // Calculate start and end indices based on the current page
    if (global.settings_page == 0) {
        // Default settings
        for (var i = 0; i < 9; i++) {
            var sett_k = "";
            var sett_v = "";

            if (i == 0) {
                sett_k = getText("sett_lang");
                sett_v = getText("key_lang");
            } else if (i == 1) {
                sett_k = getText("sett_se");
                sett_v = string(global.vol_se);
            } else if (i == 2) {
                sett_k = getText("sett_bgm");
                sett_v = string(global.vol_bgm);
            } else if (i == 3) {
                sett_k = getText("sett_fscr");
                sett_v = (window_get_fullscreen() ? "ON" : "OFF");
            } else if (i == 4) {
                sett_k = getText("sett_shdr");
                sett_v = (global.shaderOn ? "ON" : "OFF");
            } else if (i == 5) {
                sett_k = getText("sett_cwrd");
                sett_v = (global.cowardOn ? "ON" : "OFF");
            } else if (i == 6 && room != rm_title) {
                sett_k = (global.setting_ask ? getText("sett_ask") : getText("sett_title"));
                sett_v = "";
            } else if (i == 7) {
                sett_k = getText("sett_page", "Current Page");
                sett_v = string(global.settings_page) + "/" + string(global.max_settings_pages);
            } else if (i == 8) {
                sett_k = getText("sett_back");
                sett_v = "";
            }

            draw_setting(_arg0, _arg1, i, sett_k, sett_v, i == global.setting_ind);
        }
    } else {
        // Custom settings
        global.custom_settings_count = array_length(global.settings);
        global.settings_page_start_index = (global.settings_page - 1) * max_lines;
        global.settings_page_end_index = min(global.settings_page_start_index + max_lines, global.custom_settings_count);

        for (var i = global.settings_page_start_index; i < global.settings_page_end_index; i++) {
            var setting = global.settings[i];
            var sett_k = setting._options.sett_k;
            var sett_v = string(global[$ setting._global_var]);
			var ask = setting._options.askConfirm
			var changeInGame = setting._options.changeInGame

			var is_selected = (global.setting_ind + global.settings_page_start_index) == i
            // Handle value cases
            var sett_v_cases = setting._options.sett_v_cases;
            if (sett_v_cases != []) {
                for (var j = 0; j < array_length(sett_v_cases); j++) {
                    var _case = sett_v_cases[j];
                    if (real(sett_v) == _case[0]) { // Check if the case matches
                        sett_v = _case[1];
                        break;
                    }
                }
            }
			if (ask)
				sett_k = ((global.setting_ask && is_selected) ? getText("sett_ask") : sett_k)

			var disabled = (!changeInGame && !(room == rm_title))
            draw_setting(_arg0, _arg1, i - global.settings_page_start_index, sett_k, sett_v, is_selected, disabled);
		}

        // Render the page navigation and back buttons
        //draw_setting(_arg0, _arg1, max_lines - 2, getText("sett_page", "Current Page"), string(global.settings_page) + "/" + string(global.max_settings_pages), global.setting_ind == 7);
        //draw_setting(_arg0, _arg1, max_lines - 1, getText("sett_back"), "", global.setting_ind == 8);
		draw_setting(_arg0, _arg1, global.max_settings_lines_per_page + 1, getText("sett_page", "Current Page"), string(global.settings_page) + "/" + string(global.max_settings_pages), global.setting_ind == 7);
        draw_setting(_arg0, _arg1, global.max_settings_lines_per_page + 2, getText("sett_back"), "", global.setting_ind == 8);
    }
}

// Helper function for drawing settings
function draw_setting(_arg0, _arg1, index, sett_k, sett_v, is_selected, disabled = 0) {
    var y_offset = _arg1 + (40 * index);

    // Shadow
    draw_set_color(c_black);
    draw_set_alpha(0.4);
    draw_set_align(fa_left, fa_top);
    draw_text((_arg0 - 2), (y_offset - 2), sett_k);
    draw_text((_arg0 + 2), (y_offset - 2), sett_k);
    draw_text((_arg0 - 2), (y_offset + 2), sett_k);
    draw_text((_arg0 + 2), (y_offset + 2), sett_k);

    draw_set_align(fa_center, fa_top);
    draw_text(((_arg0 + 340) - 2), (y_offset - 2), sett_v);
    draw_text(((_arg0 + 340) + 2), (y_offset - 2), sett_v);
    draw_text(((_arg0 + 340) - 2), (y_offset + 2), sett_v);
    draw_text(((_arg0 + 340) + 2), (y_offset + 2), sett_v);

    // Actual text
    draw_set_alpha(1);
    if (is_selected) {
        draw_set_color(c_yellow);
    } else {
        draw_set_color(make_color_rgb(80, 80, 80));
    }

    draw_set_align(fa_left, fa_top);
    draw_text(_arg0, y_offset, sett_k);

	if (disabled && is_selected)
		draw_set_color(make_color_rgb(100, 0, 0))

    draw_set_align(fa_center, fa_top);
    draw_text((_arg0 + 340), y_offset, sett_v);

    if (is_selected) && (sett_v != "") {
        draw_sprite(spr_ui_setting_arrow, 0, (_arg0 + 340), (y_offset + 8));
    }
	
	if disabled
		draw_set_color(make_color_rgb(80, 80, 80))
}

function key_pressed() //gml_Script_key_pressed
{
    global.key_delay = 12
}

function draw_text_blur(_arg0, _arg1, _arg2) //gml_Script_draw_text_blur
{
    draw_set_color(c_black)
    draw_set_alpha(0.4)
    draw_text((_arg0 - 2), (_arg1 - 2), _arg2)
    draw_text((_arg0 + 2), (_arg1 - 2), _arg2)
    draw_text((_arg0 - 2), (_arg1 + 2), _arg2)
    draw_text((_arg0 + 2), (_arg1 + 2), _arg2)
    draw_set_color(c_white)
    draw_set_alpha(1)
    draw_text(_arg0, _arg1, _arg2)
}

function new_real(num) {
	var new_num = string(num)
	return real(new_num)	
}