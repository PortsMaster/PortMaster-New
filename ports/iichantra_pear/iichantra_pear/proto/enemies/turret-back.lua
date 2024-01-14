--forbidden
name = "turret-back";

physic = 1;
phys_solid = 0;
phys_bullet_collidable = 1;
phys_max_x_vel = 0;
phys_max_y_vel = 0;
phys_jump_vel = 20;
phys_walk_acc = 3;
phys_one_sided = 0;
mp_count = 1;

FunctionName = "CreateEnemy";

-- Описание спрайта

texture = "turret-back";

z = -0.003;

image_width = 256;
image_height = 128;
local speed = 200;

animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 43 },
			{ com = constants.AnimComRealH; param = 43 },
			{ com = constants.AnimComSetHealth; param = 50*difficulty },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComSetGravity },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{ 
		name = "idle";
		frames = 
		{
			{ dur = 100; num = 0; com = constants.AnimComWaitForTarget; param = 320; txt = "active" },
			{ com = constants.AnimComLoop }	
		}
	},
	{ 
		-- Создание
		name = "pain";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 420 },
			{ com = constants.AnimComPushInt; param = 340 },
			{ com = constants.AnimComJumpIfCloseToCamera; param = 3 },
			{ com = constants.AnimComSetAnim; txt="idle" },
			{ com = constants.AnimComPop },
			{ com = constants.AnimComReduceHealth },
			{ com = constants.AnimComSetAnim; txt="active" }
		}
	},
	{
		name = "active";
		frames = 
		{
			{ com = constants.AnimComFaceTarget },
			{ com = constants.AnimComPushInt; param = 620 },
			{ com = constants.AnimComJumpIfTargetClose; param = 5 },
			{ dur = 500; num = 0 },
			{ com = constants.AnimComSetAnim; txt = "idle" },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComPushInt; param = 15 },
			{ com = constants.AnimComPushInt; param = -10 },
			{ com = constants.AnimComRealY; param = 1 },
			{ com = 0 },
			{ com = 0 },
			{ dur = 0; num = 1; com = constants.AnimComAimedShot; txt = "fireshot2" },
			{ com = constants.AnimComPushInt; param = 15 },
			{ com = constants.AnimComPushInt; param = 10 },
			{ dur = 100; num = 1; com = constants.AnimComAimedShot; txt = "fireshot2" },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComPushInt; param = 20 },
			{ com = constants.AnimComJumpRandom; param = 19 },
			{ com = constants.AnimComLoop },
			{ dur = 700; num = 0 },
			{ com = constants.AnimComLoop }
		}
	},
	{ 
		-- Создание
		name = "die";
		frames = 
		{
			{ com = constants.AnimComSetTouchable; param = 0 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "explosion-safe" },
			{ com = constants.AnimComMapVarAdd; param = 80; txt = "score" },
			{ com = constants.AnimComSetBulletCollidable; param = 0 },
			{ dur = 5000; num = 2 },
			{ com = constants.AnimComPushInt; param = 420 },
			{ com = constants.AnimComPushInt; param = 340 },
			{ com = constants.AnimComJumpIfCloseToCamera; param = 3 },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{ 
		-- Создание
		name = "land";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "idle" }
		}
	}
	
}



