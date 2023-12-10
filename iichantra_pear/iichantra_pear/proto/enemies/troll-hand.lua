physic = 1;
phys_solid = 0;
phys_bullet_collidable = 0;
phys_max_x_vel = 200;
phys_max_y_vel = 50;
phys_jump_vel = 20;
phys_walk_acc = 3;
mp_count = 1;
offscreen_distance = 640
offscreen_behavior = constants.offscreenNone

mass = -1; --Бесконечно большая масса.


drops_shadow = 1;

-- Описание спрайта

texture = "troll-hand";

z = -0.2;

faction_id = 1
faction_hates = { -1, -2 }

local dx = 17
local dy = -23

animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComSetHealth; param = health },
			{ com = constants.AnimComRealW; param = 89 },
			{ com = constants.AnimComRealH; param = 54 },
			{ com = constants.AnimComMirror },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{
		name = "idle";
		frames =
		{
			{ dur = 100; num = 0; com = constants.AnimComWaitForTarget; param = 30000; txt = "move" },
			{ dur = 100; num = 1; com = constants.AnimComWaitForTarget; param = 30000; txt = "move" },
			{ dur = 100; num = 2; com = constants.AnimComWaitForTarget; param = 30000; txt = "move" },
			{ dur = 100; num = 1; com = constants.AnimComWaitForTarget; param = 30000; txt = "move" },
			{ com = constants.AnimComLoop }
		}
	},
	{ 
		name = "move";
		frames = 
		{
--TODO: Not yo move if y close to that of player or less than -29
			{ dur = 100; num = 0; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 2; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 0; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 2; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 0; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 2; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 0; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 2; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 0; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 2; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetY; param = 50 },
			{ com = constants.AnimComSetAnim; param = 128; txt = "shoot_beam" },
			{ com = constants.AnimComSetAnim; txt = "shoot_spread" },
		}
	},
	{
		name = "shoot_beam";
		frames =
		{
			{ dur = 100; num = 3; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 4; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 3; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 4; com = constants.AnimComMoveToTargetY; param = 50 },
			{ dur = 100; num = 3; },
			{ dur = 100; num = 4; },
			{ com = constants.AnimComRealY; param = 21 },
			{ com = constants.AnimComPushInt; param = 17 },
			{ com = constants.AnimComPushInt; param = -23 },
			{ dur = 100; num = 5; com = constants.AnimComCreateEnemyRay; txt = "troll-cancerray" },
			{ com = constants.AnimComRealY; param = 0 },
			{ dur = 600; num = 0; com = constants.AnimComStop },
			{ com = constants.AnimComSetAnim; txt = "move" },
		}
	},
	{
		name = "shoot_spread";
		frames =
		{
			{ dur = 100; num = 3; },
			{ dur = 100; num = 4; },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile" },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = -23 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile" },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = 23 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile" },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = -45 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile" },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = 45 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile" },
			{ dur = 100; num = 5; },
			{ com = constants.AnimComSetAnim; txt = "move" },
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
		name = "stage2";
		frames = 
		{
--TODO: Not yo move if y close to that of player or less than -29
			{ dur = 100; num = 0; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 2; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 0; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 2; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 0; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 2; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 0; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 2; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 0; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 2; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetY; param = 70 },

			{ com = constants.AnimComSetAnim; param = 128; txt = "shoot_beam2" },
			{ com = constants.AnimComSetAnim; txt = "shoot_spread2" },
		}
	},
	{
		name = "shoot_beam2";
		frames =
		{
			{ dur = 100; num = 3; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 4; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 3; com = constants.AnimComMoveToTargetY; param = 70 },
			{ dur = 100; num = 4; com = constants.AnimComMoveToTargetY; param = 70 },
			{ com = constants.AnimComRealY; param = 21 },
			{ com = constants.AnimComPushInt; param = 17 },
			{ com = constants.AnimComPushInt; param = -23 },
			{ dur = 100; num = 5; com = constants.AnimComCreateEnemyRay; txt = "troll-cancerray" },
			{ com = constants.AnimComRealY; param = 0 },
			{ dur = 300; num = 0; com = constants.AnimComStop },
			{ com = constants.AnimComSetAnim; txt = "move" },
		}
	},
	{
		name = "shoot_spread2";
		frames =
		{
			{ dur = 100; num = 3; },
			{ dur = 100; num = 4; },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile2" },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = -23 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile2" },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = 23 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile2" },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = -45 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile2" },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = 45 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile2" },
			{ dur = 100; num = 5; },
			{ dur = 100; num = 3; },
			{ dur = 100; num = 4; },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile2" },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = -23 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile2" },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = 23 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile2" },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = -45 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile2" },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = 45 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile2" },
			{ dur = 100; num = 5; },
			{ dur = 100; num = 3; },
			{ dur = 100; num = 4; },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile2" },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = -23 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile2" },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = 23 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile2" },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = -45 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile2" },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = 45 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile2" },
			{ dur = 100; num = 5; },
			{ com = constants.AnimComSetAnim; txt = "move" },
		}
	},
	{
		name = "target_dead";
		frames =
		{
			{ com = constants.AnimComSetAnim; txt = "idle" }
		}
	},

}



