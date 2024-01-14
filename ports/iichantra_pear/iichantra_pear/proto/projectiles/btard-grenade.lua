--forbidden
name = "btard-grenade";

physic = 1;

reload_time = 500;
bullets_per_shot = 20;

-- Описание пули
bullet_damage = 0;
bullet_vel = 2;

-- Описание спрайта пули
texture = "grenade";

image_width = 256;
image_height = 64;
frame_width = 32;
frame_height = 32;
frames_count = 10;
z = -0.001;

bounce = 0.75;

animations = 
{
	{
		name = "fly";
		frames =
		{
			{ com = constants.AnimComSetAccX; param = 0 },
			{ com = constants.AnimComSetAccY; param = 0 },
			{ dur = 30; num = 0 },
			{ dur = 30; num = 1 },
			{ dur = 30; num = 2 },
			{ dur = 30; num = 3 },
			{ dur = 30; num = 4 },
			{ dur = 30; num = 0 },
			{ dur = 30; num = 1 },
			{ dur = 30; num = 2 },
			{ dur = 30; num = 3 },
			{ dur = 30; num = 4 },
			{ dur = 30; num = 0 },
			{ dur = 30; num = 1 },
			{ dur = 30; num = 2 },
			{ dur = 30; num = 3 },
			{ dur = 30; num = 4 },
			{ dur = 30; num = 5 },
			{ dur = 30; num = 6 },
			{ dur = 30; num = 7 },
			{ dur = 30; num = 8 },
			{ dur = 30; num = 9 },
			{ com = constants.AnimComSetAnim; txt = "die" }
		}
	},
	{
		-- Пуля, летящая прямо
		name = "straight";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 600 },
			{ com = constants.AnimComSetGravity }, 
			{ com = constants.AnimComRealX; param = 10 },
			{ com = constants.AnimComRealY; param = 10 },
			{ com = constants.AnimComRealW; param = 11 },
			{ com = constants.AnimComRealH; param = 11 },
			{ com = constants.AnimComSetMaxVelX; param = 10000 },
			{ com = constants.AnimComSetMaxVelY; param = 10000 },
			{ com = constants.AnimComSetAccY; param = 0 },
			{ com = constants.AnimComSetAnim; txt = "fly" }
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
		name = "miss";
		frames =
		{
			{ com = constants.AnimComPlaySound; txt = "grenade-bounce" },
			{ com = constants.AnimComSetAnim; txt = "die" }
		}
	},
	{
		--Уничтожение
		name = "die";
		frames =
		{
			{ com = constants.AnimComStop },
			{ com = constants.AnimComCreateEnemyBullet; txt = "explosion" },
			{ com = constants.AnimComDestroyObject }
		}
	}
}