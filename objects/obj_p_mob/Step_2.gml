//event_inherited()

// if position is different after step, update everything.
if (bstep_pos != [x, y, dir, state]) {
	_cb_sync_mob()
	
	var msg = "OBJ_P_MOB: (" + string(object_get_name(object_index)) + ") Position changed!"
	if (bstep_pos[0] != x)
		msg += "\n-X pos changed"
	else
		msg += "\n-X pos is same"
	if (bstep_pos[1] != y)
		msg += "\n-Y pos changed"
	else
		msg += "\n-Y pos is same"
	if (bstep_pos[2] != dir)
		msg += "\n-DIR changed"
	else
		msg += "\n-DIR pos is same"
	if (bstep_pos[3] != state)
		msg += "\n-STATE changed"
	else
		msg += "\n-STATE is same"
	msg+= "\nPackets sent due to this mob: " + string(_pcnt)
	
	if check_is_server() show_debug_message(msg)
}