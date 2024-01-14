name = "vegetable2";

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

--LoadTexture("vegetable2.png");
texture = "vegetable2";
z = -0.001;

image_width = 128;
image_height = 128;
frame_width = 21;
frame_height = 31;
frames_count = 16;

animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 21 },
			{ com = constants.AnimComRealH; param = 31 },
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
	
			{ dur = 50; num = 0; },
			{ dur = 50; num = 1; },
			{ dur = 50; num = 2; },
			{ dur = 50; num = 3; },
			{ dur = 50; num = 4; },
			{ dur = 50; num = 5; },
			{ dur = 50; num = 6; },
			{ dur = 50; num = 7; },
			{ dur = 50; num = 8; },
			{ dur = 50; num = 9; },
			{ dur = 50; num = 10;},
			{ dur = 50; num = 11;},
			{ dur = 50; num = 12;},
			{ dur = 50; num = 13;},
			{ dur = 50; num = 14;},
			{ dur = 50; num = 15;},
			{ com = constants.AnimComLoop }	
		}
	},
	{ 
		-- Бонус
		name = "touch";
		frames = 
		{
			{ com = constants.AnimComGiveHealth; param = 20 },
			{ com = constants.AnimComJumpIfPlayerId; param = 3 },
			{ com = constants.AnimComDestroyObject },
			{ dur = 100 },
			{ com = constants.AnimComPlaySound; txt = "health-pickup.ogg" },
			{ com = constants.AnimComCallFunction; txt = "StabilizeSync"; param = 1 },
			{ com = constants.AnimComDestroyObject }
		}
	}
	
}