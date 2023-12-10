--forbidden
reload_time = 200;
bullets_per_shot = 0;
clip_reload_time = 150;
damage_type = 2;
multiple_targets = 0;
hurts_same_type = 1;

is_ray_weapon = 1;
time_to_live = 0;

-- Описание пули
bullet_damage = 25;
--bullet_vel = 15;

-- Описание спрайта пули
texture = "troll-hand";

z = -0.002;
--z = 1

frames_count = 15;

next_shift_y = 4;

end_effect = "laser_collision_effect";

--local sound_shoot = "blaster_shot"

local t = 50

animations = 
{
	{
		-- Пуля, летящая прямо
		name = "straight";
		frames = 
		{
			{ com = constants.AnimComRealW; param =  32},
			--{ com = constants.AnimComPlaySound; txt = sound_shoot },
			{ com = constants.AnimComRealY; param = 0 },			-- param = 3 лучше при стрельбе стоя, но, кажется, хуже при беге
			{ dur = t; num = 7; com = constants.AnimComRealH; param = 1 },
			{ dur = t; num = 6 },
			{ dur = t; num = 7 },
			{ dur = t; num = 6 },
			{ dur = t; num = 7 },
			{ dur = t; num = 6 },
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
	}
}
