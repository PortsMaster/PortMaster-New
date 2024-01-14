--forbidden

z = -0.11;
phys_ghostlike = 1;
effect = 1;
offscreen_distance = 640
offscreen_behavior = constants.offscreenNone

texture = "misc_effects"

animations = 
{
	{ 
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "loop" }
		}
	},

	{ 
		name = "loop";
		frames = 
		{
			{ dur = 100; num = 0 },
			{ dur = 100; num = 1 },
			{ dur = 100; num = 2 },
			{ dur = 100; num = 1 },
			{ com = constants.AnimComLoop }
		}
	}
	
}
