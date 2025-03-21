//global.transition = 2
//global.trans_alp = 1
//dialog_add_line_ext("", getText("intro_1"), spr_intro_3, gus_creaming, true, 5)
//dialog_add_line_ext("", getText("intro_2"), spr_intro_4, dialog_intro_2, true, 5)
//dialog_add_line(getText("friendA"), getText("intro_3"), dialog_intro_3, true, 5)
//dialog_add_line(getText("shotakun"), getText("intro_4"),dialog_intro_4, true, 5)
//dialog_add_line(getText("friendA"), getText("intro_5"), dialog_intro_5, true, 5)
//dialog_add_line(getText("shotakun"), getText("intro_6"), dialog_intro_6, true, 5)
//dialog_add_line(getText("friendA"), getText("intro_7"), dialog_intro_7, true, 5)
//dialog_add_line_ext("", getText("intro_8"), spr_intro_5, dialog_intro_8, true, 5)
global.dialog_mode = 1
global.dialog_show_box = 1
global.enable_ui_cutter = 0
global.forest_raining = 1

if global.forest_raining
	play_bgm(bgm_rain_outside)
else
	play_bgm(bgm_forest)

// Find all sprite spots and configure one as a note
var sprite_spots = ds_list_create();

// Collect all sprite spots
with(obj_sprite_spot) {
    ds_list_add(sprite_spots, id);
}

// Pick and configure a random spot
if (ds_list_size(sprite_spots) > 0) {
    var chosen_spot = sprite_spots[| irandom(ds_list_size(sprite_spots) - 1)];
    
    with(chosen_spot) {
        sprite = spr_slenderman_notes;
        index = irandom(sprite_get_number(spr_slenderman_notes) - 1);
        target_layer = layer_get_id("Forest_Foreground");
        follow_layer = true;
        sprite_alpha = 1;
        sprite_xscale = 0.25;
        sprite_yscale = 0.25;
    }
//	show_debug_message("did stuff to spot")
}

// Clean up
ds_list_destroy(sprite_spots);