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
		__msg+= "\n	- PACKET_QUEUE = " + string(network.packet_queue)
	} else {
		__msg+= "\n	- Players = " + string(struct_get_names(network.players))
		__msg+= "\n	- Entities = " + string(struct_get_names(network.entities))
		__msg+= "\n	- PPS = " + string(network.statistics.pps)
		__msg+= "\n	- PACKET_QUEUE = " + string(network.packet_queue)
	}
	__msg += "\n - TIMERS: " + string(network.timers)
	_log(__msg)	
}

if (struct_names_count(network.packet_queue) > 0)
	_log("PACKET_QUEUE!! " + string(network.packet_queue))
	
// send all packets to their destination
var _waiting_socks = struct_get_names(network.packet_queue)
for (var i = 0; i < array_length(_waiting_socks); i++) {
	var _sock = _waiting_socks[i]
	var _packetbuffs = network.packet_queue[$ _sock]
	_log("Sending '" + string(array_length(_packetbuffs)) + "' packets to sock '" + string(_sock) + "'")
	var _combined = packet_buffer_combine(_packetbuffs)
	multiplayer_send_packet(_sock, _combined)
	struct_remove(network.packet_queue, _sock)
	
	buffer_delete(_combined)
}