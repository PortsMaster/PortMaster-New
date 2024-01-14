--forbidden
name = "turret-snow";

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

texture = "turret_snow";

z = -0.004;

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
			{ com = constants.AnimComRealW; param = 45 },
			{ com = constants.AnimComRealH; param = 12 },
			{ com = constants.AnimComSetHealth; param = 60*difficulty },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 16000 },
			{ com = constants.AnimComSetGravity },
			{ com = constants.AnimComSetBulletCollidable; param = 0 },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{ 
		name = "idle";
		frames = 
		{
			{ dur = 100; num = 0; com = constants.AnimComWaitForTarget; param = 3000; txt = "hidden" },
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
		name = "hidden";
		frames = 
		{
			{ com = constants.AnimComSetBulletCollidable; param = 0 },
			{ com = constants.AnimComRealH; param = 12 },
			{ com = constants.AnimComPushInt; param = 200 },
			{ dur = 100; num = 0; com = constants.AnimComJumpIfTargetClose; param = 5 },
			{ com = constants.AnimComLoop },
			{ dur = constants.AnimComBreakpoint },
			{ com = constants.AnimComPushInt; param = 90 },
			{ com = constants.AnimComJumpCheckFOV; param = 9 },
			{ com = constants.AnimComLoop },
			{ dur = 0 },
			{ com = constants.AnimComSetAnim; txt = "appear" }
		}
	},
	{
		name = "appear";
		frames = 
		{
			{ com = constants.AnimComSetBulletCollidable; param = 1 },
			{ com = constants.AnimComRealH; param = 14 },
			{ dur = 50; num = 1 },
			{ com = constants.AnimComRealH; param = 20 },
			{ dur = 50; num = 2 },
			{ com = constants.AnimComRealH; param = 29 },
			{ dur = 50; num = 3 },
			{ com = constants.AnimComRealH; param = 39 },
			{ dur = 50; num = 4 },
			{ com = constants.AnimComRealH; param = 43 },
			{ dur = 50; num = 5 },
			{ com = constants.AnimComSetAnim; txt = "firstshot" }			
		}
	},
	{
		name = "firstshot";
		frames =
		{
			{ com = constants.AnimComSetBulletCollidable; param = 1 },
			{ com = constants.AnimComRealX; param = 9 },
			{ com = constants.AnimComRealH; param = 43 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ dur = 100; num = 9; com = constants.AnimComAimedShot; txt = "fireshot" },
			{ com = constants.AnimComSetAnim; txt = "active" }
		}
	},
	{ 
		-- Создание
		name = "active";
		frames = 
		{
			{ com = constants.AnimComSetBulletCollidable; param = 1 },
			{ com = constants.AnimComRealH; param = 44 },
			{ dur = 50; num = 6 },
			{ dur = 100; num = 7 },
			{ dur = 100; num = 8 },
			{ dur = 100; num = 7 },
			{ dur = 100; num = 8 },
			{ dur = 100; num = 7 },
			{ com = constants.AnimComPushInt; param = 90 },
			{ com = constants.AnimComJumpCheckFOV; param = 10 },
			{ com = constants.AnimComSetAnim; txt = "hide" },
			{ com = constants.AnimComRealX; param = 9 },
			{ com = constants.AnimComRealH; param = 43 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ dur = 100; num = 9; com = constants.AnimComAimedShot; txt = "fireshot" },
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealH; param = 44 },
			{ com = constants.AnimComPushInt; param = 400 },
			{ dur = 100; num = 0; com = constants.AnimComJumpIfTargetClose; param = 22 },
			{ com = constants.AnimComSetAnim; txt = "hide" },
			{ dur = 0 },
			{ com = constants.AnimComLoop }
		}
	},
	{
		name = "hide";
		frames =
		{
			{ com = constants.AnimComRealH; param = 43 },
			{ dur = 50; num = 5 },
			{ com = constants.AnimComRealH; param = 39 },
			{ dur = 50; num = 4 },
			{ com = constants.AnimComRealH; param = 29 },
			{ dur = 50; num = 3 },
			{ com = constants.AnimComRealH; param = 20 },
			{ dur = 50; num = 2 },
			{ com = constants.AnimComRealH; param = 14 },
			{ dur = 50; num = 1 },
			{ com = constants.AnimComRealH; param = 12 },
			{ com = constants.AnimComSetBulletCollidable; param = 0 },
			{ com = constants.AnimComSetTouchable; param = 0 },
			{ com = constants.AnimComSetAnim; txt = "hidden" }
		}
	},
	{
		-- Создание
		name = "jump";
		frames = 
		{
			{ com = constants.AnimComSetBulletCollidable; param = 1 },
		}
	},
	{
		name = "touch";
		frames = 
		{
			{ com = constants.AnimComJumpIfPlayerId; param = 2 },
			{ com = constants.AnimComRecover },
			{ dur = 0 },
			{ com = constants.AnimComDamage; param = 15*difficulty },
			{ com = constants.AnimComRecover },
		}
	},
	{ 
		-- Создание
		name = "die";
		frames = 
		{
			{ com = constants.AnimComSetTouchable; param = 0 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "explosion-safe" },
			{ com = constants.AnimComMapVarAdd; param = 40; txt = "score" },
			{ com = constants.AnimComSetBulletCollidable; param = 0 },
			{ com = constants.AnimComRealW; param = 45 },
			{ com = constants.AnimComRealH; param = 12 },
			{ dur = 5000; num = 10 },
			{ com = constants.AnimComDestroyObject }	
		}
	},
	{ 
		-- Создание
		name = "land";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "hidden" }
		}
	}
	
}



