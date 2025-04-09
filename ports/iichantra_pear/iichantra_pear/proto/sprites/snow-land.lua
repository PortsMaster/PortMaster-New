texture = "snoweffects";

z = 0.25;

animations = 
{
	{ 
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComRealY; param = -75 },
			{ com = constants.AnimComRealX; param = -42 },
			{ dur = 100; num = 0 },
			{ dur = 100; num = 1 },
			{ dur = 100; num = 2 },
			{ dur = 100; num = 3 },
			
			{ com = constants.AnimComDestroyObject }
		}
	}
}
