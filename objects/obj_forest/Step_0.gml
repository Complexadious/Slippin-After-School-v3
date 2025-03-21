/// Modify obj_forest Step Event
var vx = camera_get_view_x(view_camera[0]);

// Get tile information
var tree_tile_element = fg_id
var tree_tile_sprite = layer_background_get_sprite(tree_tile_element);
var tree_tile_w = sprite_get_width(tree_tile_sprite);
var tree_tile_scale = layer_background_get_xscale(tree_tile_element);

//if keyboard_check_pressed(ord("Y")) && (room == rm_forest) {
//	randomize_note_position();
//    //// Increment counter
//    //tile_test_counter++;
    
//    //// Calculate position for this tile
//    //var tile_x = tile_test_counter * (tree_tile_w * tree_tile_scale);
    
//    //// Move player to tile position
//    //if instance_exists(obj_pkun) {
//    //    obj_pkun.x = tile_x;
//    //}
    
//    //// Debug info
//    //show_debug_message("Tile " + string(tile_test_counter) + 
//    //                  " Position: " + string(tile_x) + 
//    //                  " (Tile Width: " + string(tree_tile_w) + 
//    //                  ", Scale: " + string(tree_tile_scale) + ")");
//}

if global.forest_raining {
    var rain = instance_create_depth(random(vx + 1280), -50, 0, obj_efct_rain);
    rain.rot = -30;
}

if (instance_exists(obj_pkun)) {
    layer_x(front_layer, lerp(0, vx, front_speed));
    layer_x(bg_layer, lerp(0, vx, bg_speed));
    layer_x(mg_1_layer, lerp(0, vx, mg_1_speed));
    layer_x(mg_2_layer, lerp(0, vx, mg_2_speed));
    layer_x(mg_3_layer, lerp(0, vx, mg_3_speed));
}