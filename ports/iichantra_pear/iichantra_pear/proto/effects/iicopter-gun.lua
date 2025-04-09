--forbidden
texture = "iicopter";

z = -0.11;
phys_ghostlike = 1;
physic = 1;
phys_bullet_collidable = 1;
phys_max_x_vel = 9000;
offscreen_distance = 640
offscreen_behavior = constants.offscreenNone

overlay = {0};

animations = 
{
	{
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 55 },
			{ com = constants.AnimComRealH; param = 35 },
			{ com = constants.AnimComSetHealth; param = 300 },
			{ dur = 1; num = 2 },
			{ com = constants.AnimComCallFunction; txt = "iicopter_part_created" },
			{ com = constants.AnimComSetAnim; txt = "ready" }
		}
	},
	{
		name = "inactive";
		frames =
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComJumpIfTargetY; param = 3 },
			{ com = constants.AnimComJump; param = 20 },
			{ dur = 100; num = 2 }	
		}
	},
	{ 
		name = "ready";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComPushInt; param = 10 },
			{ com = constants.AnimComPushInt; param = 8 },
			{ com = constants.AnimComPushInt; param = 6 },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComSetAnimOnTargetPos; param = 3 },
			{ dur = 0; num = 2 },
			{ com = constants.AnimComSetAnim; txt = "forward" },
			{ dur = 0; num = 2 },
			{ com = constants.AnimComSetAnim; txt = "down" },
			{ dur = 0; num = 2 },
			{ com = constants.AnimComSetAnim; txt = "back" }
		}
	},
	{ 
		name = "forward";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComJumpIfTargetY; param = 3 },
			{ com = constants.AnimComJump; param = 20 },
			{ dur = 0 },
			{ com = constants.AnimComAdjustAim; param = 4 },
			{ dur = 100; num = 2 },
			{ com = constants.AnimComPushInt; param = 30 },
			{ com = constants.AnimComPushInt; param = 30 },
			{ com = constants.AnimComAimedShot; txt = "fireshot" },
			{ dur = 200; num = 2 },
			{ com = constants.AnimComPushInt; param = 30 },
			{ com = constants.AnimComPushInt; param = 30 },
			{ com = constants.AnimComAimedShot; txt = "fireshot" },
			{ dur = 200; num = 2 },
			{ com = constants.AnimComPushInt; param = 30 },
			{ com = constants.AnimComPushInt; param = 30 },
			{ com = constants.AnimComAimedShot; txt = "fireshot" },
			{ dur = 800; num = 2 },
			{ com = constants.AnimComSetAnim; txt = "ready" },
			{ dur = 100; num = 2 },
			{ com = constants.AnimComSetAnim; txt = "ready" }
		}
	},
	{ 
		name = "down";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComJumpIfTargetY; param = 3 },
			{ com = constants.AnimComJump; param = 20 },
			{ dur = 0 },
			{ com = constants.AnimComAdjustAim; param = 4 },
			{ dur = 100; num = 3 },
			{ com = constants.AnimComPushInt; param = 5 },
			{ com = constants.AnimComPushInt; param = 45 },
			{ com = constants.AnimComAimedShot; txt = "fireshot" },
			{ dur = 200; num = 3 },
			{ com = constants.AnimComPushInt; param = 5 },
			{ com = constants.AnimComPushInt; param = 45 },
			{ com = constants.AnimComAimedShot; txt = "fireshot" },
			{ dur = 200; num = 3 },
			{ com = constants.AnimComPushInt; param = 5 },
			{ com = constants.AnimComPushInt; param = 45 },
			{ com = constants.AnimComAimedShot; txt = "fireshot" },
			{ dur = 800; num = 3 },
			{ com = constants.AnimComSetAnim; txt = "ready" },
			{ dur = 100; num = 3 },
			{ com = constants.AnimComSetAnim; txt = "ready" }
		}
	},
	{ 
		name = "back";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 14 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComJumpIfTargetY; param = 3 },
			{ com = constants.AnimComJump; param = 20 },
			{ dur = 0 },
			{ com = constants.AnimComAdjustAim; param = 4 },
			{ dur = 100; num = 4 },
			{ com = constants.AnimComPushInt; param = -30 },
			{ com = constants.AnimComPushInt; param = 30 },
			{ com = constants.AnimComAimedShot; txt = "fireshot" },
			{ dur = 200; num = 4 },
			{ com = constants.AnimComPushInt; param = -30 },
			{ com = constants.AnimComPushInt; param = 30 },
			{ com = constants.AnimComAimedShot; txt = "fireshot" },
			{ dur = 200; num = 4 },
			{ com = constants.AnimComPushInt; param = -30 },
			{ com = constants.AnimComPushInt; param = 30 },
			{ com = constants.AnimComAimedShot; txt = "fireshot" },
			{ dur = 800; num = 4 },
			{ com = constants.AnimComSetAnim; txt = "ready" },
			{ dur = 100; num = 4 },
			{ com = constants.AnimComSetAnim; txt = "ready" }
		}
	},
	{ 
		name = "die";
		frames = 
		{
			{ com = constants.AnimComCallFunction; txt = "iicopter_part_destroyed" },
			{ com = constants.AnimComMapVarAdd; param = 500; txt = "score" },
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComSetBulletCollidable; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "explosion-safe" },
			{ dur = 100, num = 5 }
		}
	}

}
