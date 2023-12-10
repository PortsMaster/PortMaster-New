--forbidden
name = "flamer";

reload_time = 0.5;
bullets_per_shot = 1;
can_hit_multiple_targets = 1;


-- Описание пули
bullet_damage = 60;
bullet_vel = 2;

-- Описание спрайта пули
texture = "flamer";

z = -0.001;

image_width = 256;
image_height = 32;
frame_width = 32;
frame_height = 32;
frames_count = 8;
z = -0.002;

animations = 
{
	{
		-- Пуля, летящая прямо
		name = "straight";
		frames = 
		{
			{ com = constants.AnimComPlaySound; txt = "weapons/flame.ogg"; param = 1 },
			{ com = constants.AnimComRealX; param = 16 },
			{ com = constants.AnimComRealY; param = 12 },
			{ com = constants.AnimComRealW; param = 9 },
			{ com = constants.AnimComRealH; param = 8 },
			{ dur = 30; num = 0 },
			{ com = constants.AnimComRealX; param = 12 },
			{ com = constants.AnimComRealY; param = 14 },
			{ com = constants.AnimComRealW; param = 15 },
			{ com = constants.AnimComRealH; param = 12 },
			{ dur = 30; num = 1 },
			{ com = constants.AnimComRealX; param = 10 },
			{ com = constants.AnimComRealY; param = 8 },
			{ com = constants.AnimComRealW; param = 20 },
			{ com = constants.AnimComRealH; param = 18 },
			{ dur = 30; num = 2 },
			{ com = constants.AnimComRealX; param = 9 },
			{ com = constants.AnimComRealY; param = 7 },
			{ com = constants.AnimComRealW; param = 21 },
			{ com = constants.AnimComRealH; param = 19 },
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComJumpRandom; param = 31 },
			{ dur = 30; num = 3 },
			{ dur = 30; num = 4 },
			{ dur = 30; num = 5 },
			{ com = constants.AnimComRealX; param = 4 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 32 },
			{ com = constants.AnimComRealH; param = 24 },
			{ dur = 60; num = 6 },
			{ dur = 60; num = 7 },
			{ com = constants.AnimComDestroyObject },
			{ dur = 30; num = 5 },
			{ dur = 30; num = 4 },
			{ dur = 30; num = 3 },
			{ com = constants.AnimComRealX; param = 4 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 32 },
			{ com = constants.AnimComRealH; param = 24 },
			{ dur = 60; num = 6 },
			{ dur = 60; num = 7 },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{
		-- Пуля, летящая по диагонали вниз
		name = "diagdown";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "straight" }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "diagup";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "straight" }
		}
	},
	{
		--Пуля попала в неподвижный объект.
		name = "miss";
		frames =
		{
			{ com = constants.AnimComStartDying },
			{ com = constants.AnimComStop },
			{ com = constants.AnimComSetMaxVelY; param = 10000 },
			{ com = constants.AnimComRealX; param = 5 },
			{ com = constants.AnimComRealY; param = 7 },
			{ com = constants.AnimComRealW; param = 21 },
			{ com = constants.AnimComRealH; param = 19 },
			{ dur = 100; num = 8 },
			{ dur = 100; num = 9 },
			{ dur = 100; num = 10 },
			{ dur = 100; num = 11 },
			{ dur = 100; num = 8 },
			{ dur = 100; num = 9 },
			{ dur = 100; num = 10 },
			{ dur = 100; num = 11 },
			{ dur = 100; num = 8 },
			{ dur = 100; num = 9 },
			{ dur = 100; num = 10 },
			{ dur = 100; num = 11 },
			{ dur = 100; num = 8 },
			{ dur = 100; num = 9 },
			{ com = constants.AnimComSetAnim; txt = "die" }
		}
	},
	{
		--Уничтожение
		name = "die";
		frames =
		{
			{ com = constants.AnimComStartDying },
			{ com = constants.AnimComStop },
			{ com = constants.AnimComSetMaxVelY; param = 10000 },
			{ com = constants.AnimComRealX; param = 5 },
			{ com = constants.AnimComRealY; param = 7 },
			{ com = constants.AnimComRealW; param = 21 },
			{ com = constants.AnimComRealH; param = 19 },
			{ dur = 100; num = 8 },
			{ dur = 100; num = 9 },
			{ dur = 100; num = 10 },
			{ dur = 100; num = 11 },
			{ dur = 100; num = 8 },
			{ dur = 100; num = 9 },
			{ dur = 100; num = 10 },
			{ dur = 100; num = 11 },
			{ dur = 100; num = 8 },
			{ dur = 100; num = 9 },
			{ dur = 100; num = 10 },
			{ dur = 100; num = 11 },
			{ dur = 100; num = 8 },
			{ dur = 100; num = 9 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}