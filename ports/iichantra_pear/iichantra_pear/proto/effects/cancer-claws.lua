--forbidden
texture = "cancer";

z = -0.09;
phys_ghostlike = 1;
physic = 1;
phys_bullet_collidable = 0;
phys_max_x_vel = 9000;
offscreen_distance = 640
offscreen_behavior = constants.offscreenNone

effect = 1;


animations = 
{
	{
		name = "idle";
		frames =
		{
			{ com = constants.AnimComRealW; param = 90 },
			{ com = constants.AnimComRealH; param = 65 },
			{ com = constants.AnimComSetHealth; param = 150 },
			{ dur = 1; num = 12 },
			{ com = constants.AnimComSetAnim; txt = "loop" }
		}
	},
	{
		name = "loop";
		frames =
		{
			{ dur = 100; num = 12; com = constants.AnimComRealW; param = 90 },
			{ dur = 100; num = 13; },
			{ dur = 100; num = 14; },
			{ dur = 100; num = 15; },
			{ dur = 100; num = 16; com = constants.AnimComRealW; param = 88 },
			{ com = constants.AnimComLoop }
		}
	}
}
