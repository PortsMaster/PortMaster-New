name = "bonus-diamond";

trajectory_type = constants.pttGlobalSine;
trajectory_param1 = 0.5;
trajectory_param2 = 0.05;

physic = 1;
phys_solid = 0;
phys_bullet_collidable = 0;
phys_max_x_vel = 0;
phys_max_y_vel = 0;

FunctionName = "CreateItem";

-- Описание спрайта

texture = "weapon_bonuses";
z = -0.001;


animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 25 },
			{ com = constants.AnimComRealH; param = 25 },
			{ com = constants.AnimComSetTouchable; param = 1 },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{ 
		name = "idle";
		frames = 
		{
	
			{ dur = 100; num = 14 },
			{ dur = 100; num = 15 },
			{ dur = 100; num = 16 },
			{ dur = 100; num = 17 },
			{ dur = 100; num = 18 },
			{ dur = 100; num = 19 },
			{ dur = 100; num = 20 },
			{ dur = 100; num = 21 },
			{ dur = 100; num = 22 },
			{ dur = 100; num = 23 },
			{ dur = 100; num = 24 },
			{ dur = 100; num = 25 },
			{ dur = 100; num = 26 },
			{ dur = 100; num = 27 },
			{ com = constants.AnimComLoop }	
		}
	},
	{ 
		-- Бонус
		name = "touch";
		frames = 
		{
			{ com = constants.AnimComGiveWeapon; txt = "diamond"; num = 14 },
			{ com = constants.AnimComDestroyObject; num = 14 }
		}
	}
	
}



