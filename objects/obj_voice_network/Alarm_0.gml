if (!global.transcript_connected) {
    var result = network_connect_raw_async(global.transcript_socket, global.transcript_server_ip, global.transcript_server_port);
    if (result >= 0) {
        show_debug_message("obj_voice_network: Attempting raw connection to the server...");
    } else {
        show_debug_message("obj_voice_network: Failed to initiate raw connection. Retrying...");
        alarm[0] = retry_time_steps; // Retry after delay
    }
}
