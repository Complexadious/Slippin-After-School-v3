/// Rain Create Event
rot = 0;  // Rotation in degrees
base_speed = (irandom_range(40, 60));  // Base fall speed
//base_speed = 10;

// Convert rotation to radians
rot_radians = degtorad(rot);

// Calculate velocities
xspd = base_speed * sin(rot_radians);  // Use sin for x component
yspd = base_speed * cos(rot_radians);  // Use cos for y component (positive for downward)
//show_debug_message("XSPD: " + string(xspd) + " YSPD: " + string(yspd))

alp = random_range(0.5, 1);
ys = random_range(0.6, 2);
x1 = irandom_range(-400, 400);
x2 = irandom_range(-400, 400);
y1 = irandom_range(-400, 400);
y2 = irandom_range(-400, 400);

recal = 0