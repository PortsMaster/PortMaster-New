parent = "enemies/btard-com"

faction_id = -3
faction_hates = {}

animations =
{
	{ 
		-- Создание
		name = "move";
		frames = 
		{
			{ com = constants.AnimComSetAccX; param = 1000 },
			{ com = constants.AnimComRealX; param = 11 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 36 },
			{ com = constants.AnimComRealH; param = 75 },
			{ dur = 100; num = 5},
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 6},
			{ com = constants.AnimComRealX; param = 6 },
			{ dur = 100; num = 7},
			{ com = constants.AnimComRealX; param = 18 },
			{ dur = 100; num = 8},
			{ com = constants.AnimComRealX; param = 12 },
			{ dur = 100; num = 9},
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 10},
			{ com = constants.AnimComLoop }
		}
	},
	{ 
		-- Создание
		name = "move_left";
		frames = 
		{
			{ com = constants.AnimComSetAccX; param = -500 },
			{ com = constants.AnimComRealX; param = 11 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 36 },
			{ com = constants.AnimComRealH; param = 75 },
			{ dur = 100; num = 5},
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 6},
			{ com = constants.AnimComRealX; param = 6 },
			{ dur = 100; num = 7},
			{ com = constants.AnimComRealX; param = 18 },
			{ dur = 100; num = 8},
			{ com = constants.AnimComRealX; param = 12 },
			{ dur = 100; num = 9},
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 10},
			{ com = constants.AnimComLoop }
		}
	},
	{
		name = "attack";
		frames =
		{
			{ com = constants.AnimComStop; },
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 34 },
			{ com = constants.AnimComRealH; param = 81 },
			{ com = constants.AnimComFaceTarget },
			{ dur = 100; num = 11 },
			{ com = constants.AnimComRealW; param = 68 },
			{ com = constants.AnimComRealH; param = 78 },
			{ dur = 100; num = 12 },
			{ com = constants.AnimComRealH; param = 77 },
			{ dur = 100; num = 13 },
			{ com = constants.AnimComRealH; param = 69 },
			{ com = constants.AnimComPushInt; param = 50 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComRealH; param = 68 },
			{ dur = 100; num = 15 },
			{ com = constants.AnimComRealH; param = 78 },
			{ dur = 400; num = 16 },
			{ com = constants.AnimComSetAnim; txt = "idle" }
		}
	},
	{
		name = "land";
		frames =
		{
			{ com = constants.AnimComSetAnim; txt = "idle" }
		}
	}
}
