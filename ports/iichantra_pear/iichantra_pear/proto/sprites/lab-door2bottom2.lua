name = "lab-door2bottom2";
texture = "lab-door2";
FunctionName = "CreateSprite";

z = -0.5;

physic = 1;
phys_solid = 1;
phys_one_sided = 0;
phys_bullet_collidable = 1;

ghost_to = 8;

animations = 
{
	{
		name = "idle";
		frames =
		{
			{ com = constants.AnimComInitH; param = 64 },
			{ com = constants.AnimComRealH; param = 9 },
			{ dur = 50; num = 18 },
			{ com = constants.AnimComRealH; param = 12 },
			{ dur = 50; num = 17 },
			{ com = constants.AnimComRealH; param = 15 },
			{ dur = 50; num = 16 },
			{ com = constants.AnimComRealH; param = 19 },
			{ dur = 50; num = 15 },
			{ com = constants.AnimComRealH; param = 25 },
			{ dur = 50; num = 14 },
			{ com = constants.AnimComRealH; param = 30 },
			{ dur = 50; num = 13 },
			{ com = constants.AnimComRealH; param = 39 },
			{ dur = 50; num = 12 },
			{ com = constants.AnimComRealH; param = 46 },
			{ dur = 50; num = 11 },
			{ com = constants.AnimComRealH; param = 56 },
			{ dur = 50; num = 10 },
			{ com = constants.AnimComRealH; param = 64 },
			{ dur = 50; num = 9 },
			{ com = constants.AnimComDestroyObject}
		}
	}
}
