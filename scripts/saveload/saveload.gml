function stageSetting(global_var, default_val = -4, file = "Custom_Stage_Settings.ini") constructor {
	_global_var = global_var;
	_default_val = default_val;
	_val = global[$ global_var] != undefined ? global[$ global_var] : default_val; 
	_file = file;
	_type = "stage";
	
	show_debug_message("Stage Setting " + string(global_var) + " created.");
}

function Setting(section, display_name, global_var = display_name, default_val = -4, file = "Settings.ini", options = {}) constructor {
    _section = section;                     
    _display_name = display_name;          
    _global_var = global_var;
    _val = global[$ global_var] != undefined ? global[$ global_var] : default_val; 
    _default_val = default_val;             
	_file = file;
	_type = "setting";

    // Merge user-provided options with defaults
    _options = {
        changeInGame: options[$ "changeInGame"] ?? true, // (bool) Determines if the setting can be changed during gameplay. Default: true.
        sett_k: options[$ "sett_k"] ?? display_name, // (string) The displayed name of the setting in the UI. Defaults to the display_name parameter.
        sett_v: options[$ "sett_v"] ?? _val, // (any) The value displayed for the setting. Defaults to the current value of the global variable (_val).
        maxNum: options[$ "maxNum"] ?? noone, // (real) The maximum allowable value for the setting (required if the type is "range").
        minNum: options[$ "minNum"] ?? noone, // (real) The minimum allowable value for the setting (required if the type is "range").
        changeRate: options[$ "changeRate"] ?? 1, // (real) The increment or decrement amount for the setting when adjusted. Default: 1.
		type: options[$ "type"] ?? "range", // type: (string) The type of the setting:
										//       - "range": Represents a numerical range (e.g., brightness 0-100).
										//       - "bool": Represents a toggle (on/off, true/false).
		keyDelay: options[$ "keyDelay"] ?? !(options[$ "type"] == "range"), // (bool) Determines if holding down a key repeatedly changes the setting. Default: false.
		askConfirm: options[$ "askConfirm"] ?? 0, // (bool) Specifies if the setting should prompt a "Are you sure?" confirmation before applying changes. Default: false.
		sett_v_cases: options[$ "sett_v_cases"] ?? [], // (array) Defines specific display values for certain numeric cases (e.g., [0, "OFF"], [1, "ON"]).
		loop: options[$ "loop"] ?? 0, // (bool) Specifies if the setting should loop back to min when max is exceeded and vice versa. Default: false.
//is_stage_setting: options[$ "is_stage_setting"] ?? 0, // (bool) specifies whether to actually render this, if its a stage setting then NO
    };

    show_debug_message("Setting " + string(display_name) + " created with options: " + string(_options));

    // Initialize the global variable with the _val value
    global[$ global_var] = _val;
}


function saveSettingToFile(setting) {
    var file = global.game_dir + setting._file;
    ini_open(file);

	// Ensure the latest value from the global variable is used
	setting._val = global[$ setting._global_var];
	
	if (setting._type == "setting") {
	    ini_write_real(setting._section, setting._display_name, setting._val);
		global.settings_page = 0
	}
	else
	{
		ini_write_real("CUSTOM_STAGE_SETTINGS", setting._global_var, setting._val);	
	}
    ini_close();
}

function loadSettingFromFile(setting) {
    var file = global.game_dir + setting._file;
	var stage = !(setting._type == "setting")
	var sec = (stage) ? "CUSTOM_STAGE_SETTINGS" : setting._section
	var dn = (stage) ? setting._global_var : setting._display_name
	
    if (file_exists(file)) {
        ini_open(file);
        global[$ setting._global_var] = ini_read_real(sec, dn, setting._default_val);
        ini_close();
    } else {
        // If the file or key doesn't exist, initialize with default and save
        global[$ setting._global_var] = setting._default_val;
        saveSettingToFile(setting);
    }
}

/// @description Registers a global variable to save in a settings file.
/// @param {string} section Ini section name (ex. "Settings" or "General")
/// @param {string} display_name Ini key name and name to display in settings ui
/// @param {string} global_var Global variable to tie it to (ex. "sigma" -> global.sigma)
/// @param {string} default_val Default value
/// @param {string} file Name of the file to save it to (Defaults to "Settings.ini")
/// @param {any} options Additional options (changeInGame {bool}, sett_k {strings}, sett_v {strings}, maxNum {real}, minNum {real})
function addSetting(section, display_name, global_var = display_name, default_val = -4, file = "Settings.ini", options = {}) {
    var new_setting = new Setting(section, display_name, global_var, default_val, file, options);
    if (!is_array(global.settings)) global.settings = [];
    array_push(global.settings, new_setting);
}

function addStageSetting(global_var, default_val = -4, file = "Custom_Stage_Settings.ini") {
	var new_stage_setting = new stageSetting(global_var, default_val, file)
	if (!is_array(global.stage_settings)) global.stage_settings = [];
	array_push(global.stage_settings, new_stage_setting)
}

function sys_save_setting() //gml_Script_sys_save_setting
{
    var fn = (global.game_dir + "Settings.ini")
    if file_exists(fn)
        file_delete(fn)
    ini_open(fn)
    ini_write_real("Settings", "Language", global.language)
    ini_write_real("Settings", "Coward Mode", global.cowardOn)
    ini_write_real("Settings", "Bloom Shader", global.shaderOn)
    ini_write_real("Settings", "Fullscreen", window_get_fullscreen())
    ini_write_real("Settings", "BGM Volume", global.vol_bgm)
    ini_write_real("Settings", "SE Volume", global.vol_se)
	ini_close()
	
	// New implementation
    show_debug_message("sys_save_setting: Saving all settings");
    if (is_array(global.settings)) {
        for (var i = 0; i < array_length(global.settings); i++) {
            saveSettingToFile(global.settings[i]);
        }
    }
	sys_apply_settings()
}

function sys_load_setting() //gml_Script_sys_load_setting
{
    var fn = (global.game_dir + "Settings.ini")
    if file_exists(fn)
    {
        ini_open(fn)
        window_set_fullscreen(ini_read_real("Settings", "Fullscreen", 0))
        global.language = ini_read_real("Settings", "Language", 0)
        global.vol_bgm = ini_read_real("Settings", "BGM Volume", 50)
        global.vol_se = ini_read_real("Settings", "SE Volume", 100)
        global.cowardOn = ini_read_real("Settings", "Coward Mode", 1)
        global.shaderOn = ini_read_real("Settings", "Bloom Shader", 1)
//		global.shaderOn = 0
        ini_close()
    }
    else
    {
        global.language = 1
        global.shaderOn = 1
//		global.shaderOn = 0
        global.cowardOn = 1
        global.vol_se = 100
        global.vol_bgm = 50
        sys_save_setting()
    }
	// New implementation
    show_debug_message("sys_load_setting: Loading all settings");
    if (is_array(global.settings)) {
        for (var i = 0; i < array_length(global.settings); i++) {
            loadSettingFromFile(global.settings[i]);
        }
    }
	sys_apply_settings()
}

function sys_init_stage() //gml_Script_sys_init_stage
{
    global.itemSlot[0] = 0
    global.itemSlot[1] = 0
    global.flashOn = 1
    global.flashPow = 100
    global.lifeMax = 3
    global.lifeCur = 3
    global.charmed = 0
    global.lastX = -1
    global.lastY = -1
	
	// New stage settings implementation
    show_debug_message("sys_init_stage: Currently Init/Resetting for all custom stage settings");
    if (is_array(global.stage_settings)) {
        for (var i = 0; i < array_length(global.stage_settings); i++) {
            //loadSettingFromFile(global.stage_settings[i]);
			global[$ global.stage_settings[i]._global_var] = global.stage_settings[i]._default_val // resetting all data to defaults
        }
    }
}

function sys_save_stage() //gml_Script_sys_save_stage
{
    var fn = (global.game_dir + "Stage.sav")
    if file_exists(fn)
        file_delete(fn)
    ini_open(fn)
    ini_write_real("Stage", "lifeCur", global.lifeCur)
    ini_write_real("Stage", "flashPow", global.flashPow)
    ini_write_real("Stage", "flashOn", global.flashOn)
    ini_write_real("Stage", "itemSlot[1]", global.itemSlot[1])
    ini_write_real("Stage", "itemSlot[0]", global.itemSlot[0])
    ini_write_real("Stage", "lastY", obj_pkun.y)
    ini_write_real("Stage", "lastX", obj_pkun.x)
    ini_write_real("Stage", "Hour", max(global.clock_hr, 1))
    ini_close()
	
	// New Stage Settings implementation
	show_debug_message("sys_save_stage: Saving all stage settings");
    if (is_array(global.stage_settings)) {
        for (var i = 0; i < array_length(global.stage_settings); i++) {
            saveSettingToFile(global.stage_settings[i]);
        }
    }
}

function sys_load_stage(argument0) //gml_Script_sys_load_stage
{
    var fn = (global.game_dir + "Stage.sav")
	show_debug_message("Running SYS_LOAD_STAGE with save " + string(fn))
    if file_exists(fn)
    {
        ini_open(fn)
        if argument0
            global.clock_hr_load = ini_read_real("Stage", "Hour", -1)
        else
        {
            global.lifeCur = ini_read_real("Stage", "lifeCur", global.lifeMax)
            global.flashPow = ini_read_real("Stage", "flashPow", 100)
            global.flashOn = ini_read_real("Stage", "flashOn", 1)
            global.itemSlot[1] = ini_read_real("Stage", "itemSlot[1]", 0)
            global.itemSlot[0] = ini_read_real("Stage", "itemSlot[0]", 0)
            global.clock_hr = ini_read_real("Stage", "Hour", -1)
            global.lastX = ini_read_real("Stage", "lastX", -1)
            global.lastY = ini_read_real("Stage", "lastY", -1)
        }
        ini_close()
    }
	
	// New stage settings implementation
    show_debug_message("sys_init_stage: Loading custom stage settings");
    if (is_array(global.stage_settings)) {
        for (var i = 0; i < array_length(global.stage_settings); i++) {
            loadSettingFromFile(global.stage_settings[i]);
        }
    }
}

function sys_save_player() //gml_Script_sys_save_player
{
    var fn = (global.game_dir + "Player.sav")
    if file_exists(fn)
        file_delete(fn)
    ini_open(fn)
    for (var i = 9; i >= 0; i--)
        ini_write_real("Player", (("memoRead[" + string(i)) + "]"), global.memoRead[i])
    ini_write_real("Player", "gallery_lock", global.gallery_lock)
    ini_write_real("Player", "end_stay", global.end_stay)
    ini_write_real("Player", "end_leave", global.end_leave)
    ini_close()
}

function sys_load_player() //gml_Script_sys_load_player
{
    var fn = (global.game_dir + "Player.sav")
    if file_exists(fn)
    {
        ini_open(fn)
        for (var i = 9; i >= 0; i--)
            global.memoRead[i] = ini_read_real("Player", (("memoRead[" + string(i)) + "]"), 0)
        global.gallery_lock = ini_read_real("Player", "gallery_lock", 1)
        global.end_stay = ini_read_real("Player", "end_stay", 0)
        global.end_leave = ini_read_real("Player", "end_leave", 0)
        ini_close()
    }
    else
    {
        for (i = 10; i >= 0; i--)
            global.memoRead[i] = 0
        global.gallery_lock = 0
        global.end_stay = 0
        global.end_leave = 0
    }
}

function sys_apply_settings()
{
	show_debug_message("sys_apply_settings, Applying settings!")
	
	// Gamespeed
	game_set_speed(global.gamespeed_fps, gamespeed_fps)
	
	// Vsync
	if (global.enable_vsync)
		display_set_timing_method(tm_countvsyncs);
	else
		display_set_timing_method(tm_sleep);
}