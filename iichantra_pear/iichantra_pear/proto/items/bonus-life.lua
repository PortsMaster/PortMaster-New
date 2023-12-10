name = "bonus-life";

trajectory_type = constants.pttGlobalSine;
trajectory_param1 = 0.5;
trajectory_param2 = 0.05;

physic = 1;
phys_solid = 0;
phys_bullet_collidable = 0;
phys_max_x_vel = 0;
phys_max_y_vel = 50;

FunctionName = "CreateItem";

-- Описание спрайта

texture = "bonus-life";
z = -0.001;

image_width = 256;
image_height = 32;
frame_width = 16;
frame_height = 16;
frames_count = 21;

animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 16 },
			{ com = constants.AnimComRealH; param = 16 },
			{ com = constants.AnimComSetTouchable; param = 1 },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{ 
		-- Вращение
		name = "idle";
		frames = 
		{
	
			{ dur = 50; num = 0 },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 2 },
			{ dur = 50; num = 1 },
			{ com = constants.AnimComLoop }	
		}
	},
	{ 
		-- Бонус
		name = "touch";
		frames = 
		{

			{ com = constants.AnimComPlaySound; txt = "item-score.ogg" },
			{ com = constants.AnimComMapVarAdd; param = 1; txt = "lives" },
			{ com = constants.AnimComDestroyObject }

		}
	}
	
}



