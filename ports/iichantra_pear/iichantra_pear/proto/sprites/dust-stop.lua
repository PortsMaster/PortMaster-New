--forbidden
name = "dust-stop";
texture = "dust-stop";
FunctionName = "CreateSprite";

z = 0.25;
image_width = 256;
image_height = 64;
frame_width = 64;
frame_height = 64;
frames_count = 4;

animations = 
{
	{ 
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 25 },
			{ com = constants.AnimComRealW; param = 32 },	
			{ dur = 100; num = 0 },
			{ dur = 100; num = 1 },
			{ dur = 100; num = 2 },
			{ dur = 100; num = 3 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}
