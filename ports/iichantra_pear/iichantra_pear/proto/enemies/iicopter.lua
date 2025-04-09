physic = 1;
phys_solid = 0;
--phys_ghostlike = 1;
phys_bullet_collidable = 0;
phys_max_x_vel = 20;
phys_max_y_vel = 30;
phys_jump_vel = 20;
phys_walk_acc = 10;
phys_one_sided = 0;
mp_count = 7;
offscreen_distance = 640
offscreen_behavior = constants.offscreenNone

FunctionName = "CreateEnemy";

-- Описание спрайта

texture = "iicopter";

drops_shadow = 1;

z = -0.1;

faction_id = 1;
faction_hates = {-1, -2};

animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			--{ com = constants.AnimComRealW; param = 419 },
			{ com = constants.AnimComRealW; param = 319 },
			{ com = constants.AnimComRealX; param = 100 },
			{ com = constants.AnimComRealH; param = 245 },
			{ com = constants.AnimComSetHealth; param = 1100 },
			{ dur = 1 },
			--{ com = constants.AnimComPushInt; param = 139 },
			--{ com = constants.AnimComPushInt; param = 95 },
			{ com = constants.AnimComPushInt; param = -7 },
			{ com = constants.AnimComPushInt; param = 22 },
			{ com = constants.AnimComMPSet; param = 2 },
			{ com = constants.AnimComPushInt; param = 124 },
			{ com = constants.AnimComPushInt; param = 97 },
			{ com = constants.AnimComMPSet; param = 3 },
			{ com = constants.AnimComPushInt; param = -84 },
			{ com = constants.AnimComPushInt; param = -88 },
			{ com = constants.AnimComMPSet; param = 4 },
			{ com = constants.AnimComPushInt; param = 25 },
			{ com = constants.AnimComPushInt; param = 85 },
			{ com = constants.AnimComMPSet; param = 5 },
			{ com = constants.AnimComPushInt; param = 59 },
			{ com = constants.AnimComPushInt; param = -42 },
			{ com = constants.AnimComMPSet; param = 6 },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEffect; txt = "iicopter-door"; param = 5 },
			{ com = constants.AnimComPushInt; param = 3 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEffect; txt = "iicopter-gun"; param = 5 },
			{ com = constants.AnimComPushInt; param = 4 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEffect; txt = "iicopter-smoke"; param = 5 },
			{ com = constants.AnimComPushInt; param = 5 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEffect; txt = "iicopter-bombs"; param = 5 },
			{ com = constants.AnimComPushInt; param = 6 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEffect; txt = "iicopter-rockets"; param = 5 },
			--{ com = constants.AnimComSetWaypoint; param = 1 },

			{ com = constants.AnimComSetAnim; txt = "fly_loop" }	
		}
	},
	{ 
		-- Создание
		name = "alt-init";
		frames = 
		{
			--{ com = constants.AnimComRealW; param = 419 },
			{ com = constants.AnimComRealW; param = 319 },
			{ com = constants.AnimComRealX; param = 100 },
			{ com = constants.AnimComRealH; param = 245 },
			{ com = constants.AnimComSetHealth; param = 1100 },
			{ dur = 1 },
			--{ com = constants.AnimComPushInt; param = 139 },
			--{ com = constants.AnimComPushInt; param = 95 },
			{ com = constants.AnimComPushInt; param = -7 },
			{ com = constants.AnimComPushInt; param = 22 },
			{ com = constants.AnimComMPSet; param = 2 },
			{ com = constants.AnimComPushInt; param = 124 },
			{ com = constants.AnimComPushInt; param = 97 },
			{ com = constants.AnimComMPSet; param = 3 },
			{ com = constants.AnimComPushInt; param = -84 },
			{ com = constants.AnimComPushInt; param = -88 },
			{ com = constants.AnimComMPSet; param = 4 },
			{ com = constants.AnimComPushInt; param = 25 },
			{ com = constants.AnimComPushInt; param = 85 },
			{ com = constants.AnimComMPSet; param = 5 },
			{ com = constants.AnimComPushInt; param = 59 },
			{ com = constants.AnimComPushInt; param = -42 },
			{ com = constants.AnimComMPSet; param = 6 },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEffect; txt = "iicopter-door"; param = 5 },
			{ com = constants.AnimComPushInt; param = 3 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEffect; txt = "iicopter-gun"; param = 5 },
			{ com = constants.AnimComPushInt; param = 4 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEffect; txt = "iicopter-smoke"; param = 5 },
			{ com = constants.AnimComPushInt; param = 5 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEffect; txt = "iicopter-bombs"; param = 5 },
			{ com = constants.AnimComPushInt; param = 6 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEffect; txt = "iicopter-rockets"; param = 5 },
			--{ com = constants.AnimComSetWaypoint; param = 1 },

			{ com = constants.AnimComSetAnim; txt = "alt_fly_loop" }	
		}
	},
	{
		name = "hold_still_damn_it_i_need_to_test_your_parts";
		frames =
		{
			{ dur = 100; num = 0; com = constants.AnimComFlyToWaypoint }
		}
	},
	{
		name = "fly_loop";
		frames =
		{
			{ com = constants.AnimComPlaySound; txt = "heli.ogg" },
			{ com = constants.AnimComPushInt; param = 2000 },
			{ com = constants.AnimComPushInt; param = 2 },
			{ dur = 100; num = 0; com = constants.AnimComFlyToWaypoint; param = 20 },
			{ com = constants.AnimComPushInt; param = 2000 },
			{ com = constants.AnimComPushInt; param = 2 },
			{ dur = 100; num = 0; com = constants.AnimComFlyToWaypoint; param = 20 },
			{ com = constants.AnimComPushInt; param = 2000 },
			{ com = constants.AnimComPushInt; param = 2 },
			{ dur = 100; num = 0; com = constants.AnimComFlyToWaypoint; param = 20 },
			{ com = constants.AnimComPushInt; param = 2000 },
			{ com = constants.AnimComPushInt; param = 2 },
			{ dur = 100; num = 0; com = constants.AnimComFlyToWaypoint; param = 20 },
			{ com = constants.AnimComPushInt; param = 2000 },
			{ com = constants.AnimComPushInt; param = 2 },
			{ dur = 100; num = 0; com = constants.AnimComFlyToWaypoint; param = 20 },
			{ com = constants.AnimComPushInt; param = 2000 },
			{ com = constants.AnimComPushInt; param = 2 },
			{ dur = 100; num = 0; com = constants.AnimComFlyToWaypoint; param = 20 },
			{ com = constants.AnimComPushInt; param = 2000 },
			{ com = constants.AnimComPushInt; param = 2 },
			{ dur = 100; num = 0; com = constants.AnimComFlyToWaypoint; param = 20 },
			{ com = constants.AnimComPushInt; param = 2000 },
			{ com = constants.AnimComPushInt; param = 2 },
			{ dur = 50; num = 0; com = constants.AnimComFlyToWaypoint; param = 20 },
			{ com = constants.AnimComLoop }
		}
	},
	{
		name = "alt_fly_loop";
		frames =
		{
			{ com = constants.AnimComPlaySound; txt = "heli.ogg" },
			{ com = constants.AnimComPushInt; param = 2000 },
			{ com = constants.AnimComPushInt; param = 98 },
			{ dur = 100; num = 0; com = constants.AnimComFlyToWaypoint; param = 20 },
			{ com = constants.AnimComPushInt; param = 2000 },
			{ com = constants.AnimComPushInt; param = 98 },
			{ dur = 100; num = 0; com = constants.AnimComFlyToWaypoint; param = 20 },
			{ com = constants.AnimComPushInt; param = 2000 },
			{ com = constants.AnimComPushInt; param = 98 },
			{ dur = 100; num = 0; com = constants.AnimComFlyToWaypoint; param = 20 },
			{ com = constants.AnimComPushInt; param = 2000 },
			{ com = constants.AnimComPushInt; param = 98 },
			{ dur = 100; num = 0; com = constants.AnimComFlyToWaypoint; param = 20 },
			{ com = constants.AnimComPushInt; param = 2000 },
			{ com = constants.AnimComPushInt; param = 98 },
			{ dur = 100; num = 0; com = constants.AnimComFlyToWaypoint; param = 20 },
			{ com = constants.AnimComPushInt; param = 2000 },
			{ com = constants.AnimComPushInt; param = 98 },
			{ dur = 100; num = 0; com = constants.AnimComFlyToWaypoint; param = 20 },
			{ com = constants.AnimComPushInt; param = 2000 },
			{ com = constants.AnimComPushInt; param = 98 },
			{ dur = 100; num = 0; com = constants.AnimComFlyToWaypoint; param = 20 },
			{ com = constants.AnimComPushInt; param = 2000 },
			{ com = constants.AnimComPushInt; param = 98 },
			{ dur = 50; num = 0; com = constants.AnimComFlyToWaypoint; param = 20 },
			{ com = constants.AnimComLoop }
		}
	},
	{
		name = "black_duck_down";
		frames = 
		{
			{ com = constants.AnimComDestroyObject; param = 3 },
			{ com = constants.AnimComPlaySound; txt = "explosion.ogg" },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 400 },
			{ com = constants.AnimComSetGravity },
			{ com = constants.AnimComMapVarAdd; param = 1500; txt = "score" },
			{ com = constants.AnimComMapVarAdd; param = 1; txt = "kills" },
			{ num = 0; dur = 1 },
			{ com = constants.AnimComJumpIfOnPlane; param = 10 },
			{ com = constants.AnimComJump; param = 7 },
			{ dur = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "explosion-safe" },
			{ com = constants.AnimComPushInt; param = -29 },
			{ com = constants.AnimComPushInt; param = 31 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "explosion-safe" },
			{ com = constants.AnimComPushInt; param = 18 },
			{ com = constants.AnimComPushInt; param = 31 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "explosion-safe" },
			{ com = constants.AnimComPushInt; param = -100 },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "explosion-safe" },
			{ com = constants.AnimComPushInt; param = -100 },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "explosion-safe" },
			{ com = constants.AnimComPushInt; param = -50 },
			{ com = constants.AnimComPushInt; param = -100 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "explosion-safe" },
			{ com = constants.AnimComPushInt; param = 150 },
			{ com = constants.AnimComPushInt; param = -46 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "explosion-safe" },
			{ com = constants.AnimComPushInt; param = -111 },
			{ com = constants.AnimComPushInt; param = -142 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "explosion-safe" },
			{ com = constants.AnimComDestroyObject }

		}
	},
	{ 
		name = "ready";
		frames = 
		{
			{ dur = 0; num = 0 },
			{ com = constants.AnimComSetAccX; param = -20},
			{ dur = 500; num = 0 },
			{},
			{ com = constants.AnimComSetAccX; param = 20},
			{ dur = 1000; num = 0 },
			{ com = constants.AnimComSetAccX; param = -20 },
			{ dur = 1000; num = 0 },
			{ com = constants.AnimComJump; param = 3 }
		}
	},
--[[
	{
		name = "land";
		frames =
		{
			{ com = constants.AnimComSetAnim; txt = "fly_loop" }
		}
	}
--]]
}



