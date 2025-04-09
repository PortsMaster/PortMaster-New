--forbidden

z = -0.11;
phys_ghostlike = 0;
effect = 1;
offscreen_distance = 640
offscreen_behavior = constants.offscreenNone

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
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ dur = 1 },
			{ com = constants.AnimComCreateParticles; txt = "pleaves"; param = 16 },
			{ dur = 100 },
--			{ com = constants.AnimComLoop }
		}
	}
	
}
