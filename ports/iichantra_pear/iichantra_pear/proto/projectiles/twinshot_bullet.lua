--forbidden
name = "twinshot_bullet";

push_force = 1.0;

reload_time = 150;
bullets_per_shot = 0;
clip_reload_time = 150;
damage_type = 2;

-- Описание пули
bullet_damage = 20;
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
			{ dur = 1; num = 0; com = constants.AnimComRealH; param = 7 }
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
			{ dur = 1; num = 1; com = constants.AnimComRealH; param = 7 },
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
			{ dur = 1; num = 2; com = constants.AnimComRealH; param = 7 },
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