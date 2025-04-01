var _entities = struct_get_names(network.entities)
for (var i = 0; i < array_length(_entities); i++) {
	// go through every entity, if x or y or dir or dx changed, send
	var _entity = network.entities[$ _entities[i]]
	
	if !struct_exists(_entity, "instance")
		continue;
	
	with (_entity.instance) {
		var _ls = last_synced
		var _l = last
		var cdx = (x - _l.x) // calculated dx
		
		if ((y == _ls.y) && (cdx == _ls.dx) && (dir == _ls.dir)) {
			if (_ls.pos_check) {
//				_log(object_get_name(object_index) + ": SKIP UPDATE")
				continue;
			} else {
				other._log(object_get_name(object_index) + ": lsdx=" + string(_ls.dx) + " cal_dx=" + string(cdx) + " ldx = " + string(_l.dx))
				other._log(object_get_name(object_index) + ": POS DIDNT CHANGE! SEND LAST SHIT!")
				_ls.pos_check = 1
			}
		} else {
			// position changed
			_ls.pos_check = 0
			other._log(object_get_name(object_index) + ": lsdx=" + string(_ls.dx) + " cal_dx=" + string(cdx) + " ldx = " + string(_l.dx))
			other._log(object_get_name(object_index) + ": POS CHANGED! SEND SHIT!")
		}
		
		_ls.x = x
		_ls.dx = cdx //dx
		_ls.y = y
		_ls.dir = dir
	}
}