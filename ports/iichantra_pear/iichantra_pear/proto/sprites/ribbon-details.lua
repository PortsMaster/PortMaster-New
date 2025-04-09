texture = "ribbon-details"
z = -0.99;

animations =
{
	{
		name = "hangman";
		frames =
		{
			{ num = 0; dur = 160; com = constants.AnimComRealX; param = 0 },
			{ num = 10; dur = 160; com = constants.AnimComRealX; param = -3 },
			{ num = 11; dur = 160; com = constants.AnimComRealX; param = -4 },
			{ num = 12; dur = 160; com = constants.AnimComRealX; param = -4 },
			{ num = 13; dur = 160; com = constants.AnimComRealX; param = -3 },
			{ num = 14; dur = 160; com = constants.AnimComRealX; param = -2 },
			{ num = 15; dur = 160; com = constants.AnimComRealX; param = -1 },
			{ num = 16; dur = 160; com = constants.AnimComRealX; param = 2 },
			{ num = 17; dur = 160; com = constants.AnimComRealX; param = 1 },
			{ num = 18; dur = 160; com = constants.AnimComRealX; param = 2 },
			{ num = 19; dur = 160; com = constants.AnimComRealX; param = 3 },
			{ num = 20; dur = 160; com = constants.AnimComRealX; param = 1 },
			{ num = 21; dur = 160; com = constants.AnimComRealX; param = 0 },
			{ num = 22; dur = 160; com = constants.AnimComRealX; param = -1 },
			{ com = constants.AnimComLoop }
		}
	},
	{
		name = "owl";
		frames =
		{
			{ num = 1; dur = 160; },
			{ num = 23; dur = 160; },
			{ num = 24; dur = 340; },
			{ num = 23; dur = 160; },
			{ num = 1; dur = 1600; },
			{ com = constants.AnimComLoop }
		}
	},
	{
		name = "branch";
		frames =
		{
			{ num = 2 }
		}
	},
	{
		name = "smile";
		frames =
		{
			{ dur = 800; num = 3 },
			{ dur = 100; num = 4 },
			{ dur = 100; num = 5 },
			{ dur = 100; num = 6 },
			{ dur = 100; num = 7 },
			{ dur = 100; num = 8 },
			{ dur = 800; num = 9 },
			{ dur = 100; num = 8 },
			{ dur = 100; num = 7 },
			{ dur = 100; num = 6 },
			{ dur = 100; num = 5 },
			{ dur = 100; num = 4 },
			{ com = constants.AnimComLoop }
		}
	}
}