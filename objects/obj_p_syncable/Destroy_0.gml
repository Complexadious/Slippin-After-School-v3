/// @description Insert description here
// You can write your code in this editor
if (variable_instance_exists(id, "__entity") && (struct_exists(__entity, "destroy"))) {
	// properly handle destroying entity
	__entity.destroy()
}