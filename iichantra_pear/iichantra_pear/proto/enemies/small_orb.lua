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
facing = constants.facingFixed

mass = 0.1;

drops_shadow = 1;

gravity_x = 0;
gravity_y = 0;

faction_id = 1;
faction_hates = { -1, -2 };

FunctionName = "CreateEnemy";

-- Описание спрайта

texture = "small_orb";

z = -0.002;

animations = 
{
	{ 
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 45 },
			{ com = constants.AnimComRealH; param = 45 },
			{ com = constants.AnimComSetTouchable; param = 1 },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{ 
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComStop },
			{ dur = 100; num = 0; com = constants.AnimComWaitForTarget; param = 320; txt = "move" },
			{ com = constants.AnimComLoop }	
		}
	},
	{ 
		name = "pain";
		frames = 
		{
			{ com = constants.AnimComPop },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateParticles; txt = "pspark2"; param = 0 },
			{ com = constants.AnimComSetAnim; txt = "move" }
		}
	},
	{ 
		name = "move";
		frames = 
		{
			{},
			{ com = constants.AnimComMoveToTarget; param = 50; dur = 100; num = 1 },
			{ com = constants.AnimComMoveTotarget; param = 50; dur = 100; num = 2 },
			{ com = constants.AnimComMoveTotarget; param = 50; dur = 100; num = 3 },
			{ com = constants.AnimComMoveTotarget; param = 50; dur = 100; num = 2 },
			{ com = constants.AnimComPushInt; param = 320;  },
			{ com = constants.AnimComJumpIfTargetClose; param = 0 },
			{ com = constants.AnimComSetAnim; txt = "idle" }
		}
	},
	{
		name = "land";
		frames =
		{
			{ com = constants.AnimComSetAnim; txt = "idle" }
		}
	},
	{
		name = "touch";
		frames =
		{
			{ com = constants.AnimComDealDamage; param = 10*difficulty },
			{ dur = 100; num = 3 },
			{ com = constants.AnimComSetTouchable; param = 1 },
			{ com = constants.AnimComSetAnim; txt = "move" }
		}
	},

}



