physic = 1;
phys_max_x_vel = 0;
phys_max_y_vel = 4;

texture = "keycards";
z = -0.001;

gravity_x = 0;
gravity_y = 0.8;

animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 9 },
			{ com = constants.AnimComRealH; param = 13 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 800 },
			{ com = constants.AnimComSetGravity },
			{ com = constants.AnimComSetTouchable; param = 1 },
			{ dur = 1; num = 0 },
			{ com = constants.AnimComSetAnim; txt = "idle-blue" }	
		}
	},
	{ 
		-- Вращение
		name = "idle-blue";
		frames = 
		{
	
			{ dur = 100; num = 0 },
		}
	},
	{ 
		-- Вращение
		name = "idle-red";
		frames = 
		{
	
			{ dur = 100; num = 1 },
		}
	},
	{ 
		-- Вращение
		name = "idle-yellow";
		frames = 
		{
	
			{ dur = 100; num = 2 },
		}
	},
	{ 
		-- Бонус
		name = "touch";
		frames = 
		{
			{ com = constants.AnimComSetInvisible; param = 1 },
			{ com = constants.AnimComCallFunction; txt = "keycard" },
			{ com = constants.AnimComDestroyObject }
		}
	}
	
}



