--forbidden
name = "dust-run2";
texture = "dust-run";
FunctionName = "CreateSprite";

z = 0.25;
image_width = 256;
image_height = 128;
frame_width = 64;
frame_height = 64;
frames_count = 7;

animations = 
{
	{ 
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealW; param = 64 },	
			{ dur = 200; num = 0 },
			{ dur = 200; num = 1 },
			{ dur = 200; num = 2 },
			{ dur = 200; num = 3 },
			{ dur = 200; num = 4 },
			{ dur = 200; num = 5 },
			{ dur = 200; num = 6 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}
