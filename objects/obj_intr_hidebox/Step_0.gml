// var current_target = get_closest_target(x, y, id)

if (shake > 0)
    shake-= adjust_to_fps(1)
if locked
    icon = 6
else if (instance_exists(current_target)) && (instance_exists(current_target.intrTarget)) && (current_target.intrTarget == id && current_target.hiding)
    icon = 5
else
    icon = 4
