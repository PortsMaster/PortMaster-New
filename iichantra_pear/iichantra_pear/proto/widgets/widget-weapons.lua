--forbidden
name = "widget-weapons";
texture = "weapons";
FunctionName = "CreateSprite";

z = 0;
image_width = 128;
image_height = 512;
frames_count = 58;

animations =
{
	{
		name = "grenades";
		frames =
		{
			{ dur = 50; num = 7 },
			{ dur = 50; num = 8 },
			{ dur = 50; num = 9 },
			{ dur = 50; num = 10 },
			{ dur = 50; num = 11 },
			{ dur = 50; num = 12 },
			{ dur = 50; num = 9 },
			{ dur = 50; num = 13 },
			{ com = constants.AnimComLoop }
		}
	},
	{
	
		name = "flamer";
		frames =
		{
			{ dur = 50; num = 27 },
			{ dur = 50; num = 21 },
			{ dur = 50; num = 22 },
			{ dur = 50; num = 23 },
			{ dur = 50; num = 24 },
			{ dur = 50; num = 25 },
			{ dur = 50; num = 22 },
			{ dur = 50; num = 26 },
			{ com = constants.AnimComLoop }
		}
	},
	{
	
		name = "machinegun";
		frames =
		{
			{ dur = 50; num = 64 },
			{ dur = 50; num = 65 },
			{ dur = 50; num = 66 },
			{ dur = 50; num = 67 },
			{ dur = 50; num = 68 },
			{ dur = 50; num = 69 },
			{ dur = 50; num = 66 },
			{ dur = 50; num = 70 },
			{ com = constants.AnimComLoop }
		}
	},
	{
	
		name = "spread";
		frames =
		{
			{ dur = 50; num = 50 },
			{ dur = 50; num = 51 },
			{ dur = 50; num = 52 },
			{ dur = 50; num = 53 },
			{ dur = 50; num = 54 },
			{ dur = 50; num = 55 },
			{ dur = 50; num = 52 },
			{ dur = 50; num = 56 },
			{ com = constants.AnimComLoop }
		}
	},
	{
	
		name = "rocketlauncher";
		frames =
		{
			{ dur = 50; num = 36 },
			{ dur = 50; num = 37 },
			{ dur = 50; num = 38 },
			{ dur = 50; num = 39 },
			{ dur = 50; num = 40 },
			{ dur = 50; num = 41 },
			{ dur = 50; num = 38 },
			{ dur = 50; num = 42 },
			{ com = constants.AnimComLoop }
		}
	}
}
