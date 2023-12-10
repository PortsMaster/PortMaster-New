physic = 1;
phys_solid = 0;
phys_bullet_collidable = 0;
phys_max_x_vel = 0;
phys_max_y_vel = 0;

trajectory_type = constants.pttGlobalSine;
trajectory_param1 = 0.5;
trajectory_param2 = 0.05;

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
			{ com = constants.AnimComPushInt; param = 1 }, --circle
			{ dur = 100; num = 6 },
			{ com = constants.AnimComPop },
			{ com = constants.AnimComPushInt; param = 2 }, --diamond
			{ dur = 100; num = 14 },
			{ com = constants.AnimComPop },
			{ com = constants.AnimComPushInt; param = 3 }, --line
			{ dur = 100; num = 28 },
			{ com = constants.AnimComPop },
			{ com = constants.AnimComPushInt; param = 4 }, --square
			{ dur = 100; num = 0 },
			{ com = constants.AnimComPop },
			{ com = constants.AnimComPushInt; param = 5 }, --triangle
			{ dur = 100; num = 10 },
			{ com = constants.AnimComPop },
			{ com = constants.AnimComLoop }
		}
	},
	{ 
		-- Бонус
		name = "touch";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 10 },
			{ com = constants.AnimComLocalJumpIfNextIntEquals; param = 1 },
			{ com = constants.AnimComPushInt; param = 13 },
			{ com = constants.AnimComLocalJumpIfNextIntEquals; param = 2 },
			{ com = constants.AnimComPushInt; param = 16 },
			{ com = constants.AnimComLocalJumpIfNextIntEquals; param = 3 },
			{ com = constants.AnimComPushInt; param = 19 },
			{ com = constants.AnimComLocalJumpIfNextIntEquals; param = 4 },
			{ com = constants.AnimComGiveWeapon; txt = "triangle"},
			{ com = constants.AnimComDestroyObject },
			{},
			{ com = constants.AnimComGiveWeapon; txt = "circle"},
			{ com = constants.AnimComDestroyObject },
			{},
			{ com = constants.AnimComGiveWeapon; txt = "diamond"},
			{ com = constants.AnimComDestroyObject },
			{},
			{ com = constants.AnimComGiveWeapon; txt = "line"},
			{ com = constants.AnimComDestroyObject },
			{},
			{ com = constants.AnimComGiveWeapon; txt = "square"},
			{ com = constants.AnimComDestroyObject }
		}
	}
	
}



