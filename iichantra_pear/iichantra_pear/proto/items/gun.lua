texture = "gun";
z = -0.001;

trajectory_type = constants.pttGlobalSine;
trajectory_param1 = 0.5;
trajectory_param2 = 0.05;

animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 44 },
			{ com = constants.AnimComRealH; param = 24 },
			{ com = constants.AnimComSetTouchable; param = 1 },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{ 
		-- Вращение
		name = "idle";
		frames = 
		{
			{ dur = 100; num = 0 },
			{ dur = 100; num = 1 },
			{ com = constants.AnimComLoop }	
		}
	},
	{ 
		-- Бонус
		name = "touch";
		frames = 
		{

			{ com = constants.AnimComCallFunction; txt = "gun_get" },
			{ com = constants.AnimComDestroyObject }

		}
	}
	
}



