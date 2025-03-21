// Act

// Define custom actors once at game start
create_custom_actor("mike", {
    idle_sprite: spr_mike_idle,
    walk_sprite: spr_mike_walk,
    image_speed: 0.5,
    walk_sound: choose(se_step_b_1, se_step_b_2, se_step_b_3),
    sound_index: [0],
    sound_delay: 10,
    make_pkun_hide: 0
});

create_custom_actor("bush", {
    idle_sprite: spr_fortnite_bush,
    walk_sprite: spr_fortnite_bush,
    image_speed: 0,
    walk_sound: -4,
    sound_index: [0],
    sound_delay: 0,
    make_pkun_hide: 1,
    hide_se_in: se_h_cum_1,
    hide_se_out: se_h_deepfera_1,
    shake_amount_in: 15,
    shake_amount_out: 10,
    x_scale: 0.5,
    y_scale: 0.5,
    depth: -100
});

// Define an "exit" actor that makes Pkun exit
create_custom_actor("exit_trigger", {
    idle_sprite: -1,  // Invisible actor
    make_pkun_exit: 1,
    hide_se_out: se_h_deepfera_1,
    shake_amount_out: 10,
    depth: 0,
    destroy_on_exit: true
});


dialog_add_line("", "...")
dialog_add_act(new Act("shota", -4, obj_pkun.x, obj_pkun.y))
dialog_add_act(new Act("custom", -4, (obj_pkun.x + 150), obj_pkun.y, "mike"));
dialog_add_line(getText("shotakun"), "How much farther is it?")
dialog_add_line("Mike", "It's around 3 miles this way.")
dialog_add_line(getText("shotakun"), "...")
dialog_add_line(getText("shotakun"), "Couldn't we have drove?")
dialog_add_line("Mike", "Too risky. Keep walking.")
dialog_add_line("", " ")
dialog_add_act(new Act("shota", 4, obj_pkun.x + 550, 550))
dialog_add_act(new Act("custom", 4, obj_pkun.x + 750, 700, "mike"));
dialog_add_line("Mike", "Wait... Did you hear that?")
dialog_add_line("?", "*brap*")
dialog_add_line(getText("shotakun"), "What the fuck was that?")
dialog_add_line("Mike", "Oh no. It's them.")
dialog_add_line(getText("shotakun"), "Who??")
dialog_add_line("Mike", "Relax, I've seen this before. Now quickly, hide.")
dialog_add_line(getText("shotakun"), "Fine.")
dialog_add_line("", " ")
dialog_add_act(new Act("custom", -4, 1540, obj_pkun.y, "bush"));
dialog_add_line("Mike", "I'm over here strokin' my dick.")
dialog_add_act(new Act("shota", 0, -1, 0))
dialog_add_act(new Act("custom", -1, 0, 0, "bush"));

        //dialog_add_line(getText("shotakun"), getText("ch1_1"))
        //dialog_add_act(new Act("shota", -4, obj_pkun.x, obj_pkun.y))
        //dialog_add_act(new Act("item", -4, (obj_pkun.x + 900), obj_pkun.y))
        //dialog_add_line(getText("shotakun"), getText("ch1_2"))
        //dialog_add_line(getText("shotakun"), getText("ch1_3"))
        //dialog_add_line("", " ")
        //dialog_add_act(new Act("shota", 4, 1, 550))
        //dialog_add_line(getText("shotakun"), "?")
        //dialog_add_line("", " ")
        //dialog_add_act(new Act("shota", 4, 1, 250))
        //dialog_add_line(getText("shotakun"), getText("ch1_4"))
        //dialog_add_act(new Act("item", -1, 0, 0))
        //dialog_add_line(getText("shotakun"), getText("ch1_5"))
        //dialog_add_line(getText("shotakun"), "!")
        //dialog_add_act(new Act("shota", 0, -1, 0))
        //dialog_add_line(getText("shotakun"), getText("ch1_6"))
        //dialog_add_line("", " ")
        //dialog_add_act(new Act("shota", 12, 1, 250))
        //dialog_add_line("", " ")
        //dialog_add_act(new Act("shota", 12, 1, 1100))
        //dialog_add_line("", " ")

/// obj_forest Create Event
tile_test_counter = 0;

// Layer speeds (smaller = slower)
front_speed = -0.9;
bg_speed = 0.075;
mg_1_speed = 0.100;
mg_2_speed = 0.095;
mg_3_speed = 0.085;

notes_speed = 0

// Layer scales
front_scale = 1;
bg_scale = 0.3;
mg_1_scale = 0.8;
mg_2_scale = 0.6;
mg_3_scale = 0.4;

notes_scale = 1
//front_scale = 0.9;
//bg_scale = 1;
//mg_1_scale = 1;
//mg_2_scale = 1;
//mg_3_scale = 1;


// Get layer IDs
front_layer = layer_get_id("Forest_Front");
fg_layer = layer_get_id("Forest_Foreground")
bg_layer = layer_get_id("Forest_Background");
mg_1_layer = layer_get_id("Forest_Middleground_1");
mg_2_layer = layer_get_id("Forest_Middleground_2");
mg_3_layer = layer_get_id("Forest_Middleground_3");
notes_layer = layer_get_id("Slenderman_Notes")

// Get background IDs
front_id = layer_background_get_id(front_layer);
fg_id = layer_background_get_id(fg_layer)
bg_id = layer_background_get_id(bg_layer);
mg_1_id = layer_background_get_id(mg_1_layer);
mg_2_id = layer_background_get_id(mg_2_layer);
mg_3_id = layer_background_get_id(mg_3_layer);
notes_id = layer_background_get_id(notes_layer)

added_y_offset = -50

// Get sprite information
var bg_sprite = layer_background_get_sprite(bg_id);
var _sprite_height = sprite_get_height(bg_sprite);

// Calculate Y offsets based on height differences
var bg_y_offset = _sprite_height - (_sprite_height * bg_scale) + 6 * added_y_offset;
var mg_1_y_offset = _sprite_height - (_sprite_height * mg_1_scale) + added_y_offset;
var mg_2_y_offset = _sprite_height - (_sprite_height * mg_2_scale) + 3 * added_y_offset;
var mg_3_y_offset = _sprite_height - (_sprite_height * mg_3_scale) + 5 * added_y_offset;
//var notes_y_offset = _sprite_height - (sprite_get_height(spr_slenderman_notes) * notes_scale) + 5 * added_y_offset;

//function randomize_note_position(tree_tile_layer = fg_id) {
//    // Note sprite setup
//    var notes_y_offset = layer_get_y(notes_layer) + random_range(-50, 50);
//    var notes_element = layer_sprite_get_id(notes_layer, "graphic_67F5C33E");
//    var _i = random(sprite_get_number(spr_slenderman_notes));
//    layer_sprite_index(notes_element, _i);

//    // Get tile information (same as our test code)
//    var tree_tile_element = layer_background_get_id(tree_tile_layer);
//    var tree_tile_sprite = layer_background_get_sprite(tree_tile_element);
//    var tree_tile_w = sprite_get_width(tree_tile_sprite);
//    var tree_tile_scale = layer_background_get_xscale(tree_tile_element);

//    // Calculate how many tiles we can have
//    var tile_count = floor(room_width / (tree_tile_w * tree_tile_scale));
    
//    // Choose random tile (avoiding edges)
//    var min_tile = 5;
//    var max_tile = tile_count - 5;
//    var chosen_tile = irandom_range(min_tile, max_tile);
    
//    // Calculate base position (same as test code)
//    var tile_x = chosen_tile * (tree_tile_w * tree_tile_scale);
    
//    // Add trunk offset
//    var trunk_positions = [24, 87];  // X positions of trunks in sprite
//    var chosen_trunk = trunk_positions[irandom(array_length(trunk_positions) - 1)];
//    var final_x = tile_x + (chosen_trunk * tree_tile_scale);
    
//    // Set positions
//    layer_sprite_x(notes_element, final_x);
//    layer_y(notes_layer, notes_y_offset);
    
//    // Move player for testing
//    if instance_exists(obj_pkun) {
//        obj_pkun.x = final_x;
//    }
    
//    show_debug_message("Note placed at tile " + string(chosen_tile) + 
//                      " Position: " + string(final_x) + 
//                      " (Trunk offset: " + string(chosen_trunk) + ")");
//}

// layer property stuff
// Set properties
layer_background_alpha(front_id, 0.35);
layer_background_xscale(front_id, front_scale);
layer_background_yscale(front_id, front_scale);
layer_background_xscale(bg_id, bg_scale);
layer_background_yscale(bg_id, bg_scale);
layer_background_xscale(mg_1_id, mg_1_scale);
layer_background_yscale(mg_1_id, mg_1_scale);
layer_background_xscale(mg_2_id, mg_2_scale);
layer_background_yscale(mg_2_id, mg_2_scale);
layer_background_xscale(mg_3_id, mg_3_scale);
layer_background_yscale(mg_3_id, mg_3_scale);
layer_background_xscale(notes_id, notes_scale);
layer_background_yscale(notes_id, notes_scale);

// Set Y positions using the calculated offsets
layer_y(bg_layer, bg_y_offset);
layer_y(mg_1_layer, mg_1_y_offset);
layer_y(mg_2_layer, mg_2_y_offset);
layer_y(mg_3_layer, mg_3_y_offset);

//randomize_note_position()