/// @description Update timers and such
// You can write your code in this editor

// decrease timers if exist
var loc = network.timers
var _tmrs = struct_get_names(loc)
for (var _i = array_length(_tmrs) - 1; _i >= 0; _i--) {
	var _t = loc[$ _tmrs[_i]]
	_t.curr -= _t.decrease_amt
	if (_t.curr <= 0) {
		if (_t.func != undefined) script_execute_ext(_t.func[0], _t.func[1])
		if (_t.loop) {
			_t.curr = _t.duration
			exit;
		}
		if _t.remove_on_expiration
			struct_remove(loc, _tmrs[_i]) // remove from paths
	}
}


if (loc[$ "MULTIPLAYER_LOG_TMR"].curr == 1) {
	var __msg = "General Info"
	if check_is_server() {
		__msg+= "\n	- Clients = " + string(struct_get_names(server.clients))
		__msg+= "\n	- Entities = " + string(struct_get_names(network.entities))
		__msg+= "\n	- PPS = " + string(network.statistics.pps)
	} else {
		__msg+= "\n	- Players = " + string(struct_get_names(network.players))
		__msg+= "\n	- Entities = " + string(struct_get_names(network.entities))
		__msg+= "\n	- PPS = " + string(network.statistics.pps)
	}
	__msg += "\n - TIMERS: " + string(network.timers)
	_log(__msg)	

}