parent = "enemies/slowpoke";
texture = "slowpoke_hw";

animations =
{
	{
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 86; },
			{ com = constants.AnimComRealH; param = 46; },
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComSetHealth; param = health; },
			{ com = constants.AnimComSetTouchable; param = 1; },
			{ com = constants.AnimComSetNearestWaypoint },
			{ com = constants.AnimComSetAnim; txt = "waypoints"; }
		}
	},
	{
		name = "waypoints";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 2+8+64 },
			{ com = constants.AnimComFlyToWaypoint; param = 2000 },
			{ dur = 100; com = constants.AnimComWaitForTarget; param = 400; txt = "waypoints_stop" },
			{ dur = 100; num = 1; com = constants.AnimComWaitForTarget; param = 400; txt = "waypoints_stop" },
			{ dur = 100; num = 2; com = constants.AnimComWaitForTarget; param = 400; txt = "waypoints_stop" },
			{ dur = 100; num = 3; com = constants.AnimComWaitForTarget; param = 400; txt = "waypoints_stop" },
			{ dur = 100; num = 4; com = constants.AnimComWaitForTarget; param = 400; txt = "waypoints_stop" },
			{ dur = 100; num = 5; com = constants.AnimComWaitForTarget; param = 400; txt = "waypoints_stop" },
			{ dur = 100; num = 6; com = constants.AnimComWaitForTarget; param = 400; txt = "waypoints_stop" },
			{ dur = 100; num = 7; com = constants.AnimComWaitForTarget; param = 400; txt = "waypoints_stop" },
			{ com = constants.AnimComLoop; },
		}
	},
	{
		name = "waypoints_stop";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 2+8+64 },
			{ com = constants.AnimComFlyToWaypoint; param = 0 },
			{ com = constants.AnimComSetAnim; txt = "shoot" },
		}
	},
	{
		name = "reinit";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 86; },
			{ com = constants.AnimComRealH; param = 46; },
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComSetAnim; txt = "waypoints"; }
		}
	},
	{
		name = "die";
		frames = 
		{
			{ com = constants.AnimComCallFunction; txt = "hw_enemy_dead" },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 300 },
			{ com = constants.AnimComSetGravity }, 
			{ com = constants.AnimComDrop; param = 1 },
			{ com = constants.AnimComSetTouchable; param = 0; },
			{ com = constants.AnimComSetShadow; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateParticles; txt = "pblood2" },
			{ com = constants.AnimComSetBulletCollidable; param = 0; },
			{ com = constants.AnimComPlaySound; txt = "slowpoke-death.ogg" },
			{ com = constants.AnimComMapVarAdd; param = 30*difficulty; txt = "score"; },
			{ com = constants.AnimComRealX; param = 11; },
			{ dur = 100; num = 17; com = constants.AnimComRealH; param = 45; },
			{ com = constants.AnimComRealX; param = 15; },
			{ dur = 100; num = 18; com = constants.AnimComRealH; param = 46; },
			{ com = constants.AnimComRealX; param = 20; },
			{ dur = 100; num = 19; com = constants.AnimComRealH; param = 58; },
			{ com = constants.AnimComRealX; param = 28; },
			{ dur = 100; num = 20; com = constants.AnimComRealH; param = 48; },
			{ dur = 100; num = 21; com = constants.AnimComRealH; param = 30; },
			{ dur = 100; num = 22; com = constants.AnimComRealH; param = 22; },
			{ com = constants.AnimComSetZ; param = -450 },
			{ dur = 5000; num = 23; com = constants.AnimComRealH; param = 10; },
			{ com = constants.AnimComPushInt; param = 320 },
			{ com = constants.AnimComPushInt; param = 240 },
			{ dur = 1; num = 23; com = constants.AnimComJumpIfCloseToCamera; param = 24 },
			{ com = constants.AnimComDestroyObject; }
		}
	}
}