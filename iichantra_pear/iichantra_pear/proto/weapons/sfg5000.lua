--forbidden
name = "sfg5000";

reload_time = 190;
clip_reload_time = 190;
shots_per_clip = 3;
bullets_per_shot = 0;
damage_type = 2;

push_force = 3.0;

-- Описание пули
bullet_damage = 15;
bullet_vel = 15;

-- Описание спрайта пули
texture = "bullets-sfg5000";

z = -0.002;

image_width = 256;
image_height = 64;
frame_width = 64;
frame_height = 32;
frames_count = 7;

-- просто переменая, такое тоже можно
local sound_shoot = "weapons/blaster_shot.ogg"

animations = 
{
	{
		-- Пуля, летящая прямо
		name = "straight";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 38 },
			{ com = constants.AnimComRealY; param = 12 },
			{ com = constants.AnimComRealW; param = 11 },
			{ com = constants.AnimComPlaySound; txt = sound_shoot; param = 1 },
			{ dur = 1; num = 0; com = constants.AnimComRealH; param = 7 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -8 },
			{ com = constants.AnimComCreateEffect; txt ="flash-straight-sfg5000"; param = 13 },
			{ dur = 100; num = 0; com = constants.AnimComRealH; param = 5 },
		}
	},
	{
		-- Пуля, летящая по диагонали вниз
		name = "diagdown";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 37 },
			{ com = constants.AnimComRealY; param = 21 },
			{ com = constants.AnimComRealW; param = 9 },
			{ com = constants.AnimComPlaySound; txt = sound_shoot; param = 1 },
			{ dur = 1; num = 1; com = constants.AnimComRealH; param = 7 },
			{ com = constants.AnimComPushInt; param = -3 },
			{ com = constants.AnimComPushInt; param = -34 },
			{ com = constants.AnimComCreateEffect; txt ="flash-angle-down-sfg5000"; param = 13 },
			{ dur = 100; num = 1; com = constants.AnimComRealH; param = 9 },
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "diagup";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 37 },
			{ com = constants.AnimComRealY; param = 2 },
			{ com = constants.AnimComRealW; param = 9 },
			{ com = constants.AnimComPlaySound; txt = sound_shoot; param = 1 },
			{ dur = 1; num = 2; com = constants.AnimComRealH; param = 7 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -10 },
			{ com = constants.AnimComCreateEffect; txt ="flash-angle-up-sfg5000"; param = 13 },
			{ com = constants.AnimComPlaySound; txt = sound_shoot },
			{ dur = 100; num = 2; com = constants.AnimComRealH; param = 9 },
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
			{ com = constants.AnimComRealX; param = 38 },
			{ com = constants.AnimComRealY; param = 12 },
			{ com = constants.AnimComRealW; param = 11 },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComPushInt; param = 100 },
			{ dur = 100; num = 4 },
			{ dur = 100; num = 5 },
			{ dur = 100; num = 6 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}