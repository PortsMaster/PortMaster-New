name = "portrait-soh";
texture = "portrait-soh";
FunctionName = "CreateSprite";

z = 0.999;

animations = 
{
	{
		name = "left";
		frames =
		{
			{ dur = 100; num = 0 },
			{ com = constants.AnimComLoop }
		}
	},
	{
		name = "right";
		frames =
		{
			{ com = constants.AnimComMirror },
			{ dur = 100; num = 0 }
		}
	}
}
