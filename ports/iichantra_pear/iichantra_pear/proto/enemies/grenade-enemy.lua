--forbidden

bounce = 0.25;

physic = 1;
phys_solid = 0;
phys_bullet_collidable = 1;
phys_max_x_vel = 10;
phys_max_y_vel = 50;
phys_jump_vel = 20;
phys_walk_acc = 3;
phys_one_sided = 0;
mp_count = 1;

gravity_y = 0.4;

-- Описание спрайта

texture = "grenade-enemy";

z = -0.001;

animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 22 },
			{ com = constants.AnimComRealH; param = 22 },
			{ com = constants.AnimComSetHealth; param = 5 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 800 },
			{ com = constants.AnimComSetGravity },
			{ com = constants.AnimComSetHealth; param = 1 },
			{ com = constants.AnimComSetTouchable; param = 1 },
			{ com = constants.AnimComSetVelY; param = -6000 },
			{ com = constants.AnimComSetVelX; param = 3000 },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{ 
		name = "idle";
		frames = 
		{
			{ num = 0; dur = 50 },
			{ num = 1; dur = 50 },
			{ num = 2; dur = 50 },
			{ num = 3; dur = 50 },
			{ num = 0; dur = 50 },
			{ num = 1; dur = 50 },
			{ num = 2; dur = 50 },
			{ num = 3; dur = 50 },
			{ num = 0; dur = 50 },
			{ num = 1; dur = 50 },
			{ num = 2; dur = 50 },
			{ num = 3; dur = 50 },
			{ num = 0; dur = 50 },
			{ num = 1; dur = 50 },
			{ num = 2; dur = 50 },
			{ num = 3; dur = 50 },

			{ com = constants.AnimComSetAnim; txt = "die" }
		}
	},
	{ 
		-- Создание
		name = "pain";
		frames = 
		{
			{ com = constants.AnimComPop },
			{ com = constants.AnimComReduceHealth },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComRecover; txt = "idle" }
		}
	},
	{
		-- Создание
		name = "jump";
		frames = 
		{
			{ num = 0; dur = 50 },
			{ num = 1; dur = 50 },
			{ num = 2; dur = 50 },
			{ num = 3; dur = 50 },
			{ num = 0; dur = 50 },
			{ num = 1; dur = 50 },
			{ num = 2; dur = 50 },
			{ num = 3; dur = 50 },
			{ num = 0; dur = 50 },
			{ num = 1; dur = 50 },
			{ num = 2; dur = 50 },
			{ num = 3; dur = 50 },
			{ num = 0; dur = 50 },
			{ num = 1; dur = 50 },
			{ num = 2; dur = 50 },
			{ num = 3; dur = 50 },
			{ com = constants.AnimComSetAnim; txt = "die" }
		}
	},
	{
		name = "touch";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "die" }
		}
	},
	{ 
		-- Создание
		name = "die";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "explosion" },
			{ com = constants.AnimComDestroyObject }	
		}
	},
	{ 
		-- Создание
		name = "land";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "die" }
		}
	}
	
}



