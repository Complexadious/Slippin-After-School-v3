// Calculate the difference between the current scale and target scale (max or min)
var target_scale = (scale_direction == 1) ? max_scale : min_scale;
var distance = abs(scale - target_scale);

// Apply easing effect: Speed increases near `max_scale`, decreases near `min_scale`
var ease_speed = adjust_to_fps(scale_speed + (distance * ease_factor));

if instance_exists(obj_title)
	alp = obj_title.menu_alp
	
if (global.setting_mode)
{
	alp = 0
	return;
}

// Update the scale based on the calculated easing speed
scale += ease_speed * scale_direction;

// Reverse direction if scale reaches bounds
if (scale >= max_scale) scale_direction = -1; // Shrinking
if (scale <= min_scale) scale_direction = 1;  // Growing
