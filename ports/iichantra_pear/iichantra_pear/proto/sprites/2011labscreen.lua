--forbidden
texture = "2011lab2";

z = -.2;

animations = 
{
	{ 
		name = "fail";
		frames = 
		{
			{ dur = 100; num = 1 },
			{ dur = 100; com = constants.AnimComSetInvisible; param = 1 },
			{ dur = 100; num = 1; com = constants.AnimComSetInvisible; param = 0 },
			{ dur = 100; com = constants.AnimComSetInvisible; param = 1 },
			{ dur = 100; num = 1; com = constants.AnimComSetInvisible; param = 0 },
			{ dur = 100; com = constants.AnimComSetInvisible; param = 1 },
			{ dur = 100; num = 1; com = constants.AnimComSetInvisible; param = 0 },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{ 
		name = "denied";
		frames = 
		{
			{ dur = 100; num = 2 },
			{ dur = 100; com = constants.AnimComSetInvisible; param = 1 },
			{ dur = 100; num = 2; com = constants.AnimComSetInvisible; param = 0 },
			{ dur = 100; com = constants.AnimComSetInvisible; param = 1 },
			{ dur = 100; num = 2; com = constants.AnimComSetInvisible; param = 0 },
			{ dur = 100; com = constants.AnimComSetInvisible; param = 1 },
			{ dur = 100; num = 2; com = constants.AnimComSetInvisible; param = 0 },
			{ com = constants.AnimComDestroyObject }
		}
	},
}
