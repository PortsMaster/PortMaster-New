--forbidden
name = "twinshot";

reload_time = 170;
bullets_per_shot = 1;
shots_per_clip = 6;
clip_reload_time = 200;
damage_type = 2;

push_force = 3.0;

-- Описание пули
bullet_damage = 45;
bullet_vel = 6;

-- Описание спрайта пули
texture = "twinshot";
overlay = {0};

z = -0.002;

image_width = 256;
image_height = 64;
frame_width = 64;
frame_height = 32;
frames_count = 7;

-- просто переменая, такое тоже можно
local sound_shoot = "weapons/doubleshot.ogg"

animations = 
{
	{
		-- Пуля, летящая прямо
		name = "straight";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 11 },
			{ com = constants.AnimComRealX; param = 30 },
			{ com = constants.AnimComRealY; param = -1 },
			{ com = constants.AnimComPlaySound; txt = sound_shoot; param = 1 },
			{ dur = 1; num = 0; com = constants.AnimComRealH; param = 7 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -8 },
			{ com = constants.AnimComCreateEffect; txt ="flash-straight"; param = 13 },
			{ dur = 50; num = 0; com = constants.AnimComRealH; param = 7 },
			{ dur = 50; num = 3; com = constants.AnimComRealY; param = 9},
			{ dur = 50; num = 4; com = constants.AnimComRealY; param = 18},
			{ dur = 50; num = 5; com = constants.AnimComRealY; param = 20},
			{ com = constants.AnimComPushInt; param = 0},
			{ com = constants.AnimComPushInt; param = 0},
			{ com = constants.AnimComPushInt; param = -18},
			{ com = constants.AnimComPushInt; param = 0},
			{ com = constants.AnimComPushInt; param = 0},
			{ com = constants.AnimComAngledShot; txt = "twinshot_bullet" },
			{ com = constants.AnimComPushInt; param = 0},
			{ com = constants.AnimComPushInt; param = 0},
			{ com = constants.AnimComPushInt; param = 18},
			{ com = constants.AnimComPushInt; param = 0},
			{ com = constants.AnimComPushInt; param = 0},
			{ com = constants.AnimComAngledShot; txt = "twinshot_bullet" },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{
		-- Пуля, летящая по диагонали вниз
		name = "diagdown";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 18 },
			{ com = constants.AnimComRealY; param = 24 },
			{ com = constants.AnimComRealW; param = 11 },
			{ com = constants.AnimComPlaySound; txt = sound_shoot; param = 1 },
			{ dur = 1; num = 1; com = constants.AnimComRealH; param = 7 },
			{ com = constants.AnimComPushInt; param = -3 },
			{ com = constants.AnimComPushInt; param = -34 },
			{ com = constants.AnimComCreateEffect; txt ="flash-angle-down"; param = 13 },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 6 },
			{ dur = 50; num = 7 },
			{ dur = 0; num = 11; com = constants.AnimComRealX; param = 15 },
			{ dur = 50; num = 8; com = constants.AnimComRealY; param = 15 },
			{ com = constants.AnimComPushInt; param = 0},
			{ com = constants.AnimComPushInt; param = 9},
			{ com = constants.AnimComPushInt; param = -18},
			{ com = constants.AnimComPushInt; param = 45},
			{ com = constants.AnimComPushInt; param = -2},
			{ com = constants.AnimComAngledShot; txt = "twinshot_bullet" },
			{ com = constants.AnimComPushInt; param = 0},
			{ com = constants.AnimComPushInt; param = -9},
			{ com = constants.AnimComPushInt; param = 18},
			{ com = constants.AnimComPushInt; param = 45},
			{ com = constants.AnimComPushInt; param = -2},
			{ com = constants.AnimComAngledShot; txt = "twinshot_bullet" },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "diagup";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 18 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 11 },
			{ com = constants.AnimComPlaySound; txt = sound_shoot; param = 1 },
			{ dur = 1; num = 2; com = constants.AnimComRealH; param = 7 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -10 },
			{ com = constants.AnimComCreateEffect; txt ="flash-angle-up"; param = 13 },
			{ dur = 50; num = 2 },
			{ dur = 50; num = 9 },
			{ dur = 50; num = 10 },
			{ dur = 0; num = 11; com = constants.AnimComRealX; param = 15 },
			{ dur = 50; num = 11; com = constants.AnimComRealY; param = 15 },
			{ com = constants.AnimComPushInt; param = 0},
			{ com = constants.AnimComPushInt; param = 9},
			{ com = constants.AnimComPushInt; param = -18},
			{ com = constants.AnimComPushInt; param = -45},
			{ com = constants.AnimComPushInt; param = 2},
			{ com = constants.AnimComAngledShot; txt = "twinshot_bullet" },
			{ com = constants.AnimComPushInt; param = 0},
			{ com = constants.AnimComPushInt; param = 18},
			{ com = constants.AnimComPushInt; param = 18},
			{ com = constants.AnimComPushInt; param = -45},
			{ com = constants.AnimComPushInt; param = 2},
			{ com = constants.AnimComAngledShot; txt = "twinshot_bullet" },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{
		--Пуля попала в неподвижный объект.
		name = "miss";
		frames =
		{
			{ com = constants.AnimComStartDying },
			{ com = constants.AnimComSetAnim; txt = "die" }
		}
	},
	{
		-- Уничтожение пули
		name = "die";
		frames = 
		{
			{ com = constants.AnimComStop },
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 6 },
			{ com = constants.AnimComRealH; param = 6 },
			{ dur = 100; num = 12 },
			{ com = constants.AnimComRealX; param = 5 },
			{ com = constants.AnimComRealY; param = 5 },
			{ dur = 100; num = 13 },
			{ dur = 100; num = 14 },
			{ com = constants.AnimComRealX; param = 6 },
			{ com = constants.AnimComRealY; param = 6 },
			{ dur = 100; num = 15 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}