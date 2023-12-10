physic = 0;
phys_solid = 0;
phys_bullet_collidable = 0;
phys_one_sided = 0;
mp_count = 1;

faction_id = 1;

offscreen_distance = 640;
offscreen_behavior = constants.offscreenSleep

animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComSetInvisible; param = 1 },
			{ com = constants.AnimComSetAnim; txt = "working" }	
		}
	},
	{ 
		name = "working";
		frames = 
		{
			{ dur = 2500 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEnemy; txt = "grenade-enemy"; param = 0 },
			{ dur = 300 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEnemy; txt = "grenade-enemy"; param = 0 },
			{ com = constants.AnimComLoop }
		}
	},
	{ 
		name = "off";
		frames = 
		{
			{ dur = 800 },
			{ com = constants.AnimComLoop }
		}
	}

}



