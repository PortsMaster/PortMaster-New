--forbidden

physic = 0;
phys_solid = 0;
phys_bullet_collidable = 0;
phys_ghostlike = 1;
phys_max_x_vel = 0;
phys_max_y_vel = 0;

-- Описание спрайта



animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 1 },
			{ com = constants.AnimComRealH; param = 1 },
			{ com = constants.AnimComSetTouchable; param = 1 },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{ 
		-- Вращение
		name = "idle";
		frames = 
		{
			{ num = 28; dur = 100 }
		}
	},
	{ 
		name = "touch";
		frames = 
		{
			{ com = constants.AnimComSetTouchable; param = 1 },
			{ com = constants.AnimComPop },
			{ com = constants.AnimComCallFunctionWithStackParameter; txt = "map_trigger" },
			{ com = constants.AnimComSetAnim; txt = "idle" }
		}
	}
	
}



