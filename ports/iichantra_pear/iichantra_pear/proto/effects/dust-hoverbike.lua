--forbidden
texture = "dust-land";

z = -0.5

animations = 
{
	{ 
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 32 },
			{ com = constants.AnimComRealW; param = 64 },	
			{ dur = 100; num = 1 },
			{ dur = 100; num = 2 },
			{ dur = 100; num = 3 },
			{ com = constants.AnimComLoop }
		}
	}
}
