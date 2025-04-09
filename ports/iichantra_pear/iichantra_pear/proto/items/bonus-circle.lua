name = "bonus-circle";

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
			{ com = constants.AnimComRealW; param = 22 },
			{ com = constants.AnimComRealH; param = 22 },
			{ com = constants.AnimComSetTouchable; param = 1 },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{ 
		name = "idle";
		frames = 
		{
	
			{ dur = 100; num = 6 },
			{ dur = 100; num = 7 },
			{ dur = 100; num = 8 },
			{ dur = 100; num = 9 },
			{ com = constants.AnimComLoop }	
		}
	},
	{ 
		-- Бонус
		name = "touch";
		frames = 
		{
			{ com = constants.AnimComGiveWeapon; txt = "circle"; num = 6 },
			{ com = constants.AnimComDestroyObject; num = 6 }
		}
	}
	
}



