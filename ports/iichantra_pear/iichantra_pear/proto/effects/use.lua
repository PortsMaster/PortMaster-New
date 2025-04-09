--forbidden

z = -0.11;
phys_ghostlike = 1;
effect = 1;
offscreen_distance = 640
offscreen_behavior = constants.offscreenNone

facing = constants.facingFixed;

texture = "misc_effects"

animations = 
{
	{ 
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComRealX; param = -3 },
			{ com = constants.AnimComRealY; param = 5 },
			{ com = constants.AnimComSetAnim; txt = "loop" }
		}
	},
	{ 
		name = "loop";
		frames = 
		{
			{ dur = 100; num = 6 },
			{ dur = 100; num = 7 },
			{ dur = 100; num = 8 },
			{ dur = 100; num = 7 },
			{ com = constants.AnimComLoop }
		}
	}
	
}
