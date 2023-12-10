texture = "phys_floor";

z = -0.1;

physic = 1;
phys_solid = 1;
phys_bullet_collidable = 1;
phys_one_sided = 1;

phys_max_x_vel = 3;
phys_max_y_vel = 3;

animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 32 },
			{ com = constants.AnimComRealH; param = 32 },
			{ com = constants.AnimComSetAnim; txt = "fly_loop" }	
		}
	},
	{
		name = "fly_loop";
		frames =
		{
			{ com = constants.AnimComPushInt; param = 2000 },
			{ com = constants.AnimComPushInt; param = 2 },
			{ dur = 100; num = 0; com = constants.AnimComFlyToWaypoint; param = 20 },
			{ com = constants.AnimComLoop }
		}
	},
	{
		name = "land";
		frames =
		{
			{ com = constants.AnimComSetAnim; txt = "fly_loop" }
		}
	}
}
