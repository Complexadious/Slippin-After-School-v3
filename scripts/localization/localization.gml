function loadTextFile() //gml_Script_loadTextFile
{
    global.textFile = load_csv(("Text.csv"))
    var hh = ds_grid_height(global.textFile)
    var keys = ds_map_create()
    for (var i = 0; i < hh; i++)
        ds_map_add(keys, ds_grid_get(global.textFile, 0, i), i)
    global.textKey = keys
}

function getText(argument0, argument1 = "Undefined (Can't find in Text.csv)") //gml_Script_getText
{
    var str = "undefined"
    if ((global.textFile != -1) && ds_map_exists(global.textKey, argument0))
        str = ds_grid_get(global.textFile, (1 + global.language), ds_map_find_value(global.textKey, argument0))
	if (str == "undefined") str = argument1; // Add optional fallback if text isnt found in text.csv
    return str;
}

function sys_game_restart() //gml_Script_sys_game_restart
{
    game_restart()
}

function setFont(argument0, argument1) //gml_Script_setFont
{
    var fnt = "fnt_"
    if ((global.language == (2)) || (global.language == (1)))
    {
        if ((argument0 == "C"))
            fnt += "nanumjhs"
        else
            fnt += "sangsang"
    }
    else if ((argument0 == "A"))
        fnt += "ankoku"
    else if ((argument0 == "B"))
        fnt += "otsutome"
    else if ((argument0 == "C"))
        fnt += "tare"
    draw_set_font(asset_get_index(((fnt + "_") + string(argument1))))
}

function pkun_get_location(argument0) //gml_Script_pkun_get_location
{
    var str = ""
    var flr = 1
    var px = 0
    var py = 0
    if instance_exists(obj_pkun)
    {
		var nearest_room = instance_nearest(obj_pkun.x, obj_pkun.y, obj_room_identifier)
		if (place_meeting(obj_pkun.x, obj_pkun.y, nearest_room)) || (distance_to_object(nearest_room) < 50)
		{
			return nearest_room.room_name
		}
		else
		{
	        px = obj_pkun.x
	        py = obj_pkun.y
	        flr = ((floor((py / 720)) % 3) + 1)
	        if argument0
	            str += (string(flr) + "F ")
	        if ((py < 2160))
	            str += getText("map_hall")
	        else if ((py < 4320))
	        {
	            if ((px < 3500))
	                str += ((string(flr) + "-A") + getText("map_class"))
	            else if ((px < 6500))
	                str += ((string(flr) + "-B") + getText("map_class"))
	            else if ((px < 9500))
	                str += ((string(flr) + "-C") + getText("map_class"))
	            else if ((flr == 1))
	                str += getText("map_staff")
	            else if ((flr == 2))
	                str += getText("map_lab")
	            else if ((flr == 3))
	                str += getText("map_art")
	        }
	        else if ((px < 2800))
	            str += getText("map_toilet_m")
	        else
	            str += getText("map_toilet_f")
		}
    }
    return str;
}

function get_location(x, y, include_floor = 1) //gml_Script_pkun_get_location
{
    var str = ""
    var flr = 1
    var px = 0
    var py = 0
    if (room == rm_game)
    {
		var nearest_room = instance_nearest(x, y, obj_room_identifier)
		if (place_meeting(x, y, nearest_room)) || (distance_to_object(nearest_room) < 50)
		{
			return nearest_room.room_name
		}
		else
		{
	        px = x
	        py = y
	        flr = ((floor((py / 720)) % 3) + 1)
	        if include_floor
	            str += (string(flr) + "F ")
	        if ((py < 2160))
	            str += getText("map_hall")
	        else if ((py < 4320))
	        {
	            if ((px < 3500))
	                str += ((string(flr) + "-A") + getText("map_class"))
	            else if ((px < 6500))
	                str += ((string(flr) + "-B") + getText("map_class"))
	            else if ((px < 9500))
	                str += ((string(flr) + "-C") + getText("map_class"))
	            else if ((flr == 1))
	                str += getText("map_staff")
	            else if ((flr == 2))
	                str += getText("map_lab")
	            else if ((flr == 3))
	                str += getText("map_art")
	        }
	        else if ((px < 2800))
	            str += getText("map_toilet_m")
	        else
	            str += getText("map_toilet_f")
		}
    }
	else
	{
		str = "in_unknown_room"	
	}
    return str;
}

function get_floor(y, floors = 3, floor_height = 720) {
	return ((floor((y / floor_height)) % floors) + 1)	
}

function intr_get_text(argument0) //gml_Script_intr_get_text
{
    var str = ""
    if ((argument0.type == "portal"))
    {
        if ((argument0.port > 100))
        {
            if ((argument0.icon == 1))
                str += getText("intr_up")
            else
                str += getText("intr_dwn")
        }
        else
            str += location_get_name((argument0.y > 2100), argument0.port, 0)
    }
    else if ((argument0.type == "hidespot"))
    {
        if obj_pkun.hiding
            str += getText("intr_exit")
        else
            str += getText("intr_hide")
    }
    else if ((argument0.type == "itemspot"))
        str += getText("intr_search")
    else if ((argument0.type == "mainexit"))
        str += getText("intr_exit")
    else if ((argument0.type == "figure"))
        str += "H"
    else if ((argument0.type == "piano"))
        str += getText("intr_piano")
    return str;
}

function location_get_name(argument0, argument1, argument2) //gml_Script_location_get_name
{
	// first check if there is a room identifier there
	// if there isn't, then check as normal
	var possible_rooms = {}
	
	with (obj_room_identifier) {
		var dist = point_distance(argument0, argument1, x, y)
		if (dist <= 50)
			struct_set(possible_rooms, dist, room_name)
	}
	
	// go through all possible rooms and get the one that's closest
	if (struct_names_count(possible_rooms) > 1)
	{
		var dists = struct_get_names(possible_rooms)
		closest_room = script_execute_ext(min, dists) 
		return closest_room
	}
	else if (array_length(possible_rooms) == 0)
	{
	    str = "" 
	    flr = floor((argument1 / 10))
	    n = (argument1 % 10)
	    if argument0
	        str += ((string(flr) + "F ") + getText("map_hall"))
	    else if ((n == 4))
	        str += ((string(flr) + "F ") + getText("map_toilet_m"))
	    else if ((n == 5))
	        str += ((string(flr) + "F ") + getText("map_toilet_f"))
	    else if ((n == 8) || (n == 9))
	    {
	        if ((flr == 1))
	            str += getText("map_staff")
	        else if ((flr == 2))
	            str += getText("map_lab")
	        else if ((flr == 3))
	            str += getText("map_art")
	    }
	    else
	    {
	        str += (string(flr) + "-")
	        if ((n < 2))
	            str += "A"
	        else if ((n < 6))
	            str += "B"
	        else
	            str += "C"
	        str += getText("map_class")
	    }
	    return str;
	}
}

