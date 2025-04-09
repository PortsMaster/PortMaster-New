--forbidden
physic = 1;
phys_solid = 0;
phys_bullet_collidable = 1;
phys_max_x_vel = 5;
phys_max_y_vel = 50;
phys_jump_vel = 20;
phys_walk_acc = 3;
phys_one_sided = 0;
mp_count = 1;
offscreen_distance = 640
offscreen_behavior = constants.offscreenNone

drops_shadow = 1;

gravity_x = 0;
gravity_y = 0.8;


faction_id = -2;
faction_hates = { 1, 2, 3 };

-- Описание спрайта

texture = "prof";

z = -0.002;

animations = 
{
	{ 
		-- Созидание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 28 },
			{ com = constants.AnimComRealH; param = 71 },
			{ com = constants.AnimComSetHealth; param = 100*difficulty },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{ 
		-- Разрушение
		name = "idle";
		frames = 
		{
			{ dur = 200; num = 0 }
		}
	},
	{
		name = "turn_left";
		frames =
		{
			{ dur = 1; num = 0; com = constants.AnimComSetVelX; param = 1 },
			{ dur = 0; com = constants.AnimComStop },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{ 
		-- Создание
		name = "land";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "idle" }
		}
	}
}



