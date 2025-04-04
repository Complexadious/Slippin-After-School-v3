/// @description Insert description here
// You can write your code in this editor
if variable_instance_exists(id, "cam") && instance_exists(cam) {
with (cam)
    instance_destroy()
}
if variable_instance_exists(id, "shadow") && instance_exists(shadow) {
with (shadow)
    instance_destroy()
}
	