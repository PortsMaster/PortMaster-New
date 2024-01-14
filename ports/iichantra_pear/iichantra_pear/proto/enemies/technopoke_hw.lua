parent = "enemies/slowpoke_hw"


overlay = {0};
ocolor = {{1, 1, 1, 1}};

local speed = 150


animations =
{
	{
		name = "shoot";
		frames = 
		{
			{ com = constants.AnimComAdjustAim; },
			{ com = constants.CnimComFaceTarget; },
			{ dur = 1; num = 8 },
			{ com = constants.AnimComPushInt; param = 70 },
			{ com = constants.AnimComJumpRandom; param = 8 },
			{ com = constants.AnimComPushInt; param = 10 },
			{ com = constants.AnimComPushInt; param = 0; },
			{ dur = 900; num = 8; com = constants.AnimComCreateEffect; txt = "technopoke-boomerang-effect"; param = 5 },
			{ com = constants.AnimComSetAnim; txt = "move"; },
			{ com = constants.AnimComPushInt; param = 10 },
			{ com = constants.AnimComPushInt; param = 0; },
			{ dur = 100; num = 8; com = constants.AnimComAimedShot; txt = "technopoke-sine" },
			{ com = constants.AnimComPushInt; param = 10 },
			{ com = constants.AnimComPushInt; param = 0; },
			{ dur = 100; num = 8; com = constants.AnimComAimedShot; txt = "technopoke-sine" },
			{ com = constants.AnimComPushInt; param = 10 },
			{ com = constants.AnimComPushInt; param = 0; },
			{ dur = 100; num = 8; com = constants.AnimComAimedShot; txt = "technopoke-sine" },
			{ com = constants.AnimComSetAnim; txt = "move"; },
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
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "explosion" },
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
			{ dur = 1; num = 23; com = constants.AnimComJumpIfCloseToCamera; param = 27 },
			{ com = constants.AnimComDestroyObject; }
		}
	},
	{
		name = "pain";
		frames = 
		{
			{ com = constants.AnimComPop; },
			{ com = constants.AnimComReduceHealth; },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComCreateParticles; param = 2; txt = "pblood-wound"; },
			{ com = constants.AnimComSetAnim; txt = "reinit"; }
		}
	},
	{
		name = "move";
		frames =
		{
			{ com = constants.AnimComSetAnim; param = 128; txt = "move_to" },
			{ com = constants.AnimComSetAnim; param = 0; txt = "move_away" }
		}
	},
	{
		name = "move_to";
		frames = 
		{
			{ dur = 100; com = constants.AnimComMoveToTargetX; param = speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "shoot" },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetX; param = speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "shoot" },
			{ dur = 100; num = 2; com = constants.AnimComMoveToTargetX; param = speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "shoot" },
			{ dur = 100; num = 3; com = constants.AnimComMoveToTargetX; param = speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "shoot" },
			{ dur = 100; num = 4; com = constants.AnimComMoveToTargetX; param = speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "shoot" },
			{ dur = 100; num = 5; com = constants.AnimComMoveToTargetX; param = speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "shoot" },
			{ dur = 100; num = 6; com = constants.AnimComMoveToTargetX; param = speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "shoot" },
			{ dur = 100; num = 7; com = constants.AnimComMoveToTargetX; param = speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "shoot" },
			{ dur = 100; num = 8; com = constants.AnimComMoveToTargetX; param = speed; },		
			{ com = constants.AnimComSetAnim; txt = "move" }
		}
	},
	{
		name = "move_away";
		frames = 
		{
			{ dur = 100; com = constants.AnimComMoveToTargetX; param = speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "shoot" },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetX; param = -speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "shoot" },
			{ dur = 100; num = 2; com = constants.AnimComMoveToTargetX; param = -speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "shoot" },
			{ dur = 100; num = 3; com = constants.AnimComMoveToTargetX; param = -speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "shoot" },
			{ dur = 100; num = 4; com = constants.AnimComMoveToTargetX; param = -speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "shoot" },
			{ dur = 100; num = 5; com = constants.AnimComMoveToTargetX; param = -speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "shoot" },
			{ dur = 100; num = 6; com = constants.AnimComMoveToTargetX; param = -speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "shoot" },
			{ dur = 100; num = 7; com = constants.AnimComMoveToTargetX; param = -speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "shoot" },
			{ dur = 100; num = 8; com = constants.AnimComMoveToTargetX; param = -speed; },		
			{ com = constants.AnimComSetAnim; txt = "move" }
		}
	}

}