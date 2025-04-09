--forbidden
local diff = (difficulty-1)/5+1;

-- Описание пули
bullet_damage = 10;
bullet_vel = 2;

trajectory_type = constants.pttCosine;
trajectory_param1 = 5;
trajectory_param2 = 0.05;

-- Описание спрайта пули
texture = "technopoke_projectiles";

z = -0.001;
k = -2;
ghost_to = 14;

animations = 
{
	{
		-- Пуля, летящая прямо
		name = "straight";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 13 },
			{ com = constants.AnimComRealH; param = 13 },
			{ com = constants.AnimComSetLifetime; param = 300 },
			{ com = constants.AnimComSetMaxVelY; param = 4000 },
			{ com = constants.AnimComAdjustAccY; param = -2000 },
			{ dur = 100; num = 5 },
			{ dur = 100; num = 6 },
			{ com = constants.AnimComJump; param = 4 }

		}
	},
	{
		-- Пуля, летящая по диагонали вниз
		name = "diagdown";
		frames = 
		{
			{ dur = 0 }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "diagup";
		frames = 
		{
			{ dur = 0 }
		}
	},
	{
		--Пуля попала в неподвижный объект.
		name = "miss";
		frames =
		{
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateParticles; txt = "pspark"; param = 2 },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{
		-- Уничтожение пули
		name = "die";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateParticles; txt = "pspark"; param = 2 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}
