--forbidden
physic = 1;
phys_solid = 0;
phys_bullet_collidable = 1;
phys_max_x_vel = 15;
phys_max_y_vel = 50;
phys_jump_vel = 20;
phys_walk_acc = 3;
phys_one_sided = 0;
mp_count = 4;
offscreen_distance = 640
offscreen_behavior = constants.offscreenNone

mass = -1;
faction_id = 1;

drops_shadow = 1;

gravity_x = 0;
gravity_y = 0.3;

texture = "cancer";

z = -0.002;

animations = 
{
	{ 
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 144 },
			{ com = constants.AnimComRealH; param = 87 },
			{ com = constants.AnimComSetTouchable; param = 1 },
			{ com = constants.AnimComSetHealth; param = 200 },
			{ dur = 1; num = 0 },
			{ com = constants.AnimComPushInt; param = 72 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComMPSet; param = 2 },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEffect; txt = "cancer-claws"; param = 5 },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{ 
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComStop },
			{ com = constants.AnimComSetAnim; txt = "move1"; param = 128 },
			{ com = constants.AnimComSetAnim; txt = "move2" },
		}
	},
	{ 
		name = "pain";
		frames = 
		{
			{ com = constants.AnimComPop },
			{ com = constants.AnimComPop },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateParticles; txt = "pblood2"; param = 0 },
			{ com = constants.AnimComRecover }
		}
	},
	{ 
		name = "die";
		frames = 
		{
			{ com = constants.AnimComDestroyObject }
		}
	},
	{
		name = "move1";
		frames = 
		{
			{ dur = 0; num = 0; com = constants.AnimComSetMaxVelX; param = 3000 },
			{ dur = 0; num = 0; com = constants.AnimComSetAccX; param = -5000 },
			{ dur = 0; num = 0; com = constants.AnimComSetVelY; param = -5000 },
			{ dur = 100; num = 0; com = constants.AnimComRealH; param = 87 },
			{ dur = 100; num = 1; com = constants.AnimComRealH; param = 88 },
			{ dur = 100; num = 2; com = constants.AnimComRealH; param = 86 },
			{ dur = 100; num = 3; com = constants.AnimComRealH; param = 88 },
			{ dur = 100; num = 4; com = constants.AnimComRealH; param = 88 },
			{ dur = 100; num = 5; com = constants.AnimComRealH; param = 87 },
			{ dur = 100; num = 6; com = constants.AnimComRealH; param = 86 },
			{ dur = 100; num = 7; com = constants.AnimComRealH; param = 85 },
			{ dur = 100; num = 8; com = constants.AnimComRealH; param = 86 },
			{ dur = 100; num = 9; com = constants.AnimComRealH; param = 87 },
			{ dur = 100; num = 10; com = constants.AnimComRealH; param = 87 },
			{ dur = 100; num = 11; com = constants.AnimComRealH; param = 87 },
			{ com = constants.AnimComLoop; }
		}
	},
	{
		name = "move2";
		frames = 
		{
			{ dur = 100; num = 0; com = constants.AnimComSetAccX; param = -1000 },
			{ dur = 100; num = 0; com = constants.AnimComRealH; param = 87 },
			{ dur = 100; num = 1; com = constants.AnimComRealH; param = 88 },
			{ dur = 100; num = 2; com = constants.AnimComRealH; param = 86 },
			{ dur = 100; num = 3; com = constants.AnimComRealH; param = 88 },
			{ dur = 100; num = 4; com = constants.AnimComRealH; param = 88 },
			{ dur = 100; num = 5; com = constants.AnimComRealH; param = 87 },
			{ dur = 100; num = 6; com = constants.AnimComRealH; param = 86 },
			{ dur = 100; num = 7; com = constants.AnimComRealH; param = 85 },
			{ dur = 100; num = 8; com = constants.AnimComRealH; param = 86 },
			{ dur = 100; num = 9; com = constants.AnimComRealH; param = 87 },
			{ dur = 100; num = 10; com = constants.AnimComRealH; param = 87 },
			{ dur = 100; num = 11; com = constants.AnimComRealH; param = 87 },
			{ com = constants.AnimComLoop; }
		}
	},
	{
		name = "touch";
		frames =
		{
			{ com = constants.AnimComDealDamage; param = 5*difficulty },
			{ dur = 1; num = 0 },
			{ com = constants.AnimComSetTouchable; param = 1 },
			{ com = constants.AnimComSetAnim; txt = "move2" }
		}
	},

}



