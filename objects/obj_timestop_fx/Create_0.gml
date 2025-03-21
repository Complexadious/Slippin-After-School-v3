/// @description Insert description here
// You can write your code in this editor
time = 0

timestop_duration = 0
//if instance_exists(obj_pkun)
//	timestop_duration = obj_pkun.timeStop
//else
//	instance_destroy();
 
dir = 1
max_rad = 2
min_rad = 0.001
spd = 0.05

// get fx target layer
//target_layer = layer_exists("Timestop_FX") ? layer_get_id("Timestop_FX") : layer_create(-100, "Timestop_FX")
target_layer = layer_exists("Pkun") ? layer_get_id("Pkun") : layer_create(-100, "Pkun")

//effects = {}
fx_name = "_filter_twirl_distort"

fx = fx_create("_filter_twirl_distort")
params = fx_get_parameters(fx)

fx_set_single_layer(fx, true)
layer_set_fx("Pkun", fx)

show_debug_message("Created fx: " + string(fx_name) + ", it has parameters:\n" + string(fx_get_parameters(fx)))

// Swirl
//_fx_name = fx_create("_filter_underwater")
//_fx_parameters = fx_get_parameters(_fx_name)
//_swirl = {fx : _fx_name, params : _fx_parameters}