--forbidden
phys_max_x_vel = 5;
phys_max_y_vel = 50;
mp_count = 1;
offscreen_distance = 640
offscreen_behavior = constants.offscreenDestroy

drops_shadow = 1;

gravity_x = 0;
gravity_y = 0.8;

faction_id = -2;

-- Описание спрайта

texture = "ex";

z = -0.002;

animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 84 },
			{ com = constants.AnimComRealH; param = 80 },
			{ com = constants.AnimComSetHealth; param = 20*difficulty },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{ 
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComMirror },
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 50 },
			{ com = constants.AnimComRealH; param = 77 },
			{ dur = 1; num = 3 }
		}
	},
	{
		name = "right";
		frames =
		{
			{ com = constants.AnimComSetAccX; param = 2000 },
			{ com = constants.AnimComRealW; param = 84 },
			{ com = constants.AnimComRealH; param = 80 },
			{ num = 0; dur = 150 },
			{ num = 1; dur = 150 },
			{ com = constants.AnimComRealH; param = 83 },
			{ num = 1; dur = 150 },
			{ com = constants.AnimComLoop }
		}
	},
	{
		name = "left";
		frames =
		{
			{ com = constants.AnimComSetAccX; param = -2000 },
			{ com = constants.AnimComRealW; param = 84 },
			{ com = constants.AnimComRealH; param = 80 },
			{ num = 0; dur = 150 },
			{ num = 1; dur = 150 },
			{ com = constants.AnimComRealH; param = 83 },
			{ num = 1; dur = 150 },
			{ com = constants.AnimComLoop }
		}
	}
}



