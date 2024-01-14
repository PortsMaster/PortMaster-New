--forbidden

z = 0.8;
phys_ghostlike = 1;
texture = "iicopter";
physic = 1;
phys_bullet_collidable = 1;
offscreen_distance = 640
offscreen_behavior = constants.offscreenNone

effect = 1;

overlay = {0};

animations = 
{
	{
		name = "idle";
		frames =
		{
			{ com = constants.AnimComSetHealth; param = 100 },
			{ com = constants.AnimComRealW; param = 160 },
			{ com = constants.AnimComRealH; param = 58 },
			{ dur = 1; num = 17 },
			{ com = constants.AnimComCallFunction; txt = "iicopter_part_created" },
			{ com = constants.AnimComSetAnim; txt = "fire" }
		}
	},
	{
		name = "inactive";
		frames = 
		{
			{ dur = 100, num = 17 }
		}
	},
	{ 
		name = "fire";
		frames = 
		{
			{ dur = 1300; num = 18 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ constants.AnimComJumpIfTargetX; param =  4 },
			{ constants.AnomComLoop },
			{},
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 20 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "iicopter-rocket"; param = 0 },
			{ dur = 400; num = 18 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 20 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "iicopter-rocket"; param = 0 },
			{ dur = 400; num = 18 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 20 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "iicopter-rocket"; param = 0 },
			{ dur = 1000; num = 18 },
			{ com = constants.AnimComLoop }
		}
	},
	{
		name = "die";
		frames =
		{
			{ com = constants.AnimComCallFunction; txt = "iicopter_part_destroyed" },
			{ com = constants.AnimComMapVarAdd; param = 500; txt = "score" },
			{ com = constants.AnimComSetBulletCollidable; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "explosion-safe" },
			{ dur = 100, num = 17 }
		}
	}
}
