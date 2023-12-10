name = "lab-door2";
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
			{ com = constants.AnimComInitH; param = 126 },
			{ com = constants.AnimComRealW; param = 30 },
			{ com = constants.AnimComPushInt; param = -1 },
			{ com = constants.AnimComSetAnim; txt = "open-stay" }
		}
	},
	{
		name = "open-stay";
		frames =
		{
			{ dur = 5000; num = 0 },
		}
	},
	{
		name = "open";
		frames =
		{
			{ com = constants.AnimComPlaySound; txt = "lab-door.ogg" },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 2 },
			{ com = constants.AnimComPushInt; param = -15 },
			--{ com = constants.AnimComPushInt; param = 34 },
			{ com = constants.AnimComPushInt; param = -30 },
			{ com = constants.AnimComCreateObject; txt = "lab-door2bottom" },
			{ com = constants.AnimComInitH; param = 59 },
			{ dur = 50; num = 3 },
			{ com = constants.AnimComInitH; param = 52 },
			{ dur = 50; num = 4 },
			{ com = constants.AnimComInitH; param = 42 },
			{ dur = 50; num = 5 },
			{ com = constants.AnimComInitH; param = 32 },
			{ dur = 50; num = 6 },
			{ com = constants.AnimComInitH; param = 25 },
			{ dur = 50; num = 7 },
			{ com = constants.AnimComInitH; param = 18 },
			{ dur = 5000; num = 8 },
		}
	},
	{
		name = "close";
		frames =
		{
			{ com = constants.AnimComPlaySound; txt = "lab-door.ogg" },
			{ com = constants.AnimComPushInt; param = -30 },
			{ com = constants.AnimComPushInt; param = 34 },
			{ com = constants.AnimComCreateObject; txt = "lab-door2bottom2" },
			{ dur = 200; num = 8 },
			{ com = constants.AnimComInitH; param = 25 },
			{ dur = 50; num = 7 },
			{ com = constants.AnimComInitH; param = 32 },
			{ dur = 50; num = 6 },
			{ com = constants.AnimComInitH; param = 42 },
			{ dur = 50; num = 5 },
			{ com = constants.AnimComInitH; param = 52 },
			{ dur = 50; num = 4 },
			{ com = constants.AnimComInitH; param = 59 },
			{ dur = 50; num = 3 },
			{ com = constants.AnimComInitH; param = 126 },
			{ dur = 50; num = 2 },
			{ dur = 50; num = 1 },
			{ com = constants.AnimComSetAnim; txt = "open-stay" }
		}
	}
}
