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
			{ dur = 1 },
			{ com = constants.AnimComPushInt; param = 1 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateParticles; txt = "pwsnow"; param = 16 },
			{ com = constants.AnimComCallFunctionWithStackParameter; txt = "register_weather" },
			{ dur = 100 },
			{ com = constants.AnimComDestroyObject }
--			{ com = constants.AnimComLoop }
		}
	}
	
}
