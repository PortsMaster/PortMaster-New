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

FunctionName = "CreateEnemy";

faction_id = 1;
faction_hates = { -1, -2 };

-- Описание спрайта

texture = "pytard";

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
			{ com = constants.AnimComRealW; param = 108 },
			{ com = constants.AnimComRealH; param = 82 },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{ 
		-- Создание
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 108 },
			{ com = constants.AnimComRealH; param = 82 },
			{ dur = 100; num = 0 },
			{ dur = 100; num = 1; com = constants.AnimComRealX; param = 1 },
			{ dur = 100; num = 2; com = constants.AnimComRealX; param = 3 },
			{ dur = 100; num = 3; com = constants.AnimComRealX; param = 1 },
			{ dur = 100; num = 0; com = constants.AnimComRealX; param = 0 },
			{ dur = 100; num = 1; com = constants.AnimComRealX; param = 1 },
			{ dur = 100; num = 2; com = constants.AnimComRealX; param = 3 },
			{ dur = 100; num = 3; com = constants.AnimComRealX; param = 1 },
			{ dur = 100; num = 0; com = constants.AnimComRealX; param = 0 },
			{ dur = 100; num = 1; com = constants.AnimComRealX; param = 1 },
			{ dur = 100; num = 2; com = constants.AnimComRealX; param = 3 },
			{ dur = 100; num = 3; com = constants.AnimComRealX; param = 1 },
			{ dur = 1; num = 3; com = constants.AnimComWaitForTarget; param = 3000; txt = "move" },
			{ com = constants.AnimComLoop; }	
		}
	},

	{ 
		-- Создание
		name = "pain";
		frames = 
		{
			--{ com = constants.AnimComJumpIfIntEquals; param = 2; txt = "sfg9000" },
			{ com = constants.AnimComPop },
			{ com = constants.AnimComCallFunctionWithStackParameter; txt = "pytard_hurt" },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateParticles; txt = "pblood-wound"; param = 2 },
			{ com = constants.AnimComRecover }
		}
	},
	{ 
		-- Создание
		name = "move";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 84 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 37 },
			{ com = constants.AnimComRealH; param = 78 },
			{ com = constants.AnimComEnvSound; param = 1},
			{ dur = 100; num = 5; com = constants.AnimComMoveToTargetX; param = 200 },
			{ com = constants.AnimComRealX; param = 73 },
			{ dur = 100; num = 6; com = constants.AnimComMoveToTargetX; param = 200 },
			{ com = constants.AnimComRealX; param = 57 },
			{ com = constants.AnimComRealH; param = 79 },
			{ dur = 100; num = 7; com = constants.AnimComMoveToTargetX; param = 200 },
			{ com = constants.AnimComRealH; param = 77 },
			{ com = constants.AnimComRealX; param = 57 },
			{ com = constants.AnimComEnvSound; },
			{ dur = 100; num = 8; com = constants.AnimComMoveToTargetX; param = 200 },
			{ com = constants.AnimComRealX; param = 56 },
			{ dur = 100; num = 9; com = constants.AnimComMoveToTargetX; param = 200 },
			{ com = constants.AnimComRealX; param = 72 },
			{ com = constants.AnimComRealH; param = 80 },
			{ dur = 100; num = 10; com = constants.AnimComMoveToTargetX; param = 200 },
			{ com = constants.AnimComLoop },
		}
	},
	{ 
		-- Создание
		name = "move_left";
		frames = 
		{
			{ com = constants.AnimComSetAccX; param = -200 },
			{ com = constants.AnimComRealX; param = 84 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 37 },
			{ com = constants.AnimComRealH; param = 78 },
			{ com = constants.AnimComEnvSound; param = 1},
			{ dur = 100; num = 5;},
			{ com = constants.AnimComRealX; param = 73 },
			{ dur = 100; num = 6; },
			{ com = constants.AnimComRealX; param = 57 },
			{ com = constants.AnimComRealH; param = 79 },
			{ dur = 100; num = 7; },
			{ com = constants.AnimComRealH; param = 77 },
			{ com = constants.AnimComRealX; param = 57 },
			{ com = constants.AnimComEnvSound; },
			{ dur = 100; num = 8; },
			{ com = constants.AnimComRealX; param = 56 },
			{ dur = 100; num = 9; },
			{ com = constants.AnimComRealX; param = 72 },
			{ com = constants.AnimComRealH; param = 80 },
			{ dur = 100; num = 10; },
			{ com = constants.AnimComLoop },
		}
	},
	{ 
		-- Создание
		name = "move_right";
		frames = 
		{
			{ com = constants.AnimComSetAccX; param = 200 },
			{ com = constants.AnimComRealX; param = 84 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 37 },
			{ com = constants.AnimComRealH; param = 78 },
			{ com = constants.AnimComEnvSound; param = 1},
			{ dur = 100; num = 5; },
			{ com = constants.AnimComRealX; param = 73 },
			{ dur = 100; num = 6; },
			{ com = constants.AnimComRealX; param = 57 },
			{ com = constants.AnimComRealH; param = 79 },
			{ dur = 100; num = 7; },
			{ com = constants.AnimComRealH; param = 77 },
			{ com = constants.AnimComRealX; param = 57 },
			{ com = constants.AnimComEnvSound; },
			{ dur = 100; num = 8; },
			{ com = constants.AnimComRealX; param = 56 },
			{ dur = 100; num = 9; },
			{ com = constants.AnimComRealX; param = 72 },
			{ com = constants.AnimComRealH; param = 80 },
			{ dur = 100; num = 10; },
			{ com = constants.AnimComLoop },
		}
	},
	{
		name = "attack";
		frames =
		{
			{ com = constants.AnimComRealX; param = 83 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 37 },
			{ com = constants.AnimComRealH; param = 81 },
			{ com = constants.AnimComFaceTarget },
			{ dur = 50; num = 11 },
			{ com = constants.AnimComRealX; param = 84 },
			{ com = constants.AnimComRealH; param = 79 },
			{ dur = 50; num = 12 },
			{ com = constants.AnimComRealX; param = 38 },
			{ com = constants.AnimComRealH; param = 77 },
			{ dur = 50; num = 13 },
			{ com = constants.AnimComRealH; param = 76 },
			{ com = constants.AnimComRealX; param = 36 },
			{ com = constants.AnimComPushInt; param = 50 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ dur = 50; num = 14; com = constants.AnimComCreateEnemyBullet; txt = "pytard-slash" },
			{ com = constants.AnimComRealX; param = 5 },
			{ dur = 50; num = 15 },
			{ com = constants.AnimComRealX; param = 3 },
			{ com = constants.AnimComRealH; param = 80 },
			{ dur = 100; num = 16 },
			{ com = constants.AnimComRealH; param = 81 },
			{ com = constants.AnimComRealX; param = 13 },
			{ dur = 100; num = 17 },
			{ com = constants.AnimComSetAnim; txt = "move" }
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



