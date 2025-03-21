/// @description Insert description here
// You can write your code in this editor
time_since_last_ping += adjust_to_fps(1)

if (time_since_last_ping > timeout_time) {
	show_debug_message("obj_voice_network: Timeout time exceeded. Attempting reconnect...")
	alarm[0] = retry_time_steps
	time_since_last_ping = 0
}

if (global.current_volume > global.speech_detection_sensitivity) global.speaking = 1 else global.speaking = 0