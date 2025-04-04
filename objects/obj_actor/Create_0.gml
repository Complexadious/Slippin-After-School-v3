role = ""
state = "idle"
dir = 1
len = -1
spd = 0
soundDelay = 0

// Custom actor properties
custom_name = "";
idle_sprite = -1;
walk_sprite = -1;
image_speed = 0;
walk_sound = -4;
sound_index = [0];
sound_delay = 0;
make_pkun_hide = 0;
hide_se_in = -4;
hide_se_out = -4;
shake_amount_in = 20;
shake_amount_out = 20;
destroy_on_exit = true;
x_scale = 1;
y_scale = 1;
make_pkun_exit = 0;

if (room = rm_forest)
{
	depth = 250
	if (role == "shota")
		walk_sound = choose(se_gravel_step_1, se_gravel_step_2, se_gravel_step_3, se_gravel_step_4)
}

current_target = obj_pkun