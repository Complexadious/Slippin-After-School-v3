if (instance_exists(obj_pkun) && (obj_pkun.portalPort == port) && (distance_to_object(obj_pkun) > 200) && (global.trans_alp >= 0.9))
{
    obj_pkun.x = x
    obj_pkun.y = (560 + (720 * floor((y / 720))))
    obj_camera.x = obj_pkun.x
    obj_pkun.portalPort = -1
	// sync_pkun_event()
}
