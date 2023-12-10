--forbidden
name = "explosion-rocket";

physic = 1;
phys_ghostlike = 1;
push_force = 10.0;

reload_time = 500;
bullets_per_shot = 0;
multiple_targets = 1;

-- Описание пули
bullet_damage = 120;
bullet_vel = 0;

-- Описание спрайта пули
texture = "rocket-explosion";

image_width = 256;
image_height = 64;
frame_width = 64;
frame_height = 64;
frames_count = 4;
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
			{ com = constants.AnimComSetAnim; txt = "die" }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "diagup";
		frames = 
		{

			{ com = constants.AnimComSetAnim; txt = "die" }
		}
	},
	{
		name = "miss";
		frames =
		{
			{ com = constants.AnimComStop },
			{ dur = 1 },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComCreateParticles; param = 2; txt = "pexplosionblue"; },
			{ com = constants.AnimComPlaySound; txt = "weapons/grenade-explosion.ogg" },
			{ com = constants.AnimComRealH; param = 84 },
			{ com = constants.AnimComRealW; param = 84 },
			{ com = constants.AnimComRealX; param = -10 },
			{ com = constants.AnimComRealY; param = -10 },
			{ dur = 100; num = 0 },
			{ dur = 100; num = 1 },
			{ dur = 100; num = 2 },
			{ dur = 100; num = 3 },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{
		--Уничтожение
		name = "die";
		frames =
		{
			{ com = constants.AnimComStop },
			{ dur = 1 },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComCreateParticles; param = 2; txt = "pexplosionblue"; },
			{ com = constants.AnimComPlaySound; txt = "weapons/grenade-explosion.ogg" },
			{ com = constants.AnimComRealH; param = 84 },
			{ com = constants.AnimComRealW; param = 84 },
			{ com = constants.AnimComRealX; param = -10 },
			{ com = constants.AnimComRealY; param = -10 },
			{ dur = 100; num = 0 },
			{ dur = 100; num = 1 },
			{ dur = 100; num = 2 },
			{ dur = 100; num = 3 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}