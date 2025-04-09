--forbidden
name = "generic-death-area";

physic = 0;
phys_solid = 0;
phys_bullet_collidable = 0;
phys_ghostlike = 1;
phys_max_x_vel = 0;
phys_max_y_vel = 30;

FunctionName = "CreateItem";

-- Описание спрайта

icon = "endbutton";

image_width = 1024;
image_height = 1024;
frame_width = 256;
frame_height = 128;
frames_count = 28;


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
		-- Бонус
		-- Oh, the irony!
		name = "touch";
		frames = 
		{
			{ com = constants.AnimComSetTouchable; param = 1 },
			{ com = constants.AnimComDamage; param = 2000 },
			{ com = constants.AnimComSetAnim; txt = "idle" }
		}
	}
	
}



