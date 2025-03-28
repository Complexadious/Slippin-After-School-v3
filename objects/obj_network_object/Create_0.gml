/// @description Insert description here
// You can write your code in this editor
show_debug_message("obj_network_object: CREATED!!")
dir = 1

intrTarget = portal_nearest()
np = -4
lp = -4
lifeloss_t = 0
lifeMax = 3
lifeCur = 3
charmed = 0

posxq = array_create(2)
posyq = array_create(2)
dx = 0
dy = 0
nametag = ""
network_obj_type = "player"
//if (self[$ "entity_uuid"] != "")
//	entity_uuid = generate_uuid4_string()
//else
//	show_debug_message("OBJ_NETWORK_OBJECT, NOT MAKING NEW UUID, ALREADY EXISTS!")
entity_uuid = ""

switch network_obj_type {
	case "player": {
		image_speed = adjust_to_fps(0.25)
		depth = -3
		
		hs_stp = 0
		hs_spr = -4
		hs_ind = 0
		hs_spd = 0
		hs_lp = -1
		hs_tmr = 0
		hs_snd_delay = 0
		hs_snd_prev = -4
		hs_snd_efct = -1
		hs_trans = 0
		hs_cum = 0	
		hs_hide_fl = 0
		hs_mob_id = 0

		flashOn = 1
		hiding = 0
		running = 0
		sliding = 0
		stamina = 100
		stmRegen = 0
		runCost = ((room == rm_game) ? 0.25 : 0)
		pantDelay = 0
		hscene_target = -4
		intrTarget = -4
		np = -4
		lp = -4
		noclip = 0
		se_step = [se_step_a_1, se_step_a_2, se_step_a_3]
		se_creak = [se_creak_1, se_creak_2, se_creak_3, se_creak_4]
		shadow = instance_create_depth(x, y, 1, obj_object_shadow)
		soundDelay = 0
		intrDone = -4
		intrNeed = -4
		pressing_interact = 0
		lifeloss_t = 0
		lifeMax = 3
		lifeCur = 3
		charmed = 0
		immortal = 0
		exhaust = 0
		username = "USERNAME"
		nametag = entity_uuid
		player_sock = -1
		break;	
	}
	//case "mob": {
		
	//}
}

// save id to network shit
//if is_multiplayer()
//	struct_set(obj_multiplayer.network.network_objects, entity_uuid, id)
	
show_debug_message("obj_network_object: CREATED!! uuid: " + entity_uuid)