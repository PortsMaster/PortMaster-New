--forbidden
name = "slowpoke-ride";

physic = 1;
phys_solid = 0;
phys_bullet_collidable = 0;
phys_max_x_vel = 1;
phys_max_y_vel = 50;
phys_jump_vel = 20;
phys_walk_acc = 3;
phys_one_sided = 0;
mp_count = 1;
gravity_x = 15;
gravity_y = 0;

FunctionName = "CreateEnemy";

-- Описание спрайта

texture = "slowpoke_ride";

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
			{ com = 11 },
			{ com = constants.AnimComSetAnim; txt = "move" }	
		}
	},
	{ 
		-- Создание
		name = "move";
		frames = 
		{
			{ dur = 100; num = 7},
			{ dur = 100; num = 6},
			{ dur = 100; num = 5},
			{ dur = 100; num = 4},
			{ dur = 100; num = 3},
			{ dur = 100; num = 2},
			{ dur = 100; num = 1},
			{ dur = 100; num = 0},
			{ com = 11 },
			{ com = constants.AnimComLoop }
		}
	}
}



