--forbidden
physic = 1;

reload_time = 500;
bullets_per_shot = 0;

-- Описание пули
bullet_damage = 40;
bullet_vel = 0;

-- Описание спрайта пули
texture = "iicopter";

z = -0.011;

drops_shadow = 1;

--bounce = 0.75;

animations = 
{
	{
		name = "fly";
		frames =
		{
			{ com = constants.AnimComSetShielding; param = 1 },
			{ dur = 100; num = 6 },
		}
	},
	{
		-- Пуля, летящая прямо
		name = "straight";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 0; num = 6 },
			{ com = constants.AnimComPushInt; param = 400; num = 6 },
			{ com = constants.AnimComSetGravity; num = 6 }, 
			{ com = constants.AnimComRealX; param = 0; num = 6 },
			{ com = constants.AnimComRealY; param = 0; num = 6 },
			{ com = constants.AnimComRealW; param = 95; num = 6 },
			{ com = constants.AnimComRealH; param = 32; num = 6 },
			{ com = constants.AnimComSetMaxVelX; param = 5000; num = 6 },
			{ com = constants.AnimComSetMaxVelY; param = 8000; num = 6 },
			{ com = constants.AnimComSetAnim; txt = "fly"; num = 6 }
		}
	},
	{
		-- Пуля, летящая по диагонали вниз
		name = "diagdown";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "straight"; num = 6 }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "diagup";
		frames = 
		{

			{ com = constants.AnimComSetAnim; txt = "straight"; num = 6 }
		}
	},
	{
		name = "miss";
		frames =
		{
			{ com = constants.AnimComStartDying },
			{ com = constants.AnimComSetAnim; txt = "die"}
		}
	},
	{
		--Уничтожение
		name = "die";
		frames =
		{
			{ com = constants.AnimComStop; num = 6 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "explosion"; num = 6 },
			{ com = constants.AnimComDestroyObject; num = 2 }
		}
	}
}