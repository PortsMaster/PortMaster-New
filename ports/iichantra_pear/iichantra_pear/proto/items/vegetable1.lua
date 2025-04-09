name = "vegetable1";

trajectory_type = constants.pttGlobalSine;
trajectory_param1 = 0.5;
trajectory_param2 = 0.05;

physic = 1;
phys_solid = 0;
phys_bullet_collidable = 0;
phys_max_x_vel = 0;
phys_max_y_vel = 80;

FunctionName = "CreateItem";

-- Описание спрайта

--LoadTexture("vegetable1.png");
texture = "vegetable1";
z = -0.001;

image_width = 256;
image_height = 128;
frame_width = 32;
frame_height = 32;
frames_count = 19;

animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 8 },
			{ com = constants.AnimComRealY; param = 9 },
			{ com = constants.AnimComRealW; param = 16 },
			{ com = constants.AnimComRealH; param = 15 },
			{ com = constants.AnimComSetTouchable; param = 1 },
			--{ dur = 100; num = 20; com = constants.AnimComCreateParticles; txt = "pteleport" },
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
			{ dur = 50; num = 3 },
			{ dur = 50; num = 4 },
			{ dur = 50; num = 5 },
			{ dur = 50; num = 6 },
			{ dur = 50; num = 7 },
			{ dur = 50; num = 8 },
			{ dur = 50; num = 9 },
			{ dur = 50; num = 10 },
			{ dur = 50; num = 11 },
			{ dur = 50; num = 12 },
			{ dur = 50; num = 13 },
			{ dur = 50; num = 14 },
			{ dur = 50; num = 15 },
			{ dur = 50; num = 16 },
			{ dur = 50; num = 17 },
			{ dur = 50; num = 18 },
			{ com = constants.AnimComLoop }	
		}
	},
	{ 
		-- Бонус
		name = "touch";
		frames = 
		{
			{ com = constants.AnimComGiveHealth; param = 10 },
			{ com = constants.AnimComJumpIfPlayerId; param = 3 },
			{ com = constants.AnimComDestroyObject },
			{ dur = 100 },
			{ com = constants.AnimComPlaySound; txt = "health-pickup.ogg" },
			{ com = constants.AnimComCallFunction; txt = "StabilizeSync"; param = 1 },
			{ com = constants.AnimComDestroyObject }
		}
	}
	
}



