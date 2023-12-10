--forbidden
name = "turret-wall";

FunctionName = "CreateEnemy";

-- Описание спрайта

texture = "turret-wall";

z = -0.00001;
physic = 1;
phys_ghostlike = 1;

animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComMirror },
			{ com = constants.AnimComRealW; param = 36 },
			{ com = constants.AnimComRealH; param = 32 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComSetGravity },
			{ com = constants.AnimComSetBulletCollidable; param = 0 },
			{ com = constants.AnimComSetAnim; txt = "wait" }	
		}
	},
	{ 
		name = "wait";
		frames = 
		{
			{ dur = 100; num = 0; com = constants.AnimComWaitForTarget; param = 3000; txt = "idle" },
			{ com = constants.AnimComLoop }	
		}
	},
	{ 
		-- Создание
		name = "pain";
		frames = 
		{
			{ com = constants.AnimComPop },
			{ com = constants.AnimComReduceHealth },
			{ com = constants.AnimComSetAnim; txt="active" }
		}
	},
	{ 
		-- Создание
		name = "idle";
		frames = 
		{
			{ dur = 100; num = 0 },
			{ dur = 100; num = 1 },
			{ dur = 100; num = 0 },
			{ dur = 100; num = 2 },
			{ dur = 100; num = 0 },
			{ dur = 100; num = 1 },
			{ dur = 100; num = 0 },
			{ dur = 100; num = 2 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 0 },
			{ dur = 100; num = 1 },
			{ dur = 100; num = 0 },
			{ dur = 100; num = 2 },
			{ com = constants.AnimComSetAnim; txt = "fire" }
		}
	},
	{
		name = "fire";
		frames =
		{
			{ com = constants.AnimComPushInt; param = 320 },
			{ com = constants.AnimComPushInt; param = 240 },
			{ com = constants.AnimComJumpIfCloseToCamera; param = 3 },
			{ com = constants.AnimComSetAnim; txt = "reload" },
			{ dur = 100; num = 4 },
			{ com = constants.AnimComPushInt; param = 30 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ dur = 100; num = 5; com = constants.AnimComAimedShot; txt = "turret-wall-shot" },
			{ dur = 100; num = 6 },
			{ dur = 100; num = 4 },
			{ com = constants.AnimComPushInt; param = 30 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ dur = 100; num = 5; com = constants.AnimComAimedShot; txt = "turret-wall-shot" },
			{ dur = 100; num = 6 },
			{ dur = 100; num = 4 },
			{ com = constants.AnimComPushInt; param = 30 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ dur = 100; num = 5; com = constants.AnimComAimedShot; txt = "turret-wall-shot" },
			{ com = constants.AnimComSetAnim; txt = "reload" }
		}
	},
	{ 
		-- Создание
		name = "reload";
		frames = 
		{
			{ dur = 50; num = 6 },
			{ dur = 100; num = 7 },
			{ dur = 100; num = 8 },
			{ dur = 100; num = 9 },
			{ com = constants.AnimComPushInt; param = 200 },
			{ com = constants.AnimComJumpRandom; param = 7 },
			{ com = constants.AnimComLoop },
			{ dur = 0 },
			{ com = constants.AnimComSetAnim; txt = "idle" }
		}
	},
	{ 
		-- Создание
		name = "die";
		frames = 
		{
			{ com = constants.AnimComDestroyObject }	
		}
	},
		{ 
		-- Создание
		name = "pain";
		frames = 
		{
			{ com = constants.AnimComDestroyObject }	
		}
	}

}



