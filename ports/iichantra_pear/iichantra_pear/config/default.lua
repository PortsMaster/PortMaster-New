CONFIG = 
{	window_width = 640;
	window_height = 480;
	scr_width = 640;
	scr_height = 480;
	near_z = -1.100000;
	far_z = 1.100000;
	bpp = 32;
	fullscreen = 0;
	vert_sync = 0;
	debug = 0;
	show_fps = 1;

	log_level = constants.logLevelWarning;
	
	gametick = 10;

	
	backcolor_r = 0.000000;
	backcolor_g = 0.000000;
	backcolor_b = 0.000000;
	
	volume = 1.000000;
	volume_music = 1.000000;
	volume_sound = 1.000000;
	
	-- controls

	key_conf = {
		{
			left = keys["left"];
			right = keys["right"];
			down = keys["down"];
			up = keys["up"];
			jump = keys["x"];
			sit = keys["z"];
			fire = keys["c"];
			change_weapon = keys["lshift"];
			change_player = keys["a"];
			gui_nav_accept = keys["enter"];
			gui_nav_decline = keys["x"];
			gui_nav_prev = keys["up"];
			gui_nav_next = keys["down"];
			gui_nav_menu = keys["esc"];
			gui_nav_screenshot = keys["f11"];
			player_use = keys["d"];
		},
		{
			left = 0;
			right = 0;
			down = 0;
			up = 0;
			jump = 0;
			sit = 0;
			fire = 0;
			change_weapon = 0;
			change_player = 0;
			gui_nav_accept = keys["c"];
			gui_nav_decline = 0;
			gui_nav_prev = 0;
			gui_nav_next = 0;
			gui_nav_menu = 0;
			gui_nav_screenshot = 0;
			player_use = 0;
		},
		{
			left = 0;
			right = 0;
			down = 0;
			up = 0;
			jump = 0;
			sit = 0;
			fire = 0;
			change_weapon = 0;
			change_player = 0;
			gui_nav_accept = keys["c"];
			gui_nav_decline = 0;
			gui_nav_prev = 0;
			gui_nav_next = 0;
			gui_nav_menu = 0;
			gui_nav_screenshot = 0;
			player_use = 0;
		},
		{
			left = 0;
			right = 0;
			down = 0;
			up = 0;
			jump = 0;
			sit = 0;
			fire = 0;
			change_weapon = 0;
			change_player = 0;
			gui_nav_accept = 0;
			gui_nav_decline = 0;
			gui_nav_prev = 0;
			gui_nav_next = 0;
			gui_nav_menu = 0;
			gui_nav_screenshot = 0;
			player_use = 0;
		}
	};
	joystick_sensivity = 1000;
	
	-- gui settings

	gui_nav_mode = 1;
	gui_nav_cycled = 1;
	
	-- game

	language = "english";
	shadows = 1;
	weather = 1;
}
LoadConfig();
