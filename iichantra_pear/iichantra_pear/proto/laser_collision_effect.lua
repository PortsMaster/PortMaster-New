--forbidden
name = "laser_collision_effect";

texture = "twinshot";
phys_bullet_collidable = 0;

z = 1;


frames_count = 1;

animations = 
{
	{
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComInitW; param = 3 },
			{ com = constants.AnimComRealX; param = -2 },
			{ com = constants.AnimComRealY; param = 3 },
			{ dur = 100; num = 12; com = constants.AnimComRealH; param = 3 },
			{ com = constants.AnimComRealW; param = 8 },
			{ com = constants.AnimComRealX; param = 3 },
			{ com = constants.AnimComRealY; param = 8 },
			{ dur = 100; num = 13 },
			{ dur = 100; num = 14; },
			{ com = constants.AnimComRealW; param = 9 },
			{ com = constants.AnimComRealX; param = 4 },
			{ com = constants.AnimComRealY; param = 9 },
			{ dur = 100; num = 15 },
			{ com = constants.AnimComDestroyObject }
		}
	}
};