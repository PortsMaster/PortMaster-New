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
offscreen_behavior = constants.offscreenSleep

mass = -1;
faction_id = 1;

drops_shadow = 1;

gravity_x = 0;
gravity_y = 0.8;

texture = "pbear";

z = -0.002;

animations = 
{
	{ 
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 76 },
			{ com = constants.AnimComRealH; param = 77 },
			{ com = constants.AnimComSetTouchable; param = 1 },
			{ com = constants.AnimComSetHealth; param = 200 },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{ 
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComStop },
			{ dur = 100; num = 0; com = constants.AnimComSetAccX; param = -500 },
			{ com = constants.AnimComSetAnim; txt = "move" }	
		}
	},
	{ 
		name = "pain";
		frames = 
		{
			{ com = constants.AnimComPop },
			{ com = constants.AnimComReduceHealth },
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
			{ com = constants.AnimComMapVarAdd; param = difficulty*100; txt = "score" },
			{ com = constants.AnimComMapVarAdd; param = 1; txt = "kills" },
			{ com = constants.AnimComSetTouchable; param = 0 },
			{ com = constants.AnimComStop; },
			{ com = constants.AnimComSetBulletCollidable; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 28 },
			{ com = constants.AnimComCreateParticles; txt = "pblood3"; param = 2 },
			{ com = constants.AnimComRealW; param = 63 },
			{ com = constants.AnimComRealH; param = 83 },
			{ dur = 100; num = 10 },
			{ com = constants.AnimComRealW; param = 108 },
			{ com = constants.AnimComRealH; param = 80 },
			{ dur = 100; num = 11 },
			{ com = constants.AnimComRealW; param = 122 },
			{ com = constants.AnimComRealH; param = 80 },
			{ dur = 100; num = 12 },
			{ com = constants.AnimComRealW; param = 130 },
			{ com = constants.AnimComRealH; param = 83 },
			{ dur = 100; num = 13 },
			{ com = constants.AnimComRealW; param = 117 },
			{ com = constants.AnimComRealH; param = 21 },
			{ dur = 5000; num = 14 },
			{ com = constants.AnimComPushInt; param = 320 },
			{ com = constants.AnimComPushInt; param = 240 },
			{ com = constants.AnimComJumpIfCloseToCamera; param = 20 },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{
		name = "move";
		frames = 
		{
			{ dur = 100; com = constants.AnimComRealX; param = 3; },
			{ dur = 100; num = 1; com = constants.AnimComRealX; param = -5; },
			{ dur = 100; num = 2; com = constants.AnimComRealX; param = -10; },
			{ dur = 100; num = 3; com = constants.AnimComRealX; param = -16; },
			{ dur = 100; num = 4; com = constants.AnimComRealX; param = -9; },
			{ dur = 100; num = 5; com = constants.AnimComRealX; param = -2; },
			{ dur = 100; num = 6; com = constants.AnimComRealX; param = 3; },
			{ dur = 100; num = 7; com = constants.AnimComRealX; param = -6; },
			{ dur = 100; num = 8; com = constants.AnimComRealX; param = -16; },
			{ dur = 100; num = 9; com = constants.AnimComRealX; param = -10; },
			{ com = constants.AnimComLoop; }
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
			{ dur = 1; num = 0 },
			{ com = constants.AnimComSetTouchable; param = 1 },
			{ com = constants.AnimComSetAnim; txt = "move" }
		}
	},

}



