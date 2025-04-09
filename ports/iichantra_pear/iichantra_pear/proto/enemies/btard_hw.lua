parent = "enemies/btard";
texture = "btard_hw";

animations =
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 36 },
			{ com = constants.AnimComRealH; param = 75 },
			{ com = constants.AnimComSetHealth; param = 20*difficulty },
			{ com = constants.AnimComPushInt; param = 230 },
			{ com = constants.AnimComPushInt; param = 250 },
			{ com = constants.AnimComPushInt; param = 38 },
			{ com = constants.AnimComPushInt; param = 58 },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = 22 },
			{ com = constants.AnimComControlledOverlayColor },
			{ com = constants.AnimComSetNearestWaypoint },
			{ com = constants.AnimComSetAnim; txt = "waypoints" }	
		}
	},
	{
		-- Создание
		name = "waypoints";
		frames = 
		{
			{ dur = 0 },
			{ com = constants.AnimComRealX; param = 11 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 36 },
			{ com = constants.AnimComRealH; param = 75 },
			{ com = constants.AnimComEnvSound; param = 1},
			{ com = constants.AnimComPushInt; param = 2+8+64 },
			{ com = constants.AnimComFlyToWaypoint; param = 1600 },
			{ dur = 100; num = 5; com = constants.AnimComWaitForTarget; param = 300; txt = "waypoints_stop" },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 6; com = constants.AnimComWaitForTarget; param = 300; txt = "waypoints_stop" },
			{ com = constants.AnimComRealX; param = 6 },
			{ dur = 100; num = 7; com = constants.AnimComWaitForTarget; param = 300; txt = "waypoints_stop" },
			{ com = constants.AnimComRealX; param = 18 },
			{ com = constants.AnimComEnvSound; },
			{ dur = 100; num = 8; com = constants.AnimComWaitForTarget; param = 300; txt = "waypoints_stop" },
			{ com = constants.AnimComRealX; param = 12 },
			{ dur = 100; num = 9; com = constants.AnimComWaitForTarget; param = 300; txt = "waypoints_stop" },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 10; com = constants.AnimComWaitForTarget; param = 300; txt = "waypoints_stop" },
			{ com = constants.AnimComLoop },
		}

	},
	{
		name = "waypoints_stop";
		frames =
		{
			{ com = constants.AnimComPushInt; param = 2+8+64 },
			{ com = constants.AnimComFlyToWaypoint; param = 0 },
			{ com = constants.AnimComSetAnim; txt = "move" }
		}
	},
	{
		name = "think";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 36 },
			{ com = constants.AnimComRealH; param = 75 },
			{ dur = 200; num = 0; com = constants.AnimComWaitForTarget; param = 100; txt = "move" },
			{ dur = 200; num = 1; com = constants.AnimComWaitForTarget; param = 100; txt = "move" },
			{ dur = 200; num = 2; com = constants.AnimComWaitForTarget; param = 100; txt = "move" },
			{ dur = 200; num = 3; com = constants.AnimComWaitForTarget; param = 100; txt = "move" },
			{ dur = 200; num = 4; com = constants.AnimComWaitForTarget; param = 100; txt = "move" },
			--Выходим после каждого цикла с вероятностью 0.5
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComJumpRandom; param = 15 },
			{ com = difcom; param = 16 },
			{ com = constants.AnimComSetAnim; txt = "waypoints" },
			{ com = constants.AnimComLoop },
			{ dur = 0 },
			{ com = constants.AnimComPushInt; param = 640 },
			{ com = constants.AnimComJumpIfTargetClose; param = 18 },
			{ com = constants.AnimComSetAnim; txt = "waypoints" },
			{ dur = 0 },
			{ com = constants.AnimComSetAnim; txt = "waypoints" }
		}
	},
	{
		name = "land";
		frames =
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 36 },
			{ com = constants.AnimComRealH; param = 75 },
			{ com = constants.AnimComEnvSound; },
			{ com = constants.AnimComPushInt; param = -128 },
			{ com = constants.AnimComPushInt; param = -56 },
			{ com = constants.AnimComCreateObject; txt = "dust-land" },
			{ com = constants.AnimComSetAnim; txt = "waypoints" }				
		}
	},
	{
		name = "jump";
		frames =
		{
			{ com = constants.AnimComSetAnim; txt = "waypoints" }				
		}
	},
	{ 
		-- Создание
		name = "die";
		frames = 
		{
			{ com = constants.AnimComCallFunction; txt = "hw_enemy_dead" },
			{ com = constants.AnimComSetBulletCollidable; param = 0 },
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 36 },
			{ com = constants.AnimComRealH; param = 78 },
			{ com = constants.AnimComMapVarAdd; param = difficulty*10; txt = "score" },
			{ com = constants.AnimComMapVarAdd; param = 1; txt = "kills" },
			{ com = constants.AnimComPushInt; param = 50 },
			{ com = constants.AnimComJumpRandom; param = 12 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateItem; txt = "ammo" },
			{ dur = 100; num = 18 },
			{ com = constants.AnimComRealH; param = 77 },	
			{ dur = 100; num = 19 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 28 },
			{ dur = 100; num = 20; com = constants.AnimComCreateParticles; txt = "pblood2"; param = 2 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 28 },
			{ dur = 100; num = 20; com = constants.AnimComCreateParticles; txt = "pblood3" },
			{ dur = 100; num = 21 },
			{ com = constants.AnimComRealH; param = 75 },
			{ dur = 100; num = 22 },
			{ com = constants.AnimComRealH; param = 68 },
			{ dur = 100; num = 23 },
			{ com = constants.AnimComRealH; param = 55 },
			{ dur = 100; num = 24 },
			{ com = constants.AnimComPushInt; param = -128 },
			{ com = constants.AnimComPushInt; param = -77 },
			{ com = constants.AnimComEnvSound; },
			{ com = constants.AnimComEnvSound; param = 1 },
			{ com = constants.AnimComRealH; param = 30 },
			{ dur = 100; num = 25, com = constants.AnimComCreateObject; txt = "dust-land" },
			{ com = constants.AnimComRealH; param = 25 },
			{ dur = 100; num = 26 },
			{ com = constants.AnimComPushInt; param = -128 },
			{ com = constants.AnimComPushInt; param = -64 },
			{ com = constants.AnimComRealH; param = 21 },
			{ dur = 5000; num = 27 },
			{ com = constants.AnimComPushInt; param = 320 },
			{ com = constants.AnimComPushInt; param = 240 },
			{ dur = 1; num = 0; com = constants.AnimComJumpIfCloseToCamera; param = 40 }
		}
	},

}
