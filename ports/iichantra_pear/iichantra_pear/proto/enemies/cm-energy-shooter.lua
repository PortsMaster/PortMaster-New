--forbidden
bounce = 0;

physic = 0;
phys_solid = 0;
phys_bullet_collidable = 1;
phys_max_x_vel = 200;
phys_max_y_vel = 50;
phys_jump_vel = 20;
phys_walk_acc = 3;
mp_count = 1;
offscreen_distance = 640
offscreen_behavior = constants.offscreenNone

FunctionName = "CreateEnemy";

-- Описание спрайта

drops_shadow = 0;
ghost_to = 255;

z = -0.001;

faction_id = 1;
faction_hates = {3};

animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComWaitForTarget; txt = "idle"; param = 3000; dur = 100 },
			{ com = constants.AnimComLoop }
		}
	},
	{ 
		name = "idle";
		frames = 
		{
			
			{ com = constants.AnimComAdjustAim },
			{ com = constants.AnimComAimedShot; txt = "cm-energy" },
			{ dur = 350; num = 0; },
			{ com = constants.AnimComLoop }	
		}
	},
	{ 
		name = "die";
		frames = 
		{
			{ com = constants.AnimComDestroyObject }
		}
	}
	
}



