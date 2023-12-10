--forbidden

z = 0.8;
phys_ghostlike = 1;
texture = "iicopter";
physic = 1;
phys_bullet_collidable = 0;
offscreen_distance = 640
offscreen_behavior = constants.offscreenNone

effect = 1;

animations = 
{
	{
		name = "idle";
		frames =
		{
			{ com = constants.AnimComSetHealth; param = 100 },
			{ com = constants.AnimComRealW; param = 96 },
			{ com = constants.AnimComRealH; param = 26 },
			{ dur = 1; num = 13 },
			{ com = constants.AnimComCallFunction; txt = "iicopter_part_created" },
			{ com = constants.AnimComSetAnim; txt = "drop" }
		}
	},
	{
		name = "inactive";
		frames =
		{
			{ dur = 100; num = 13 }
		}
	},
	{ 
		name = "drop";
		frames = 
		{
			{ dur = 2600; num = 13 },
			{ com = constants.AnimComSetBulletCollidable; param = 1 },
			{ dur = 100; num = 9 },
			{ dur = 100; num = 10 },
			{ dur = 100; num = 11 },
			{ dur = 100; num = 12 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 20 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "iicopter-bomb"; param = 0 },
			{ dur = 400; num = 12 },
			{ dur = 100; num = 11 },
			{ dur = 100; num = 10 },
			{ dur = 100; num = 9 },
			{ com = constants.AnimComSetBulletCollidable; param = 0 },
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
			{ com = constants.AnimComCreateEnemyBullet; txt = "explosion-bomb" },
			{ dur = 100, num = 13 }
		}
	}
}
