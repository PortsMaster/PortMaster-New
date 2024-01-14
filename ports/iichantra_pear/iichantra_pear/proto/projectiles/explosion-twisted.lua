--forbidden
name = "explosion-twisted";

physic = 1;
phys_ghostlike = 1;
push_force = 4.0;

reload_time = 500;
bullets_per_shot = 0;
multiple_targets = 1;
hurts_same_type = 1;

-- Описание пули
bullet_damage = 120;
bullet_vel = 0;

-- Описание спрайта пули
texture = "explosion-twisted";

z = 0;

bounce = 0;

animations = 
{
	{
		-- Пуля, летящая прямо
		name = "straight";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "die" }
		}
	},
	{
		-- Пуля, летящая по диагонали вниз
		name = "diagdown";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "straight" },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "diagup";
		frames = 
		{

			{ com = constants.AnimComSetAnim; txt = "straight" },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{
		name = "miss";
		frames =
		{
			{ com = constants.AnimComSetAnim; txt = "die" }
		}
	},
	{
		--Уничтожение
		name = "die";
		frames =
		{

			{ com = constants.AnimComStop },
			{ dur = 1; num = 1 },
			{ com = constants.AnimComAdjustY; param = 32 },
			{ dur = 1; num = 1 },
			{ com = constants.AnimComCreateParticles; txt = "povercharged"; },
			{ com = constants.AnimComPlaySound; txt = "weapons/grenade-explosion.ogg" },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComRealW; param = 63+65; },
			{ com = constants.AnimComRealH; param = 54+74; },
			{ com = constants.AnimComRealX; param = -32-65; },
			{ com = constants.AnimComRealY; param = -64-74+64; },
			{ dur = 100; },
			{ com = constants.AnimComRealX; param = -16-65; },
			{ com = constants.AnimComRealY; param = -32-74+64; },
			{ dur = 100; num = 1; },
--			{ com = constants.AnimComRealX; },
--			{ com = constants.AnimComRealY; },
			{ dur = 100; num = 2; },
			{ dur = 100; num = 3; },

			{ com = constants.AnimComDestroyObject }

		}
	}
}