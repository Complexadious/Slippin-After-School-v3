var _x = ((obj_pkun.x / room_width) - 0.5);
var _y = ((obj_pkun.y / room_height) - 0.5);

var _rad = params[$ "g_DistortRadius"];
_rad += (spd * dir);

// Clamp _rad within limits
if (_rad < min_rad) {
    _rad = min_rad;
    dir *= -1;
}
if (_rad > max_rad) {
    _rad = max_rad;
    dir *= -1;
}

params[$ "g_DistortRadius"] = _rad;
params[$ "g_DistortOffset"] = [_x, _y];
params[$ "g_DistortAngle"] = 69;

fx_set_parameters(fx, params);

show_debug_message("DIR: " + string(dir) + " FX PARAMS: " + string(fx_get_parameters(fx)));
layer_set_fx("Pkun", fx)
