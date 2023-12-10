texture = "2011lab3";
facing = constants.facingFixed

z = -0.008;

physic = 1;
phys_solid = 1;
phys_one_sided = 1;
phys_bullet_collidable = 0;

mass = -1;

ghost_to = 18;

phys_max_x_vel = 5;
phys_max_y_vel = 5;

animations =
{
	{
		name = "init";
		frames = 
		{
			{ com = constants.AnimComInitH; param = 14 },
			{ com = constants.AnimComRealH; param = 13 },
			{ com = constants.AnimComRealW; param = 130 },
			{ com = constants.AnimComInitW; param = 96 },
			{ com = constants.AnimComPushInt; param = 1 },
			{ com = constants.AnimComInitW; param = 108 },
			{ com = constants.AnimComRealX; param = 17 },
			{ com = constants.AnimComRealY; param = 13 },
			{ com = constants.AnimComSetAnim; txt = "loop" }
		}
	},
	{
		name = "loop";
		frames =
		{
			{ com = constants.AnimComPushInt; param = 8+32+64+128 },
			{ dur = 0, num = 35; com = constants.AnimComFlyToWaypoint; param = 2000 },
			{ dur = 50, num = 72 },
			{ com = constants.AnimComJump; param = 2 }
		}
	}
}
