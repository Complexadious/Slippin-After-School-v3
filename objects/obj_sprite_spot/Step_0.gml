/// obj_sprite_spot Step Event
if (follow_layer && target_layer != -4) {
    // Get layer position
    var layer_x_pos = layer_get_x(target_layer);
    var layer_y_pos = layer_get_y(target_layer);
    
    // Update position based on layer
    x = start_x + layer_x_pos + layer_offset_x;
    y = start_y + layer_y_pos + layer_offset_y;
    
    // Match layer depth
//    var _layer_depth = layer_get_depth(target_layer);
//    depth = _layer_depth + 1;  // +1 to ensure it's just in front of the layer
}