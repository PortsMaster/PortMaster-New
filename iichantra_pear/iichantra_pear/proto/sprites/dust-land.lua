--forbidden
name = "dust-land";
texture = "dust-land";
FunctionName = "CreateSprite";

z = 0.25;
image_width = 512;
image_height = 128;
frame_width = 128;
frame_height = 64;
frames_count = 6;

animations = 
{
	{ 
		name = "idle";
		frames = 
		{
			{ dur = 100; num = 0 },
			{ dur = 100; num = 1 },
			{ dur = 100; num = 2 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 4 },
			{ dur = 100; num = 5 },
			
			{ com = constants.AnimComDestroyObject }
		}
	}
}
