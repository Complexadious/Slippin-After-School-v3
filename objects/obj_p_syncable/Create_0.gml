dir = dir ?? 1
dx = dx ?? 0

show_debug_message("syncable inst created (" + string(object_get_name(object_index)) + ")")
__entity = new entity(x, y, dir, object_index, depth)
__entity.attach(id)