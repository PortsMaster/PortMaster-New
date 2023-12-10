--forbidden
name = "flash-angle-up-sfg5000";
texture = "flash-angle-sfg5000";
FunctionName = "CreateSprite";

z = 0.0;
image_width = 512;
image_height = 128;
frame_width = 128;
frame_height = 64;
frames_count = 7;
effect = 1;
physic = 1;
phys_ghostlike = 1;

animations = 
{
	{ 
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 64 },
			{ com = constants.AnimComRealY; param = 15 },
			{ com = constants.AnimComRealW; param = 1 },
			{ com = constants.AnimComRealH; param = 15 },
			{ dur = 50; num = 0 },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 2 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}
