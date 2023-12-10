--forbidden
name = "flash-angle-up-spread";
texture = "flash-angle";
FunctionName = "CreateSprite";

physic = 1;
phys_ghostlike = 1;

z = 0.0;
image_width = 512;
image_height = 128;
frame_width = 128;
frame_height = 64;
frames_count = 7;
effect = 1;

local dx = 10;
local dy = 0;

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
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = -45 },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComAngledShot; txt = "spread-bullet" },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = -68 },
			{ com = constants.AnimComPushInt; param = 3 },
			{ com = constants.AnimComAngledShot; txt = "spread-bullet" },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = -23 },
			{ com = constants.AnimComPushInt; param = 1 },
			{ com = constants.AnimComAngledShot; txt = "spread-bullet" },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = -90 },
			{ com = constants.AnimComPushInt; param = 4 },
			{ com = constants.AnimComAngledShot; txt = "spread-bullet" },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "spread-bullet" },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 2 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}
