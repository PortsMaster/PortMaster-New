--forbidden
texture = "2011lab4";

z = -.2;

animations = 
{
	{ 
		name = "normal";
		frames = 
		{
			{ com = constants.AnimComPlaySound; txt = "lab-door.ogg" },
			{ dur = 100; num = 0 },
			{ dur = 200; num = 1 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{ 
		name = "wc";
		frames = 
		{
			{ com = constants.AnimComPlaySound; txt = "lab-door.ogg" },
			{ dur = 100; num = 2 },
			{ dur = 200; num = 1 },
			{ dur = 100; num = 2 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}
