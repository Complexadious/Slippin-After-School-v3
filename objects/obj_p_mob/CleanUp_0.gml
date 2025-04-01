/// @description Insert description here
// You can write your code in this editor
if (variable_struct_exists(id, "entity_uuid")) && (entity_uuid != "") && (struct_exists(obj_multiplayer.network.entities, entity_uuid)) {
	_cb_destroy_entity(entity_uuid)
	struct_remove(obj_multiplayer.network.entities, entity_uuid)
//	instance_destroy();
}