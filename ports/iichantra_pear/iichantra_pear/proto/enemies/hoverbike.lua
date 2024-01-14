--forbidden
name = "slowpoke-ride";

physic = 1;
phys_solid = 0;
phys_bullet_collidable = 0;
phys_max_x_vel = 6;
phys_max_y_vel = 40;
phys_jump_vel = 20;
phys_walk_acc = 3;
phys_one_sided = 0;
mp_count = 1;
--gravity_x = 20;
gravity_x = 5;
gravity_y = 0;

FunctionName = "CreateEnemy";

trajectory_type = constants.pttCosine;
trajectory_param1 = 0.125;
trajectory_param2 = 0.05;

-- Описание спрайта

texture = "hoverbike";

z = -0.5;

image_width = 1024;
image_height = 256;
frame_width = 1;
frame_height = 1;
frames_count = 28;

animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 128 },
			{ com = constants.AnimComRealH; param = 128 },
			{ com = constants.AnimComSetHealth; param = 40 },
			{ com = constants.AnimComSetHealth; param = 100 },
			{ com = constants.AnimComSetTouchable; param = 1 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 65 },
			{ com = constants.AnimComMPSet; param = 0; },
			{ com = constants.AnimComSetAnim; txt = "move" }	
		}
	},
	{ 
		-- Создание
		name = "move";
		frames = 
		{
			{ dur = 100; num = 0},
			{ dur = 100; num = 1},
			{ dur = 100; num = 2},
			{ com = constants.AnimComLoop }
		}
	}
}



