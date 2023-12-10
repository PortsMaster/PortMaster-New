reload_time = 200;
bullets_per_shot = 0;
damage_type = 2;

local diff = (difficulty-1)/5+1;

-- Описание пули
bullet_damage = 7;
bullet_vel = 2.5;

-- Описание спрайта пули
texture = "troll-hand";

z = -0.001;

animations = 
{
	{
		-- Пуля, летящая прямо
		name = "straight";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 16 },
			{ com = constants.AnimComRealH; param = 16 },
			{ com = constants.AnimComSetLifetime; param = 300 },
			{ dur = 1; num = 8 },
			{ com = constants.AnimComPlaySound; txt = "slowpoke-shoot.ogg" },
			{ com = constants.AnimComSetAnim; txt = "fly" }
		}
	},
	{
		name = "fly";
		frames =
		{
			{ dur = 100; num = 8; },
			{ dur = 100; num = 9; },
			{ com = constants.AnimComLoop }
		},
	},
	{
		name = "miss";
		frames =
		{
			{ com = constants.AnimComStartDying },
			{ com = constants.AnimComSetAnim; txt = "die" },
		}
	},
	{
		-- Уничтожение пули
		name = "die";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateParticles; txt = "pslime"; param = 0 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}
