--forbidden
z = 0.8;
phys_ghostlike = 1;
texture = "2011topturret";
physic = 1;
phys_bullet_collidable = 1;
offscreen_behavior = constants.offscreenNone

facing = constants.facingFixed

mass = -1;

faction_id = 1;
faction_hates = { -1, -2 };

animations = 
{
	{
		name = "init";
		frames =
		{
			{ com = constants.AnimComSetHealth; param = 100 },
			{ com = constants.AnimComRealW; param = 30 },
			{ com = constants.AnimComRealH; param = 25 },
			{ com = constants.AnimComSetAnim; txt = "idle" }
		}
	},
	{
		name = "idle";
		frames =
		{
			{ dur = 1; num = 0 },
			{ dur = 1; com = constants.AnimComWait },
			{ com = constants.AnimComSetAnim; txt = "fire" }
		}
	},
	{
		name = "inactive";
		frames =
		{
			{ dur = 100; num = 0 },
			{ dur = 100; num = 1 },
			{ dur = 100; num = 0 },
			{ dur = 100; num = 1 },
			{ dur = 100; num = 0 },
			{ dur = 100; num = 1 },
			{ dur = 100; num = 0 },
			{ dur = 100; num = 1 },
			{ dur = 100; num = 0 },
			{ dur = 100; num = 1 },
			{ dur = 100; num = 0 },
			{ dur = 100; num = 1 },
			{ dur = 100; num = 0 },
			{ dur = 100; num = 1 },
			{ dur = 100; num = 0 },
			{ dur = 100; num = 1 },
			{ com = constants.AnimComSetAnim; txt = "fire" }
		}
	},
	{ 
		name = "fire";
		frames = 
		{
			{ dur = 50; num = 2 },
			{ dur = 50; num = 3 },
			{ dur = 50; num = 4 },
			{ com = constants.AnimComRealX; param = -1 },
			{ dur = 50; num = 5 },
			{ com = constants.AnimComRealX; param = 0 },
			{ dur = 50; num = 6 },
			{ dur = 50; num = 7 },
			{ dur = 50; num = 8 },
			{ com = constants.AnimComPushInt; param = 5 },
			{ com = constants.AnimComPushInt; param = 20 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "topturret-projectile"; param = 0 },
			{ dur = 50; num = 9 },
			{ dur = 50; num = 10 },
			{ com = constants.AnimComSetAnim; txt = "inactive" }
		}
	},
	{
		name = "die";
		frames =
		{
			{ com = constants.AnimComMapVarAdd; param = 1; txt = "kills" },
			{ com = constants.AnimComMapVarAdd; param = 1000; txt = "score" },
			{ com = constants.AnimComSetBulletCollidable; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "explosion-bomb" },
			{ dur = 10000, num = 11 },
			{ com = constants.AnimComJump; param = 5 }
		}
	}
}
