/// @description Insert description here
// You can write your code in this editor
vx = camera_get_view_x(view_camera[0])
vy = camera_get_view_y(view_camera[0])
x = (vx + random_range(-400, 1680))
y = (vy + random(720))
xx = random_range(-2, 2)
yy = random_range(-2, 2)
timer = irandom_range(100, 250)
timer_half = (timer / 2)
timer = irandom(timer)
