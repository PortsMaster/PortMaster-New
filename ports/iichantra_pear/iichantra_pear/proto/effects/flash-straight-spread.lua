--forbidden
name = "flash-straight-spread";
texture = "flash-straight";
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

local dx = 0;
local dy = 12;

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
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "spread-bullet" },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = -23 },
			{ com = constants.AnimComPushInt; param = 1 },
			{ com = constants.AnimComAngledShot; txt = "spread-bullet" },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = 23 },
			{ com = constants.AnimComPushInt; param = -1 },
			{ com = constants.AnimComAngledShot; txt = "spread-bullet" },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = -45 },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComAngledShot; txt = "spread-bullet" },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = 45 },
			{ com = constants.AnimComPushInt; param = -2 },
			{ com = constants.AnimComAngledShot; txt = "spread-bullet" },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 2 },
			{ com = constants.AnimComDestroyObject; param = 1}
		}
	}
}
