--forbidden
name = "flash-angle-down";
texture = "flash-angle";
FunctionName = "CreateSprite";

z = 0.0;
image_width = 512;
image_height = 128;
frame_width = 128;
frame_height = 64;
frames_count = 7;
physic = 1;
phys_ghostlike = 1;
effect = 1;

animations = 
{
	{ 
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 64 },
			{ com = constants.AnimComRealY; param = 1 },
			{ com = constants.AnimComRealW; param = 1 },
			{ com = constants.AnimComRealH; param = 1 },
			{ dur = 50; num = 3 },
			{ dur = 50; num = 4 },
			{ dur = 50; num = 5 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}
