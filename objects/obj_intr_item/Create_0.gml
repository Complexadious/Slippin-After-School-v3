event_inherited()
/// @description Insert description here
// You can write your code in this editor
type = "itemspot"
need = 60
icon = 3
se = -4
xx = x
yy = (y - 100)
y = (560 + (720 * floor((y / 720))))
sprite_index = spr_item_flick
image_speed = 1
image_angle = irandom_range(-45, 45)
itemid = 0
var current_target = get_closest_target(x, y, id)