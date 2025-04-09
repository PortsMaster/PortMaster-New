texture = "2011block";

z = -0.68;

animations =
{
	{
		name = "idle";
		frames =
		{
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealH; param = 153 },
			{ com = constants.AnimComRealW; param = 35 },
			{ dur = 100; num = 0 },
			{ dur = 100; num = 1 },
			{ dur = 100; num = 2 },
			{ com = constants.AnimComLoop }
		}
	},
	{
		name = "off";
		frames =
		{
			{ com = constants.AnimComRealY; param = -108 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 108 },
			{ dur = constants.AnimComCreateSprite; txt = "2011-block2" },
			{ dur = 100; num = 3 },
		}
	},
}
