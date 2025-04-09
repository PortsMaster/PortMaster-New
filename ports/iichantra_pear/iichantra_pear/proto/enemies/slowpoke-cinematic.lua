parent = "enemies/slowpoke"

faction_id = -3

animations =
{
	{
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 86; },
			{ com = constants.AnimComRealH; param = 46; },
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComSetHealth; param = health; },
			{ com = constants.AnimComSetTouchable; param = 0; },
			{ com = constants.AnimComSetAnim; txt = "idle"; }
		}
	},
	{
		name = "idle";
		frames =
		{
			{ dur = 100; num = 0 }
		}
	},
	{
		name = "land";
		frames =
		{
			{ com = constants.AnimComSetAnim; txt = "idle" }
		}
	},
	{
		name = "sleep";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 10; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 86; },
			{ dur = 100; num = 48; com = constants.AnimComRealH; param = 41; },
			{ com = constants.AnimComRealX; param = 15; },
			{ dur = 100; num = 49; com = constants.AnimComRealH; param = 37; },
			{ dur = 100; num = 50; com = constants.AnimComRealH; param = 34; },
			{ dur = 300; num = 51; com = constants.AnimComRealH; param = 29; },
			{ dur = 300; num = 52; },
			{ dur = 300; num = 53; },
			{ dur = 900; num = 54; },
			{ dur = 300; num = 53; },
			{ dur = 300; num = 52; },
			{ dur = 900; num = 51; },
			{ dur = 300; num = 52; },
			{ dur = 300; num = 53; },
			{ dur = 900; num = 54; },
			{ dur = 300; num = 53; },
			{ dur = 300; num = 52; },
			{ dur = 900; num = 51; },
			{ com = constants.AnimComJump; param = 9; }
		}
	}
}