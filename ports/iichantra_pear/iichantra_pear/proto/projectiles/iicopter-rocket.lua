--forbidden
physic = 1;

reload_time = 500;
bullets_per_shot = 0;

-- Описание пули
bullet_damage = 30;
bullet_vel = 0;

-- Описание спрайта пули
texture = "iicopter";

z = -0.011;

animations = 
{
	{
		name = "fly";
		frames =
		{
			{ dur = 1; num = 14 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -5 },
			{ com = constants.AnimComCreateParticles; txt = "prockettrail"; param = 2 },
			{ com = constants.AnimComPushInt; param = -1 },
			{ com = constants.AnimComJumpIfTargetX; param = 8 },
			{ com = constants.AnimComSetVelX; param = 3000 },
			{ dur = 300; num = 14 },
			{ com = constants.AnimComJump; param = 11 },
			{},
			{ com = constants.AnimComSetVelX; param = -3000 },
			{ dur = 300; num = 14 },
			{},
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ },
			{ com = constants.AnimComPushInt; param = -1 },
			{ com = constants.AnimComJumpIfTargetX; param = 20 },
			{ com = constants.AnimComSetVelX; param = 3000 },
			{ dur = 300; num = 14 },
			{ com = constants.AnimComSetAnim; txt = "diagonal" },
			{ com = constants.AnimComSetVelX; param = -3000 },
			{ dur = 300; num = 14 },
			{ com = constants.AnimComSetAnim; txt = "diagonal" }
		}
	},
	{
		name = "diagonal";
		frames =
		{
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ },
			{ com = constants.AnimComSetVelY; param = 1500 },
			{ com = constants.AnimComRealW; param = 34; num = 6 },
			{ com = constants.AnimComRealH; param = 34; num = 6 },
			{ com = constants.AnimComAdjustY; param = 28 },
			{ com = constants.AnimComPushInt; param = -1 },
			{ com = constants.AnimComJumpIfTargetX; param = 11 },
			{ com = constants.AnimComSetVelX; param = 1500 },
			{ dur = 300; num = 15 },
			{ com = constants.AnimComSetAnim; txt = "down" },
			{ com = constants.AnimComSetVelX; param = -1500 },
			{ dur = 300; num = 15 },
			{ com = constants.AnimComSetAnim; txt = "down" },
		}
	},
	{
		name = "down";
		frames =
		{
			{ com = constants.AnimComSetVelX; param = 0 },
			{ com = constants.AnimComSetVelY; param = 3000 },
			{ com = constants.AnimComRealW; param = 6; num = 6 },
			{ com = constants.AnimComRealH; param = 47; num = 6 },
			{ com = constants.AnimComAdjustY; param = 13 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ },
			{ dur = 100; num = 16 },
			{ com = constants.AnimComJump; param = 4 }
		}
	},
	{
		-- Пуля, летящая прямо
		name = "straight";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0; num = 6 },
			{ com = constants.AnimComRealY; param = 0; num = 6 },
			{ com = constants.AnimComRealW; param = 47; num = 6 },
			{ com = constants.AnimComRealH; param = 6; num = 6 },
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