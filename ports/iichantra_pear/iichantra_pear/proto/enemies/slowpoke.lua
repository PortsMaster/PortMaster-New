--forbidden
name = "slowpoke";

offscreen_distance = 640
offscreen_behavior = constants.offscreenNone

physic = 1;
phys_solid = 0;
phys_bullet_collidable = 1;
phys_max_x_vel = 5;
phys_max_y_vel = 50;
phys_jump_vel = 20;
phys_walk_acc = 3;
phys_one_sided = 0;
mp_count = 1;
touch_detection = constants.tdtFromTop;

drops_shadow = 1;

faction_id = 1;
faction_hates = { -1, -2 };

gravity_x = 0;
gravity_y = 0.8;

FunctionName = "CreateEnemy";

-- Описание спрайта

texture = "slowpoke";

z = -0.02;

local speed = 150;
if difficulty>=2.0 then speed = 180; end
local close = 150;
local far = 700;
local mc = 64;
local fc = 74;
local prob_shot = 20;
if difficulty>=2.0 then prob_shot = 40; end
local health = 75 + 50 * difficulty

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
			{ com = constants.AnimComSetAnim; txt = "sleep"; }
		}
	},
	{
		name = "idle";
		frames = 
		{
			{ dur = 100; com = constants.AnimComWaitForTarget; param = 30000; txt = "move"; },
			{ com = constants.AnimComLoop; }
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
			{ dur = 100; com = constants.AnimComMoveToTargetX; param = speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "sleep" },
			{ com = constants.AnimComSetAnim; param = 220; txt = "shoot" },
			{ com = constants.AnimComPushInt; param = 150; },
			{ com = constants.AnimComJumpIfTargetClose; param = 41; },
			{ dur = 100; num = 1; com = constants.AnimComMoveToTargetX; param = speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "sleep" },
			{ com = constants.AnimComSetAnim; param = 220; txt = "shoot" },
			{ com = constants.AnimComPushInt; param = 150; },
			{ com = constants.AnimComJumpIfTargetClose; param = 41; },
			{ dur = 100; num = 2; com = constants.AnimComMoveToTargetX; param = speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "sleep" },
			{ com = constants.AnimComSetAnim; param = 220; txt = "shoot" },
			{ com = constants.AnimComPushInt; param = 150; },
			{ com = constants.AnimComJumpIfTargetClose; param = 41; },
			{ dur = 100; num = 3; com = constants.AnimComMoveToTargetX; param = speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "sleep" },
			{ com = constants.AnimComSetAnim; param = 220; txt = "shoot" },
			{ com = constants.AnimComPushInt; param = 150; },
			{ com = constants.AnimComJumpIfTargetClose; param = 41; },
			{ dur = 100; num = 4; com = constants.AnimComMoveToTargetX; param = speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "sleep" },
			{ com = constants.AnimComSetAnim; param = 220; txt = "shoot" },
			{ com = constants.AnimComPushInt; param = 150; },
			{ com = constants.AnimComJumpIfTargetClose; param = 41; },
			{ dur = 100; num = 5; com = constants.AnimComMoveToTargetX; param = speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "sleep" },
			{ com = constants.AnimComSetAnim; param = 220; txt = "shoot" },
			{ com = constants.AnimComPushInt; param = 150; },
			{ com = constants.AnimComJumpIfTargetClose; param = 41; },
			{ dur = 100; num = 6; com = constants.AnimComMoveToTargetX; param = speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "sleep" },
			{ com = constants.AnimComSetAnim; param = 220; txt = "shoot" },
			{ com = constants.AnimComPushInt; param = 150; },
			{ com = constants.AnimComJumpIfTargetClose; param = 41; },
			{ dur = 100; num = 7; com = constants.AnimComMoveToTargetX; param = speed; },
			{ com = constants.AnimComSetAnim; param = 240; txt = "sleep" },
			{ com = constants.AnimComSetAnim; param = 220; txt = "shoot" },
			{ com = constants.AnimComPushInt; param = 150; },
			{ com = constants.AnimComJumpIfTargetClose; param = 41; },
			{ com = constants.AnimComLoop; },
			{ dur = 0 },
			{ com = constants.AnimComSetAnim; txt = "run_away" }
		}
	},
	{
		name = "run_away";
		frames =
		{
			{ dur = 0; },
			{ dur = 50; num = 1; com = constants.AnimComMoveToTargetX; param = math.floor(-1.5*speed); },
			{ com = constants.AnimComPushInt; param = 250; },
			{ com = constants.AnimComJumpIfTargetClose; param = 4; },
			{ com = constants.AnimComSetAnim;  txt = "move" },
			{ dur = 50; num = 2; com = constants.AnimComMoveToTargetX; param = math.floor(-1.5*speed); },
			{ com = constants.AnimComPushInt; param = 250; },
			{ com = constants.AnimComJumpIfTargetClose; param = 8; },
			{ com = constants.AnimComSetAnim;  txt = "move" },
			{ dur = 50; num = 3; com = constants.AnimComMoveToTargetX; param = math.floor(-1.5*speed); },
			{ com = constants.AnimComPushInt; param = 250; },
			{ com = constants.AnimComJumpIfTargetClose; param = 12; },
			{ com = constants.AnimComSetAnim;  txt = "move" },
			{ dur = 50; num = 4; com = constants.AnimComMoveToTargetX; param = math.floor(-1.5*speed); },
			{ com = constants.AnimComPushInt; param = 250; },
			{ com = constants.AnimComJumpIfTargetClose; param = 16; },
			{ com = constants.AnimComSetAnim;  txt = "move" },
			{ dur = 50; num = 5; com = constants.AnimComMoveToTargetX; param = math.floor(-1.5*speed); },
			{ com = constants.AnimComPushInt; param = 250; },
			{ com = constants.AnimComJumpIfTargetClose; param = 20; },
			{ com = constants.AnimComSetAnim;  txt = "move" },
			{ dur = 50; num = 6; com = constants.AnimComMoveToTargetX; param = math.floor(-1.5*speed); },
			{ com = constants.AnimComPushInt; param = 250; },
			{ com = constants.AnimComJumpIfTargetClose; param = 24; },
			{ com = constants.AnimComSetAnim;  txt = "move" },
			{ dur = 50; num = 7; com = constants.AnimComMoveToTargetX; param = math.floor(-1.5*speed); },
			{ com = constants.AnimComPushInt; param = 250; },
			{ com = constants.AnimComJumpIfTargetClose; param = 0; },
			{ com = constants.AnimComSetAnim;  txt = "move" }
		}
	},
	{
		name = "shoot";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 640; },
			{ com = constants.AnimComJumpIfTargetClose; param = 3; },
			{ com = constants.AnimComSetAnim; txt = "move" },
			{ dur = 0 },
			{ com = constants.AnimComPushInt; param = 128; },
			{ com = constants.AnimComJumpRandom; param = 21; },
			{ dur = 100; num = 8; com = constants.AnimComRealH; param = 46; },
			{ com = constants.AnimComRealH; param = 51; },
			{ dur = 100; num = 9; com = constants.AnimComFaceTarget; },
			{ dur = 100; num = 10; com = constants.AnimComRealH; param = 72; },
			{ dur = 100; num = 11; com = constants.AnimComRealH; param = 71; },
			{ dur = 100; num = 12; com = constants.AnimComRealH; param = 70; },
			{ com = constants.AnimComRealH; param = 70; },
			{ com = constants.AnimComAdjustAim; },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComPushInt; param = -10; },
			{ dur = 100; num = 13; com = constants.AnimComAimedShot; txt = "slowpoke-projectile"; },
			{ dur = 100; num = 14; com = constants.AnimComRealH; param = 62; },
			{ dur = 100; num = 15; com = constants.AnimComRealH; param = 51; },
			{ com = constants.AnimComRealH; param = 46; },
			{ com = constants.AnimComSetAnim; txt = "reinit"; },
			{ dur = 0 },
			{ dur = 100; num = 8; com = constants.AnimComRealH; param = 46; },
			{ com = constants.AnimComRealH; param = 51; },
			{ dur = 100; num = 9; com = constants.AnimComFaceTarget; },
			{ dur = 100; num = 10; com = constants.AnimComRealH; param = 72; },
			{ dur = 100; num = 11; com = constants.AnimComRealH; param = 71; },
			{ dur = 100; num = 12; com = constants.AnimComRealH; param = 70; },
			{ com = constants.AnimComRealH; param = 70; },
			{ com = constants.AnimComAdjustAim; },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComPushInt; param = -10; },
			{ dur = 100; num = 13; com = constants.AnimComAimedShot; txt = "slowpoke-projectile"; },
			{ dur = 100; num = 11; com = constants.AnimComRealH; param = 71; },
			{ dur = 100; num = 12; com = constants.AnimComRealH; param = 70; },
			{ com = constants.AnimComRealH; param = 70; },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComPushInt; param = -10; },
			{ dur = 100; num = 13; com = constants.AnimComAimedShot; txt = "slowpoke-projectile"; },
			{ dur = 100; num = 11; com = constants.AnimComRealH; param = 71; },
			{ dur = 100; num = 12; com = constants.AnimComRealH; param = 70; },
			{ com = constants.AnimComRealH; param = 70; },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComPushInt; param = -10; },
			{ dur = 100; num = 13; com = constants.AnimComAimedShot; txt = "slowpoke-projectile"; },
			{ dur = 100; num = 14; com = constants.AnimComRealH; param = 62; },
			{ dur = 100; num = 15; com = constants.AnimComRealH; param = 51; },
			{ com = constants.AnimComRealH; param = 46; },
			{ com = constants.AnimComSetAnim; txt = "sleep"; }

		}
	},
	{
		name = "jump";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "reinit"; }
		}
	},
	{
		name = "touch";
		frames = 
		{
			{ com = constants.AnimComBounceObject; param = 2000; },
			{ com = constants.AnimComStartDying; },
			{ com = constants.AnimComSetAnim; txt = "die"; }
		}
	},
	{
		name = "die";
		frames = 
		{
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
			{ dur = 1; num = 23; com = constants.AnimComJumpIfCloseToCamera; param = 23 },
			{ com = constants.AnimComDestroyObject; }
		}
	},
	{
		name = "land";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "reinit"; }
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
			{ com = constants.AnimComSetAnim; txt = "idle"; }
		}
	},
	{
		name = "sleep";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 10; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 86; },
			{ dur = 100; num = 48; com = constants.AnimComRealH; param = 41; },
			{ com = constants.AnimComRealX; param = 15; },
			{ dur = 100; num = 49; com = constants.AnimComRealH; param = 37; },
			{ dur = 100; num = 50; com = constants.AnimComRealH; param = 34; },
			{ dur = 300; num = 51; com = constants.AnimComRealH; param = 29; },
			{ dur = 300; num = 52; },
			{ dur = 300; num = 53; },
			{ dur = 900; num = 54; },
			{ dur = 300; num = 53; },
			{ dur = 300; num = 52; },
			{ dur = 900; num = 51; },
			{ com = constants.AnimComReduceHealth; param = -10 },
			{ dur = 300; num = 52; com = constants.AnimComWaitForTarget; param = 300; txt = "wake"; },
			{ dur = 300; num = 53; com = constants.AnimComWaitForTarget; param = 300; txt = "wake"; },
			{ dur = 900; num = 54; com = constants.AnimComWaitForTarget; param = 300; txt = "wake"; },
			{ dur = 300; num = 53; com = constants.AnimComWaitForTarget; param = 300; txt = "wake"; },
			{ dur = 300; num = 52; com = constants.AnimComWaitForTarget; param = 300; txt = "wake"; },
			{ dur = 900; num = 51; com = constants.AnimComWaitForTarget; param = 300; txt = "wake"; },
			{ com = constants.AnimComJump; param = 9; }
		}
	},
	{
		name = "wake";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 15; },
			{ dur = 100; num = 51; com = constants.AnimComRealH; param = 29; },
			{ dur = 100; num = 50; com = constants.AnimComRealH; param = 34; },
			{ dur = 100; num = 49; com = constants.AnimComRealH; param = 37; },
			{ com = constants.AnimComRealX; param = 10; },
			{ num = 48; com = constants.AnimComRealH; param = 41; },
			{ com = constants.AnimComSetAnim; txt = "reinit"; }
		}
	}
}

