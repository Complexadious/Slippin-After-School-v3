/// @description Insert description here
// You can write your code in this editor
if (obj_multiplayer.player_id == -1) {
    show_message("Connection timed out. Could not reach server.");
    network_destroy(obj_multiplayer.client_socket);
    obj_multiplayer.client_socket = -1;
}
