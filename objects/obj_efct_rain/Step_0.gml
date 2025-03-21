if !recal
{
	// Convert rotation to radians
	rot_radians = degtorad(rot);

	// Calculate velocities
	xspd = base_speed * sin(rot_radians);  // Use sin for x component
	yspd = base_speed * cos(rot_radians);  // Use cos for y component (positive for downward)
	recal = 1
}

/// Rain Step Event
x += adjust_to_fps(xspd);
y += adjust_to_fps(yspd);

var vx = camera_get_view_x(view_camera[0]);
var vy = camera_get_view_y(view_camera[0]);

// Destroy if outside view with buffer
if (x > (vx + 1320)) || (y > (vy + 760)) {
    instance_destroy();
}