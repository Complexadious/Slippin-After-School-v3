// ONLY voice shit
if (async_load[? "id"] != global.transcript_socket)
	exit;

var type = async_load[? "type"];

if (type == network_type_connect) {
    show_debug_message("obj_voice_network: Successfully connected to the server!");
    global.transcript_connected = true;
} else if (type == network_type_data) {
    var buffer = async_load[? "buffer"];
    buffer_seek(buffer, buffer_seek_start, 0);

    // Read the transcribed text as a string
    var text = buffer_read(buffer, buffer_string);
	if !(string_pos("p_", text))
	{
		show_debug_message("obj_voice_network: Received transcription: " + text);
		process_transcription(text)
	} else {
//		var volume_start = string_pos("//volume ", text) + string_length("//volume ");
//		var volume_str = string_copy(text, volume_start, string_length(text) - volume_start + 1);
	var string_to_remove = "p_";
	var _sl = string_length(string_to_remove);
	var volume_str = string_copy(text, _sl + 1, string_length(text) - _sl); // Corrected start position
	global.current_volume = real(volume_str);

//		show_debug_message("obj_voice_network: Got ping. Volume: " + string(global.current_volume) + ". Time since last ping was " + string(time_since_last_ping / 60) + " seconds ago.")
	}
	time_since_last_ping = 0

    // Process the transcribed text for actions (example)
} else if (type == network_type_disconnect) {
    show_debug_message("obj_voice_network: Server disconnected. Retrying...");
    global.transcript_connected = false;
    alarm[0] = retry_time_steps; // Retry connecting
}
