--forbidden

drops_shadow = 1;

gravity_x = 0;
gravity_y = 0.8;

FunctionName = "CreateEnemy";

faction_id = 1;
physic = 1;
phys_bullet_collidable = 1;

-- Описание спрайта

texture = "snowman";

z = -0.1;

animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 51 },
			{ com = constants.AnimComRealH; param = 78 },
			{ com = constants.AnimComSetHealth; param = 20 },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{ 
		-- Создание
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 51 },
			{ com = constants.AnimComRealH; param = 78 },
			{ dur = 1; num = 0 },
		}
	},
	{ 
		-- Создание
		name = "pain";
		frames = 
		{
			--{ com = constants.AnimComJumpIfIntEquals; param = 2; txt = "sfg9000" },
			{ com = constants.AnimComPop },
			{ com = constants.AnimComReduceHealth },

		}
	},
	{ 
		-- Создание
		name = "die";
		frames = 
		{
			{ com = constants.AnimComCallFunction; txt = "snowman_dead" },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ dur = 100; num = 0; com = constants.AnimComCreateParticles; txt = "psnowman"; param = 2 },
		}
	},

}



