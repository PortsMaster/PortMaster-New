--forbidden
texture = "btardis";

z = -.001;

animations = 
{
	{ 
		name = "idle";
		frames = 
		{
			{ dur = 50; num = 5 },
			{ dur = 50; num = 6 },
			{ com = constants.AnimComRealX; param = 36 },
			{ dur = 300; num = 7 },
			{ com = constants.AnimComRealX; param = 0 },
			{ dur = 50; num = 6 },
			{ dur = 50; num = 5 },
			{ com = constants.AnimComDestroyObject }
		}
	},
}
