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

drops_shadow = 1;

gravity_x = 0;
gravity_y = 0.8;

mass = -1;

faction_id = 1;
faction_hates = { -1, -2 };

-- Описание спрайта

texture = "cmaniac";

z = -0.1;

animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 34 },
			{ com = constants.AnimComRealH; param = 74 },
			{ com = constants.AnimComSetTouchable; param = 1 },
			{ com = constants.AnimComSetHealth; param = 1500 },
			--{ com = constants.AnimComSetHealth; param = 20 },
			{ dur = 1 },
			{ dur = 1; com = constants.AnimComSetAnim; txt = "idle_indefenite"},
			{ com = constants.AnimComLoop }	
		}
	},
	{
		name = "idle_indefinite";
		frames =
		{
			{ com = constants.AnimComSetTouchable; param = 1 },
			{ com = constants.AnimComPushInt; param = 2+8+64 },
			{ com = constants.AnimComFlyToWaypoint; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 34 },
			{ com = constants.AnimComRealH; param = 74 },
			{ com = constants.AnimComRealX; param = 0 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComRealX; param = -1 },
			{ dur = 100; num = 1; },
			{ com = constants.AnimComRealX; param = -3 },
			{ dur = 100; num = 2; },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 2; },
			{ com = constants.AnimComRealX; param = -1 },
			{ dur = 100; num = 1; },
			{ com = constants.AnimComRealX; param = 0 },
			{ constants.AnimComLoop }
		}
	},
	{
		name = "pre-idle";
		frames =
		{
			{ com = constants.AnimComMirror },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEnemy; param = 4; txt = "cm-energy-shooter"},
			{ com = constants.AnimComWaitForTarget; txt = "idle"; param = 64000 }
		}
	},
	{ 
		-- Создание
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComSetTouchable; param = 1 },
			{ com = constants.AnimComPushInt; param = 2+8+64 },
			{ com = constants.AnimComFlyToWaypoint; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 34 },
			{ com = constants.AnimComRealH; param = 74 },
			{ com = constants.AnimComRealX; param = 0 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComRealX; param = -1 },
			{ dur = 100; num = 1; },
			{ com = constants.AnimComRealX; param = -3 },
			{ dur = 100; num = 2; },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 2; },
			{ com = constants.AnimComRealX; param = -1 },
			{ dur = 100; num = 1; },
			{ com = constants.AnimComRealX; param = 0 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComRealX; param = -1 },
			{ dur = 100; num = 1; },
			{ com = constants.AnimComRealX; param = -3 },
			{ dur = 100; num = 2; },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 2; },
			{ com = constants.AnimComRealX; param = -1 },
			{ dur = 100; num = 1; },
			{ com = constants.AnimComRealX; param = 0 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComRealX; param = -1 },
			{ dur = 100; num = 1; },
			{ com = constants.AnimComRealX; param = -3 },
			{ dur = 100; num = 2; },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 2; },
			{ com = constants.AnimComRealX; param = -1 },
			{ dur = 100; num = 1; },
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComSetAnim; txt = "shoot"; param = 196 },
			{ com = constants.AnimComSetAnim; txt = "move_script" },
		}
	},
	{
		name = "touch";
		frames =
		{
			{ com = constants.AnimComJumpIfPlayerId; param = 3 },
			{ com = constants.AnimComSetTouchable; param = 1 },
			{ com = constants.AnimComSetAnim; txt = "move" },
			{ dur = 0 },
			{ com = constants.AnimComDealDamage; param = 40 },
			{ com = constants.AnimComRecover }
		}
	},
	{ 
		-- Создание
		name = "pain";
		frames = 
		{
			{ com = constants.AnimComPop },
			{ com = constants.AnimComReduceHealth },
			{ com = constants.AnimComCallFunction; txt = "cm_hurt" },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateParticles; txt = "pblood-wound"; param = 2 },
			{ com = constants.AnimComRecover }
		}
	},
	{ 
		-- Создание
		name = "move_script";
		frames = 
		{
			{ com = constants.AnimComCallFunction; txt = "cm_move" }
		}
	},
	{ 
		-- Создание
		name = "move";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 2+8+64 },
			{ com = constants.AnimComFlyToWaypoint; param = 6400 },
			
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 50 },
			{ com = constants.AnimComRealH; param = 75 },
			{ com = constants.AnimComEnvSound; param = 1},
			{ dur = 100; num = 6 },
			{ dur = 100; num = 7 },
			{ dur = 100; num = 8 },
			{ dur = 100; num = 9 },
			{ dur = 100; num = 10 },
			{ dur = 100; num = 11 },
			{ dur = 100; num = 12 },
			{ dur = 100; num = 13 },
			{ dur = 100; num = 14 },
			{ com = constants.AnimComLoop },
		}
	},
	{
		name = "stop";
		frames =
		{
			{ com = constants.AnimComPushInt; param = 2+8+64 },
			{ com = constants.AnimComFlyToWaypoint; param = 0 },
			{ num = 4; dur = 300 },
			{ com = constants.AnimComStop },
			{ com = constants.AnimComMirror },
			{ com = constants.AnimComSetAnim; txt = "idle" }
		}
	},
	{
		name = "shoot";
		frames =
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 39 },
			{ com = constants.AnimComRealH; param = 75 },
			{ com = constants.AnimComFaceTarget },
			{ dur = 50; num = 15 },
			{ dur = 50; num = 16 },
			{ dur = 50; num = 17 },
			{ dur = 50; num = 19 },
			{ dur = 100; num = 20 },
			{ com = constants.AnimComAdjustAim; param = 4 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -10 },
			{ com = constants.AnimComAimedShot; txt = "fireshot-cm" },
			{ dur = 100; num = 21 },
			{ dur = 100; num = 15 },
			{ com = constants.AnimComFaceTarget },
			{ dur = 50; num = 15 },
			{ dur = 50; num = 16 },
			{ dur = 50; num = 17 },
			{ dur = 50; num = 19 },
			{ dur = 100; num = 20 },
			{ com = constants.AnimComAdjustAim; param = 4 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -10 },
			{ com = constants.AnimComAimedShot; txt = "fireshot-cm" },
			{ dur = 100; num = 21 },
			{ dur = 100; num = 15 },
			{ com = constants.AnimComFaceTarget },
			{ dur = 50; num = 15 },
			{ dur = 50; num = 16 },
			{ dur = 50; num = 17 },
			{ dur = 50; num = 19 },
			{ dur = 100; num = 20 },
			{ com = constants.AnimComAdjustAim; param = 4 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -10 },
			{ com = constants.AnimComAimedShot; txt = "fireshot-cm" },
			{ dur = 100; num = 21 },
			{ dur = 100; num = 15 },
			{ com = constants.AnimComSetAnim; txt = "idle" }
		}
	},
	{
		name = "die";
		frames =
		{
			{ com = constants.AnimComDestroyObject; param = 3 },
			{ com = constants.AnimComSetBulletCollidable; param = 0 },
			{ com = constants.AnimComMapVarAdd; param = difficulty*10000; txt = "score" },
			{ com = constants.AnimComMapVarAdd; param = 1; txt = "kills" },
			{ com = constants.AnimComCallFunction; txt = "cm_dead" },
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 10 },
			{ com = constants.AnimComRealH; param = 77 },
			{ dur = 100; num = 22 },
			{ dur = 100; num = 23; com = constants.AnimComRealH; param = 78 },
			{ dur = 100; num = 24; com = constants.AnimComRealH; param = 72 },
			{ dur = 100; num = 25; com = constants.AnimComRealH; param = 63 },
			{ dur = 100; num = 26; com = constants.AnimComRealH; param = 51 },
			{ dur = 100; num = 27; com = constants.AnimComRealH; param = 51 },
			{ com = constants.AnimComRealX; param = 10 },
			{ dur = 100; num = 28; com = constants.AnimComRealH; param = 43 },
			{ com = constants.AnimComRealX; param = 50 },
			{ dur = 100; num = 29; com = constants.AnimComRealH; param = 35 },
			{ com = constants.AnimComJump; param = 17 }
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



