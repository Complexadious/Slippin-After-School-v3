///// @description Insert description here
//// You can write your code in this editor
//var _target_same = (struct_get(__cache, "hscene_target") == global.hscene_target)
//var _hide_fl_same = (struct_get(__cache, "hscene_hide_fl") == global.hscene_hide_fl)
//var _stp_same = (struct_get(__cache, "hs_stp") == hs_stp)
//var _mob_id_same = (struct_get(__cache, "hs_mob_id") == hs_mob_id)

//if !((_target_same) && (_stp_same) && (_mob_id_same)) {
//	show_debug_message("HSCENE IS DIFFERENT!!!")
//	var _msg = ""
	
//	if _target_same
//		_msg += "\nHscene Target [" + string(struct_get(__cache, "hscene_target")) + "->" + string(global.hscene_target) + "] Changed: " + string(_target_same)
//	if _hide_fl_same
//		_msg += "\Hide FL [" + string(struct_get(__cache, "hscene_hide_fl")) + "->" + string(global.hscene_hide_fl) + "] Changed: " + string(_hide_fl_same)
//	if _stp_same
//		_msg += "\nHscene Step [" + string(struct_get(__cache, "hs_stp")) + "->" + string(hs_stp) + "] Changed: " + string(_stp_same)
//	if _mob_id_same
//		_msg += "\Mob ID [" + string(struct_get(__cache, "hs_mob_id")) + "->" + string(hs_mob_id) + "] Changed: " + string(_mob_id_same)
	
//	if check_is_server() {
//		show_debug_message("HSCENE IS DIFFERENT!!! SENDING SERVER TO CLIENT PACKET")
//		do_packet(new PLAY_CB_SET_HSCENE(obj_multiplayer.server.player.entity_uuid, hs_mob_id, hs_hide_fl, hs_stp), struct_get_names(obj_multiplayer.server.clients))
//	} else if is_multiplayer() {
//		show_debug_message("HSCENE IS DIFFERENT!!! SENDING CLIENT TO SERVER PACKET")
//		do_packet(new PLAY_SB_SET_HSCENE(-1, hs_mob_id, hs_hide_fl, hs_stp), obj_multiplayer.network.server.connection)
//	}
//	show_debug_message("HSCENE DIFFERENCE: " + string(_msg))
//}

///*
//struct_get(__cache, "hscene_hide_fl", global.hscene_hide_fl)
//struct_get(__cache, "hs_stp", hs_stp)
//struct_get(__cache, "hs_mob_id", hs_mob_id)
//*/