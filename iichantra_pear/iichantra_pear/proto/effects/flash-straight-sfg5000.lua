--forbidden
name = "flash-straight-sfg5000";
texture = "flash-straight-sfg5000";
FunctionName = "CreateSprite";

physic = 1;
phys_ghostlike = 1;

z = 0.0;
image_width = 512;
image_height = 32;
frame_width = 128;
frame_height = 32;
frames_count = 3;
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
			{ com = constants.AnimComRealH; param = 15 },
			{ dur = 50; num = 0 },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 2 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}
