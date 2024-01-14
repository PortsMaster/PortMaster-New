--forbidden
physic = 1;
phys_ghostlike = 1;
push_force = 0.0;

reload_time = 500;
bullets_per_shot = 0;
multiple_targets = 1;

-- Описание пули
bullet_damage = 60;
bullet_vel = 0;

-- Описание спрайта пули
texture = "wave_weapon";

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
			{ com = constants.AnimComSetAnim; txt = "die" },
			{ dur = 100 },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "diagup";
		frames = 
		{

			{ com = constants.AnimComSetAnim; txt = "die" },
			{ dur = 100 },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{
		name = "miss";
		frames =
		{
			{ com = constants.AnimComStartDying },
			{ com = constants.AnimComSetAnim; txt = "die" }
		}
	},
	{
		--Уничтожение
		name = "die";
		frames =
		{

			{ com = constants.AnimComPlaySound; txt = "grenade-explosion" },
			{ com = constants.AnimComRealW; param = 39 },
			{ com = constants.AnimComRealH; param = 21 },
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ dur = 50; num = 35 },
			{ dur = 50; num = 36 },
			{ dur = 50; num = 37 },
			{ dur = 50; num = 38 },
			{ dur = 50; num = 39 },
			{ dur = 50; num = 40 },
			{ dur = 50; num = 41 },
			{ com = constants.AnimComRealH; param = 22 },
			{ dur = 50; num = 42 },
			{ com = constants.AnimComRealH; param = 24 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "wave" },
			{ com = constants.AnimComMirror },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "wave" },
			{ com = constants.AnimComMirror },
			{ com = constants.AnimComRealH; param = 28 },
			{ dur = 50; num = 43 },
			{ dur = 50; num = 44 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}