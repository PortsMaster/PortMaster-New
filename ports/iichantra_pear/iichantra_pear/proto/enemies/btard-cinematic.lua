parent = "enemies/btard";

faction_id = -3;
faction_hates = {};
animations =
{
	{ 
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 36 },
			{ com = constants.AnimComRealH; param = 75 },
			{ dur = 100; num = 0; },
			{ dur = 100; num = 1; },
			{ dur = 100; num = 2; },
			{ dur = 100; num = 3; },
			{ dur = 100; num = 4; },
			{ com = constants.AnimComLoop }	
		}
	},
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 36 },
			{ com = constants.AnimComRealH; param = 75 },
			{ com = constants.AnimComSetHealth; param = 20*difficulty },
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComControlledOverlayColor },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{
		name = "turn";
		frames =
		{
			{ com = constants.AnimComMirror },
			{ com = constants.AnimComSetAnim; txt = "idle" }
		}
	},
	{
		name = "move_left";
		frames = 
		{
			{ com = constants.AnimComSetAccX; param = -500 },
			{ dur = 0 },
			{ com = constants.AnimComRealX; param = 11 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 36 },
			{ com = constants.AnimComRealH; param = 75 },
			{ com = constants.AnimComEnvSound; param = 1},
			{ dur = 100; num = 5; },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 6; },
			{ com = constants.AnimComRealX; param = 6 },
			{ dur = 100; num = 7; },
			{ com = constants.AnimComRealX; param = 18 },
			{ com = constants.AnimComEnvSound; },
			{ dur = 100; num = 8;},
			{ com = constants.AnimComRealX; param = 12 },
			{ dur = 100; num = 9; },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 10; },
			{ com = constants.AnimComLoop }	
		}
	}
}