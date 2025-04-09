--forbidden
health = 100;

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

texture = "btard";

z = -0.1;

image_width = 1024;
image_height = 2048;
frame_width = 256;
frame_height = 128;
frames_count = 28;

overlay = {0};
ocolor = {{1, 0.8, 1, 1}}
local diff = (difficulty-1)/5+1;
local difcom = constants.AnimComNone;
if (difficulty >=1) then difcom = constants.AnimComJump; end

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
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComControlledOverlayColor },
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
			{ com = constants.AnimComRealW; param = 36 },
			{ com = constants.AnimComRealH; param = 75 },
			{ dur = 1; num = 0 },
			{ dur = 100; num = 0; com = constants.AnimComWaitForTarget; param = 3000; txt = "move" },
			{ dur = 100; num = 1; com = constants.AnimComWaitForTarget; param = 3000; txt = "move" },
			{ dur = 100; num = 2; com = constants.AnimComWaitForTarget; param = 3000; txt = "move" },
			{ dur = 100; num = 3; com = constants.AnimComWaitForTarget; param = 3000; txt = "move" },
			{ dur = 100; num = 4; com = constants.AnimComWaitForTarget; param = 3000; txt = "move" },
			--{ dur = 100; num = 4 },
			--{ dur = 100; num = 5 },
			{ com = constants.AnimComLoop }	
		}
	},
	{
		name = "sfg9000";
		frames =
		{
			{ com = constants.AnimComPop },
			{ num = 3; dur = 1000 },
			{ com = constants.AnimComSetAnim; txt = "think" }	
		}
	},
	{ 
		-- Создание
		name = "pain";
		frames = 
		{
			{ com = constants.AnimComPlaySound; txt = "ouch2.ogg" },
			--{ com = constants.AnimComJumpIfIntEquals; param = 2; txt = "sfg9000" },
			{ com = constants.AnimComPop },
			{ com = constants.AnimComReduceHealth },
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
			--{ com = constants.AnimComEnemyClean; param = 100 },
			{ dur = 0 },
			{ com = constants.AnimComRealX; param = 11 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 36 },
			{ com = constants.AnimComRealH; param = 75 },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComJumpIfTargetClose; param = 36 },
			{ com = constants.AnimComEnvSound; param = 1},
			{ dur = 100; num = 5; com = constants.AnimComMoveToTargetX; param = 500/diff },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComJumpIfTargetClose; param = 36 },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 6; com = constants.AnimComMoveToTargetX; param = 500/diff },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComJumpIfTargetClose; param = 36 },
			{ com = constants.AnimComRealX; param = 6 },
			{ dur = 100; num = 7; com = constants.AnimComMoveToTargetX; param = 500/diff },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComJumpIfTargetClose; param = 36 },
			{ com = constants.AnimComRealX; param = 18 },
			{ com = constants.AnimComEnvSound; },
			{ dur = 100; num = 8; com = constants.AnimComMoveToTargetX; param = 500/diff },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComJumpIfTargetClose; param = 36 },
			{ com = constants.AnimComRealX; param = 12 },
			{ dur = 100; num = 9; com = constants.AnimComMoveToTargetX; param = 500/diff },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComJumpIfTargetClose; param = 36 },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 10; com = constants.AnimComMoveToTargetX; param = 500/diff },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComJumpIfTargetClose; param = 36 },
			--С некоторой вероятностью битард "задумывается"
			{ com = constants.AnimComPushInt; param = 200*diff },
			{ com = constants.AnimComJumpRandom; param = 19 },
			{ com = constants.AnimComSetAnim; txt = "think" },
			{ com = constants.AnimComLoop },
			{ dur = 0 },
			{ com = constants.AnimComSetAnim; txt = "attack" }	
		}
	},
	{
		name = "think";
		frames = 
		{
			{ dur = 0 },
			--{ com = constants.AnimComEnemyClean; param = 20 },
			{ dur = 0 }, 
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
			{ com = constants.AnimComSetAnim; txt = "move" },
			{ com = constants.AnimComLoop },
			{ dur = 0 },
			{ com = constants.AnimComPushInt; param = 640 },
			{ com = constants.AnimComJumpIfTargetClose; param = 18 },
			{ com = constants.AnimComSetAnim; txt = "move" },
			{ dur = 0 },
			{ com = constants.AnimComSetAnim; txt = "move" }
		}
	},
	{ 
		-- Создание
		name = "jump";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 36 },
			{ com = constants.AnimComRealH; param = 75 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{ 
		-- Создание
		name = "die";
		frames = 
		{
			{ com = constants.AnimComSetBulletCollidable; param = 0 },
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 36 },
			{ com = constants.AnimComRealH; param = 78 },
			{ com = constants.AnimComMapVarAdd; param = difficulty*10; txt = "score" },
			{ com = constants.AnimComMapVarAdd; param = 1; txt = "kills" },
			{ com = constants.AnimComPushInt; param = 50 },
			{ com = constants.AnimComJumpRandom; param = 11 },
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
			{ com = constants.AnimComJumpIfCloseToCamera; param = 39 }
		}
	},
	{
		name = "attack";
		frames =
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 34 },
			{ com = constants.AnimComRealH; param = 81 },
			{ com = constants.AnimComFaceTarget },
			{ dur = 50; num = 11 },
			{ com = constants.AnimComRealW; param = 68 },
			{ com = constants.AnimComRealH; param = 78 },
			{ dur = 50; num = 12 },
			{ com = constants.AnimComRealH; param = 77 },
			{ dur = 50; num = 13 },
			{ com = constants.AnimComRealH; param = 69 },
			{ com = constants.AnimComPushInt; param = 50 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ dur = 150; num = 14; com = constants.AnimComCreateEnemyBullet; txt = "btard-punch" },
			{ com = constants.AnimComRealH; param = 68 },
			{ dur = 150; num = 15 },
			{ com = constants.AnimComRealH; param = 78 },
			{ dur = 400; num = 16 }, --Долго отходим
			{ com = constants.AnimComSetAnim; txt = "move" }
		}
	},
	{ 
		-- Создание
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
			{ com = constants.AnimComSetAnim; txt = "idle" }
		}
	},
	{
		name = "target_dead";
		frames =
		{
			{ com = constants.AnimComSetAnim; txt = "idle" }
		}
	},
	{ 
		-- Создание
		name = "follow";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 11 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 36 },
			{ com = constants.AnimComRealH; param = 75 },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComJumpIfTargetClose; param = 38 },
			{ com = constants.AnimComEnvSound; param = 1},
			{ dur = 100; num = 5; com = constants.AnimComMoveToTargetX; param = 250 },
			{ dur = 0; com = constants.AnimComWaitForEnemy; param = 3000; txt = "move" },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComJumpIfTargetClose; param = 38 },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 6; com = constants.AnimComMoveToTargetX; param = 250 },
			{ dur = 0; com = constants.AnimComWaitForEnemy; param = 3000; txt = "move" },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComJumpIfTargetClose; param = 38 },
			{ com = constants.AnimComRealX; param = 6 },
			{ dur = 100; num = 7; com = constants.AnimComMoveToTargetX; param = 250 },
			{ dur = 0; com = constants.AnimComWaitForEnemy; param = 3000; txt = "move" },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComJumpIfTargetClose; param = 38 },
			{ com = constants.AnimComRealX; param = 18 },
			{ com = constants.AnimComEnvSound; },
			{ dur = 100; num = 8; com = constants.AnimComMoveToTargetX; param = 250 },
			{ dur = 0; com = constants.AnimComWaitForEnemy; param = 3000; txt = "move" },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComJumpIfTargetClose; param = 38 },
			{ com = constants.AnimComRealX; param = 12 },
			{ dur = 100; num = 9; com = constants.AnimComMoveToTargetX; param = 250 },
			{ dur = 0; com = constants.AnimComWaitForEnemy; param = 3000; txt = "move" },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComJumpIfTargetClose; param = 38 },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 10; com = constants.AnimComMoveToTargetX; param = 250 },
			{ dur = 0; com = constants.AnimComWaitForEnemy; param = 3000; txt = "move" },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComJumpIfTargetClose; param = 38 },
			{ com = constants.AnimComLoop },
			{ dur = 100; num = 0; com = constants.AnimComWaitForEnemy; param = 3000; txt = "move" },
			{ dur = 100; num = 1; com = constants.AnimComWaitForEnemy; param = 3000; txt = "move"; },
			{ dur = 100; num = 2; com = constants.AnimComWaitForEnemy; param = 3000; txt = "move" },
			{ dur = 100; num = 3; com = constants.AnimComWaitForEnemy; param = 3000; txt = "move"},
			{ dur = 100; num = 4; com = constants.AnimComWaitForEnemy; param = 3000; txt = "move"},
			{ com = constants.AnimComLoop },
		}
	},

}



