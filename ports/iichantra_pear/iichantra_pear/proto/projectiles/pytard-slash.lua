--forbidden
name = "btard-punch";
FunctionName = "CreateBullet";
hurts_same_type = 1;

z = 0.25;
image_width = 1024;
image_height = 1024;
frame_width = 256;
frame_height = 128;
frames_count = 28;
bullet_damage = 80;
pish_force = 2.0*difficulty;
--bullet_damage = 0;
bullet_vel = 1;

animations = 
{
	{ 
		name = "straight";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 127 },
			{ com = constants.AnimComRealW; param = 32 },
			{ com = constants.AnimComRealH; param = 32 },
			{ dur = 600 },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{ 
		name = "diagdown";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 128 },
			{ com = constants.AnimComRealY; param = 128 },
			{ com = constants.AnimComRealW; param = 128 },
			{ com = constants.AnimComRealH; param = 0 },
			{ dur = 100 },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{ 
		name = "diagup";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 128 },
			{ com = constants.AnimComRealY; param = 128 },
			{ com = constants.AnimComRealW; param = 128 },
			{ com = constants.AnimComRealH; param = 0 },
			{ dur = 100 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}
