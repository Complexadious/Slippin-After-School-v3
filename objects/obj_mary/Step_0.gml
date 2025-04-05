//event_inherited()

if ((!game_is_paused()) && (!global.timeStop))
{
    if ((wait > 0))
        wait-= adjust_to_fps(1)
    else
    {
        if ((flr != 0)) && !obj_pkun.noclip
        {
            if ((loc == location_get_name((obj_pkun.y <= 2100), obj_pkun.np.port, 1))) && !obj_pkun.immortal
            {
                play_se(se_catch, 1)
                global.hscene_target = self; if check_is_server() sync_hscene_event();
                global.trans_alp = 1
            }
        }
        if ((timer > 0))
            timer-= adjust_to_fps(1)
        else
        {
            obj_sys.mini_dialog_timer = 300
            if ((lifespan > 0))
            {
                if ((lifespan == 1)) && (is_multiplayer() && check_is_server()) || (!is_multiplayer())
                {
                    flr = ((floor((obj_pkun.y / 720)) % 3) + 1)
                    rm = (obj_pkun.np.port % 10)
                    in = (obj_pkun.y >= 2100)
                }
                else
                {
                    flr = choose(1, 2, 3)
                    rm = irandom_range(0, 9)
                    in = choose(1, 0)
                }
                lifespan-= adjust_to_fps(1)
                timer = irandom_range(500, 700)
                wait = 120
                loc = location_get_name((!in), ((flr * 10) + rm), 1)
                if ((global.language == (0)))
                    global.mini_dialog_line = ((((getText("mary_front") + "「$ffff00") + loc) + "$ffffff」") + getText("mary_back"))
                else
                    global.mini_dialog_line = ((((getText("mary_front") + "'$ffff00") + loc) + "$ffffff'") + getText("mary_back"))
				if (is_multiplayer() && check_is_server())
					do_packet(new PLAY_CB_SET_MARY_LOCATION(loc, timer, wait, lifespan), struct_get_names(obj_multiplayer.server.clients))
			}
            else
            {
                loc = ""
                global.mini_dialog_line = getText("mary_away")
                instance_destroy()
            }
        }
    }
}
else
    image_speed = 0
