--forbidden
name = "mikuru_beam";

reload_time = 200;
bullets_per_shot = 1;
clip_reload_time = 150;
damage_type = 2;
multiple_targets = 1;

is_ray_weapon = 1;
time_to_live = 0;

-- Описание пули
bullet_damage = 30;
--bullet_vel = 15;

-- Описание спрайта пули
texture = "laser";

z = -0.002;
--z = 1

frames_count = 15;

next_shift_y = 4;

end_effect = "laser_collision_effect";

local sound_shoot = "weapons/laser.ogg"

local t = 25

animations = 
{
	{
		-- Пуля, летящая прямо
		name = "straight";
		frames = 
		{
			{ com = constants.AnimComRealW; param =  32},
			{ com = constants.AnimComPlaySound; txt = sound_shoot; param = 1 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -8 },
			{ com = constants.AnimComCreateEffect; txt ="flash-straight"; param = 13 },
			{ com = constants.AnimComRealY; param = 2 },			-- param = 3 лучше при стрельбе стоя, но, кажется, хуже при беге
			{ dur = t; num = 10; com = constants.AnimComRealH; param = 5 },
			{ dur = t; num = 11 },
			{ dur = t; num = 12 },
			{ dur = t; num = 13 },
			{ dur = t; num = 14 },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{
		-- Пуля, летящая по диагонали вниз
		name = "diagdown";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 32 },
			{ com = constants.AnimComPlaySound; txt = sound_shoot; param = 1 },
			{ com = constants.AnimComPushInt; param = -3 },
			{ com = constants.AnimComPushInt; param = -34 },
			{ com = constants.AnimComCreateEffect; txt ="flash-angle-down"; param = 13 },
			{ dur = t; num = 5; com = constants.AnimComRealH; param = 36 },
			{ dur = t; num = 6 },
			{ dur = t; num = 7 },
			{ dur = t; num = 8 },
			{ dur = t; num = 9 },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "diagup";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 32 },
			{ com = constants.AnimComPlaySound; txt = sound_shoot; param = 1 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -10 },
			{ com = constants.AnimComCreateEffect; txt ="flash-angle-up"; param = 13 },
			{ dur = t; num = 0; com = constants.AnimComRealH; param = 36 },
			{ dur = t; num = 1 },
			{ dur = t; num = 2 },
			{ dur = t; num = 3 },
			{ dur = t; num = 4 },
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
			--{ com = constants.AnimComStop },
			--{ com = constants.AnimComRealX; param = 38 },
			--{ com = constants.AnimComRealY; param = 12 },
			--{ com = constants.AnimComRealW; param = 11 },
			--{ com = constants.AnimComPushInt; param = 100 },
			--{ com = constants.AnimComPushInt; param = 100 },
			--{ dur = 100; num = 4 },
			--{ dur = 100; num = 5 },
			--{ dur = 100; num = 6 },
			--{ dur = 100; num = 7 },
			--{ com = constants.AnimComDestroyObject }
		}
	}
}