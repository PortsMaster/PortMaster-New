texture = "snoweffects";

z = 0.25;
animations = 
{
	{ 
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = -60 },
			{ com = constants.AnimComRealW; param = 64 },	
			{ dur = 100; num = 4 },
			{ dur = 100; num = 5 },
			{ dur = 100; num = 6 },
			{ dur = 100; num = 7 },
			{ dur = 100; num = 8 },
			{ dur = 100; num = 9 },
			{ dur = 100; num = 10 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}
