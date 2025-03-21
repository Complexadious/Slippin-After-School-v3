/// obj_sprite_spot Create Event
// Configurable properties
sprite = spr_null;           // Sprite to display
target_layer = -4;     // Layer to tie movement to (optional)
layer_offset_x = 0;       // X offset from layer position
layer_offset_y = 0;       // Y offset from layer position
index = 0;              // Index of sprite frame to show
sprite_alpha = 1;         // Sprite transparency
sprite_xscale = 1;       // X scale of sprite
sprite_yscale = 1;       // Y scale of sprite
follow_layer = false;     // Whether to follow layer movement

// Color/darkness properties
blend_color = c_black;    // Color to blend with sprite
darkness = 0;            // 0 = normal, 1 = fully dark (blend amount)

// Store initial position
start_x = x;
start_y = y;
//show_debug_message("Sprite Spot created in room: " + string(room) + ", sprite: " + string(sprite) + ", pos: " + string(x) + ", " + string(y))