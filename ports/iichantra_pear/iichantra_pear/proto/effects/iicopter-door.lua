--forbidden
texture = "iicopter";

z = -0.09;
phys_ghostlike = 1;
physic = 1;
phys_bullet_collidable = 1;
phys_max_x_vel = 9000;
offscreen_distance = 640
offscreen_behavior = constants.offscreenNone

effect = 1;

overlay = {0};

animations = 
{
	{
		name = "idle";
		frames =
		{
			{ com = constants.AnimComRealW; param = 57 },
			{ com = constants.AnimComRealH; param = 96 },
			{ com = constants.AnimComSetHealth; param = 150 },
			{ dur = 1; num = 1 },
			{ com = constants.AnimComCallFunction; txt = "iicopter_doors" },
			{ com = constants.AnimComSetAnim; txt = "drop" }
		}
	},
	{
		name = "inactive";
		frames =
		{
			{ dur = 1; num = 1 }
		}
	},
	{
		name = "drop";
		frames =
		{
			{ com = constants.AnimComJumpIfStackIsNotEmpty; param = 2 },
			{ com = constants.AnimComJump; param = 23 },
			{ dur = 8000; num = 1 },
			{ com = constants.AnimComSetRelativeVelX; param = 1200 },
			{ com = constants.AnimComSetVelY; param = 150 },
			{ dur = 400; num = 1 },
			{ com = constants.AnimComSetRelativeVelX; param = 0 },
			{ com = constants.AnimComSetVelY; param = 0 },
			{},
			{ com = constants.AnimComPushInt; param = -40 },
			{ com = constants.AnimComPushInt; param = 40 },
			{ num = 1; dur = 100; com = constants.AnimComSummonObject; param = 3 },
			{ com = constants.AnimComPop },
			{ com = constants.AnimComJumpIfStackIsNotEmpty; param = 8 },
			{ com = constants.AnimComSetRelativeVelX; param = -1200 },
			{ com = constants.AnimComSetVelY; param = -150 },
			{ dur = 400; num = 1 },
			{ com = constants.AnimComSetRelativeVelX; param = 0 },
			{ com = constants.AnimComSetVelY; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComSetRelativePos },
			{ dur = 16000; num = 1 },
			{},
			{ com = constants.AnimComSetAnim; txt = "default_drop" }
		}

	},
	{ 
		name = "default_drop";
		frames = 
		{
			{ dur = 8000; num = 1 },
			{ com = constants.AnimComSetRelativeVelX; param = 1200 },
			{ com = constants.AnimComSetVelY; param = 150 },
			{ dur = 400; num = 1 },
			{ com = constants.AnimComSetRelativeVelX; param = 0 },
			{ com = constants.AnimComSetVelY; param = 0 },
			{ com = constants.AnimComPushInt; param = -40 },
			{ com = constants.AnimComPushInt; param = 40 },
			{ num = 1; dur = 100; com = constants.AnimComCreateEnemy; txt = "btard-com"; param = 3 },
			{ com = constants.AnimComPushInt; param = -40 },
			{ com = constants.AnimComPushInt; param = 40 },
			{ num = 1; dur = 100; com = constants.AnimComCreateEnemy; txt = "btard-com"; param = 3 },
			{ com = constants.AnimComPushInt; param = -40 },
			{ com = constants.AnimComPushInt; param = 40 },
			{ num = 1; dur = 100; com = constants.AnimComCreateEnemy; txt = "btard-com"; param = 3 },
			{ dur = 4000; num = 1 },
			{ com = constants.AnimComPushInt; param = -40 },
			{ com = constants.AnimComPushInt; param = 40 },
			{ num = 1; dur = 100; com = constants.AnimComCreateEnemy; txt = "btard-com"; param = 3 },
			{ com = constants.AnimComPushInt; param = -40 },
			{ com = constants.AnimComPushInt; param = 40 },
			{ num = 1; dur = 100; com = constants.AnimComCreateEnemy; txt = "btard-com"; param = 3 },
			{ com = constants.AnimComSetRelativeVelX; param = -1200 },
			{ com = constants.AnimComSetVelY; param = -150 },
			{ dur = 400; num = 1 },
			{ com = constants.AnimComSetRelativeVelX; param = 0 },
			{ com = constants.AnimComSetVelY; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComSetRelativePos },
			{ dur = 16000; num = 1 },
			{ com = constants.AnimComSetAnim; txt = "drop" }
		}
	},
	{
		name = "wounded";
		frames = 
		{
			{ dur = 8000; num = 8 },
			{ com = constants.AnimComSetRelativeVelX; param = 1200 },
			{ com = constants.AnimComSetVelY; param = 150 },
			{ dur = 400; num = 8 },
			{ com = constants.AnimComSetRelativeVelX; param = 0 },
			{ com = constants.AnimComSetVelY; param = 0 },
			{ com = constants.AnimComPushInt; param = -40 },
			{ com = constants.AnimComPushInt; param = 40 },
			{ num = 8; dur = 100; com = constants.AnimComCreateEnemy; txt = "btard-com"; param = 3 },
			{ com = constants.AnimComPushInt; param = -40 },
			{ com = constants.AnimComPushInt; param = 40 },
			{ num = 8; dur = 100; com = constants.AnimComCreateEnemy; txt = "btard-com"; param = 3 },
			{ com = constants.AnimComPushInt; param = -40 },
			{ com = constants.AnimComPushInt; param = 40 },
			{ num = 8; dur = 100; com = constants.AnimComCreateEnemy; txt = "btard-com"; param = 3 },
			{ com = constants.AnimComPushInt; param = -40 },
			{ com = constants.AnimComPushInt; param = 40 },
			{ num = 8; dur = 100; com = constants.AnimComCreateEnemy; txt = "btard-com"; param = 3 },
			{ com = constants.AnimComPushInt; param = -40 },
			{ com = constants.AnimComPushInt; param = 40 },
			{ num = 8; dur = 100; com = constants.AnimComCreateEnemy; txt = "btard-com"; param = 3 },
			{ dur = 4000; num = 1 },
			{ com = constants.AnimComPushInt; param = -40 },
			{ com = constants.AnimComPushInt; param = 40 },
			{ num = 8; dur = 100; com = constants.AnimComCreateEnemy; txt = "btard-com"; param = 3 },
			{ com = constants.AnimComPushInt; param = -40 },
			{ com = constants.AnimComPushInt; param = 40 },
			{ num = 8; dur = 100; com = constants.AnimComCreateEnemy; txt = "btard-com"; param = 3 },
			{ com = constants.AnimComPushInt; param = -40 },
			{ com = constants.AnimComPushInt; param = 40 },
			{ num = 8; dur = 100; com = constants.AnimComCreateEnemy; txt = "btard-com"; param = 3 },
			{ com = constants.AnimComPushInt; param = -40 },
			{ com = constants.AnimComPushInt; param = 40 },
			{ num = 8; dur = 100; com = constants.AnimComCreateEnemy; txt = "btard-com"; param = 3 },
			{ com = constants.AnimComPushInt; param = -40 },
			{ com = constants.AnimComPushInt; param = 40 },
			{ num = 8; dur = 100; com = constants.AnimComCreateEnemy; txt = "btard-com"; param = 3 },
			{ com = constants.AnimComSetRelativeVelX; param = -1200 },
			{ com = constants.AnimComSetVelY; param = -150 },
			{ dur = 400; num = 8 },
			{ com = constants.AnimComSetRelativeVelX; param = 0 },
			{ com = constants.AnimComSetVelY; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComSetRelativePos },
			{ dur = 16000; num = 8 },
			{ com = constants.AnimComLoop }	
		}
	},
	{
		name = "reanimate";
		frames =
		{
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComSetRelativePos },
			{ com = constants.AnimComSetHealth; param = 50 },
			{ com = constants.AnimComPushInt; param = 28 },
			{ com = constants.AnimComSetAnim; txt = "wounded" },
		}
	},
	{
		name = "die";
		frames =
		{
			{ com = constants.AnimComStop },
			{ com = constants.AnimComPushInt; param = 3 },
			{ com = constants.AnimComLocalJumpIfIntEquals; param = 28 },
			{ com = constants.AnimComSetAnim; txt = "reanimate" },
			{ com = constants.AnimComCallFunction; txt = "iicopter_part_destroyed" },
			{ com = constants.AnimComMapVarAdd; param = 500; txt = "score" },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComSetRelativePos },
			{ com = constants.AnimComSetBulletCollidable; param = 0 },
			{ num = 7; dur = 100 }
		}
	}
}
