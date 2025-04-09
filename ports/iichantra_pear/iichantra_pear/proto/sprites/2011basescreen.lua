--forbidden
texture = "2011lab3";

z = -.2;

animations = 
{
	{ 
		name = "good";
		frames = 
		{
			{ dur = 100; num = 68 },
			{ dur = 100; com = constants.AnimComSetInvisible; param = 1 },
			{ dur = 100; num = 68; com = constants.AnimComSetInvisible; param = 0 },
			{ dur = 100; com = constants.AnimComSetInvisible; param = 1 },
			{ dur = 100; num = 68; com = constants.AnimComSetInvisible; param = 0 },
			{ dur = 100; com = constants.AnimComSetInvisible; param = 1 },
			{ dur = 100; num = 68; com = constants.AnimComSetInvisible; param = 0 },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{ 
		name = "bad";
		frames = 
		{
			{ dur = 100; num = 69 },
			{ dur = 100; com = constants.AnimComSetInvisible; param = 1 },
			{ dur = 100; num = 69; com = constants.AnimComSetInvisible; param = 0 },
			{ dur = 100; com = constants.AnimComSetInvisible; param = 1 },
			{ dur = 100; num = 69; com = constants.AnimComSetInvisible; param = 0 },
			{ dur = 100; com = constants.AnimComSetInvisible; param = 1 },
			{ dur = 100; num = 69; com = constants.AnimComSetInvisible; param = 0 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}
