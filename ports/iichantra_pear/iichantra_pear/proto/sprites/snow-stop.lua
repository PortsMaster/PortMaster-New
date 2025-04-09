texture = "snoweffects";
z = 0.25;
animations = 
{
	{ 
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 25 },
			{ com = constants.AnimComRealY; param = -45 },
			{ com = constants.AnimComRealW; param = 32 },	
			{ dur = 100; num = 11 },
			{ dur = 100; num = 12 },
			{ dur = 100; num = 13 },
			{ dur = 100; num = 14 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}
