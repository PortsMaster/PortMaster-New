health = 120 / difficulty;

local diff = (difficulty-1)/5+1;

physic = 1;
phys_solid = 0;
phys_bullet_collidable = 1;
phys_max_x_vel = 2.25; 
phys_max_y_vel = 50;
phys_jump_vel = 10;
phys_walk_acc = 2.25;
gravity_x = 0;
gravity_y = 0.3;

drops_shadow = 1;

mp_count = 2;

faction_id = -1;

texture = "soh-unarmed";
z = -0.001;

animations =
{
	{
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 74; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComPushInt; param = -50; },
			{ com = constants.AnimComMPSet; param = 1; },
			{ dur = 100; },
			{ dur = 100; num = 1; },
			{ dur = 100; num = 2; },
			{ dur = 100; num = 3; },
			{ com = constants.AnimComLoop; }
		}
	},
	{
		name = "walk";
		frames = 
		{
			{ com = constants.AnimComRealX; param = -5; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 72; },
			{ com = constants.AnimComShootBeh; param = 1; },
			{ com = constants.AnimComPushInt; param = 2; },
			{ com = constants.AnimComJumpIfXSpeedGreater; param = 28; },
			{ com = constants.AnimComPushInt; param = -32; },
			{ com = constants.AnimComPushInt; param = -58; },
			{ com = constants.AnimComPushInt; param = 1; },
			{ com = constants.AnimComEnvSprite; },
			{ com = constants.AnimComPushInt; param = 38; },
			{ com = constants.AnimComPushInt; param = -1; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComEnvSound; },
			{ dur = 100; num = 7; },
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComPushInt; param = 39; },
			{ com = constants.AnimComPushInt; param = -3; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 8; },
			{ com = constants.AnimComRealX; param = 5; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComPushInt; param = 41; },
			{ com = constants.AnimComPushInt; param = -4; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 9; },
			{ dur = 0 },
			{ com = constants.AnimComRealX; param = 7; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComPushInt; param = 42; },
			{ com = constants.AnimComPushInt; param = -4; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 10; },
			{ com = constants.AnimComPushInt; param = 43; },
			{ com = constants.AnimComPushInt; param = -2; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; param = 2; },
			{ com = constants.AnimComRealY; },
			{ dur = 100; num = 11; },
			{ com = constants.AnimComRealX; param = -5; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComPushInt; param = 42; },
			{ com = constants.AnimComPushInt; param = -1; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComEnvSound; param = 1; },
			{ dur = 100; num = 12; },
			{ com = constants.AnimComPushInt; param = 40; },
			{ com = constants.AnimComPushInt; param = -1; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ dur = 100; num = 14; },
			{ com = constants.AnimComPushInt; param = 37; },
			{ com = constants.AnimComPushInt; param = -3; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; param = 5; },
			{ com = constants.AnimComRealY; },
			{ dur = 100; num = 13; },
			{ com = constants.AnimComShootX; param = 36; },
			{ com = constants.AnimComPushInt; param = 40; },
			{ com = constants.AnimComPushInt; param = -3; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; param = 9; },
			{ com = constants.AnimComRealY; },
			{ dur = 100; num = 5; },
			{ com = constants.AnimComPushInt; param = 36; },
			{ com = constants.AnimComPushInt; param = -2; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; param = 3; },
			{ com = constants.AnimComRealY; },
			{ dur = 100; num = 6; },
			{ com = constants.AnimComRealX; param = -5; },
			{ com = constants.AnimComJump; param = 10; }
		}
	},
	{
		name = "jump";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 3; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ num = 28; com = constants.AnimComPushInt; param = -1; },
			{ com = constants.AnimComJumpIfYSpeedGreater; param = 10; },
			{ dur = 100; num = 29; com = constants.AnimComRealH; param = 81; },
			{ dur = 100; num = 30; com = constants.AnimComRealH; param = 73; },
			{ dur = 100; num = 31; com = constants.AnimComRealH; param = 65; },
			{ com = constants.AnimComJumpIfYSpeedGreater; param = 10; },
			{ com = constants.AnimComJump; param = 7; },
			{ dur = 0 },
			{ com = constants.AnimComSetAnim; txt = "fly"; },
			{ com = constants.AnimComRealX; param = 6; },
			{ dur = 100; num = 32; com = constants.AnimComRealH; param = 73; },
			{ dur = 100; num = 33; com = constants.AnimComRealH; param = 81; },
			{ com = constants.AnimComSetAnim; txt = "jump"; }
		}
	},
	{
		name = "fly";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealX; param = 6; },
			{ com = constants.AnimComRealY; },
			{ dur = 100; num = 31; com = constants.AnimComRealH; param = 73; },
			{ com = constants.AnimComRealX; param = 12; },
			{ dur = 100; num = 32; com = constants.AnimComRealH; param = 81; },
			{ dur = 100; num = 33; com = constants.AnimComRealH; param = 81; }
		}
	},
	{
		name = "sit";
		frames = 
		{
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; param = -2; },
			{ com = constants.AnimComRealW; param = 30; },
			{ com = constants.AnimComPushInt; param = 42; },
			{ com = constants.AnimComPushInt; param = -4; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 27; com = constants.AnimComRealH; param = 59; }
		}
	},
	{
		name = "sitaimup";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "sit"; }
		}
	},
	{
		name = "sitaimdown";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "sit"; }
		}
	},
	{
		name = "land";
		frames = 
		{
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComEnvSound; },
			{ com = constants.AnimComEnvSound; param = 1; },
			{ com = constants.AnimComPushInt; param = -128; },
			{ com = constants.AnimComPushInt; param = -58; },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComEnvSprite; param = 1; },
			{ com = constants.AnimComRealH; param = 57; },
			{ dur = 100; num = 27; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 73; },
			{ dur = 100; num = 28; com = constants.AnimComRealX; param = 1; },
			{ param = 1; txt = "gunaimup"; },
			{ param = -1; txt = "gunaimdown"; },
			{ com = constants.AnimComSetAnim; txt = "idle"; }
		}
	},
	{
		name = "pain";
		frames = 
		{
			{ com = constants.AnimComPlaySound; txt = "ouch.ogg" },
			{ com = constants.AnimComPop; }, -- pop damage type
			{ com = constants.AnimComReduceHealth; },
			{ com = constants.AnimComPlaySound; param = 1; txt = "sohpaintst.ogg"; },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComCreateParticles; param = 2; txt = "pblood-player"; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealX; param = 9; },
			{ dur = 100; num = 16; com = constants.AnimComRealH; param = 73; },
			{ com = constants.AnimComRealX; param = 15; },
			{ dur = 100; num = 17; com = constants.AnimComRealH; param = 70; },
			{ com = constants.AnimComRealX; param = 9; },
			{ dur = 100; num = 16; com = constants.AnimComRealH; param = 73; },
			{ com = constants.AnimComSetAnim; txt = "idle"; }
		}
	},
		{
		name = "die";
		frames = 
		{
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 76; },
			{ dur = 100; num = 18; com = constants.AnimComRealY; param = -2; },
			{ dur = 100; num = 19; com = constants.AnimComRealY; param = -2; },
			{ dur = 100; num = 20; com = constants.AnimComRealH; param = 60; },
			{ dur = 100; num = 21; com = constants.AnimComRealH; param = 52; },
			{ dur = 100; num = 22; com = constants.AnimComRealH; param = 50; },
			{ dur = 100; num = 23; },
			{ dur = 100; num = 24; },
			{ dur = 100; num = 25; com = constants.AnimComRealH; param = 37; },
			{ dur = 100; num = 26; com = constants.AnimComRealH; param = 26; },
			{ dur = 0 }
		}
	},
	{
		name = "aim";
		frames = 
		{

		}
	},
	{
		name = "shoot";
		frames = 
		{

		}
	},
	{
		name = "sitshoot";
		frames = 
		{

		}
	},
	{
		name = "jumpshoot";
		frames = 
		{

		}
	},
	{
		name = "gunaimup";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "idle"; }
		}
	},
	{
		name = "gunliftaimup";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "idle"; }
		}
	},
	{
		name = "gunaimupshoot";
		frames = 
		{

		}
	},
	{
		name = "situpshoot";
		frames = 
		{

		}
	},
	{
		name = "sitdownshoot";
		frames = 
		{

		}
	},
	{
		name = "walkgunaimup";
		frames = 
		{
			{ com = constants.AnimComRealX; param = -5; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 74; },
			{ com = constants.AnimComShootBeh; param = 1; },
			{ com = constants.AnimComPushInt; param = 2; },
			{ com = constants.AnimComJumpIfXSpeedGreater; param = 28; },
			{ com = constants.AnimComPushInt; param = -32; },
			{ com = constants.AnimComPushInt; param = -58; },
			{ com = constants.AnimComPushInt; param = 1; },
			{ com = constants.AnimComEnvSprite; },
			{ com = constants.AnimComPushInt; param = 38; },
			{ com = constants.AnimComPushInt; param = -1; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComEnvSound; },
			{ dur = 100; num = 7; },
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComPushInt; param = 39; },
			{ com = constants.AnimComPushInt; param = -3; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 8; },
			{ com = constants.AnimComRealX; param = 5; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComPushInt; param = 41; },
			{ com = constants.AnimComPushInt; param = -4; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 9; },
			{ dur = 0 },
			{ com = constants.AnimComRealX; param = 7; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComPushInt; param = 42; },
			{ com = constants.AnimComPushInt; param = -4; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 10; },
			{ com = constants.AnimComPushInt; param = 43; },
			{ com = constants.AnimComPushInt; param = -2; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; param = 2; },
			{ com = constants.AnimComRealY; },
			{ dur = 100; num = 11; },
			{ com = constants.AnimComRealX; param = -5; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComPushInt; param = 42; },
			{ com = constants.AnimComPushInt; param = -1; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComEnvSound; param = 1; },
			{ dur = 100; num = 12; },
			{ com = constants.AnimComPushInt; param = 40; },
			{ com = constants.AnimComPushInt; param = -1; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ dur = 100; num = 14; },
			{ com = constants.AnimComPushInt; param = 37; },
			{ com = constants.AnimComPushInt; param = -3; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; param = 4; },
			{ com = constants.AnimComRealY; },
			{ dur = 100; num = 13; },
			{ com = constants.AnimComShootX; param = 36; },
			{ com = constants.AnimComPushInt; param = 40; },
			{ com = constants.AnimComPushInt; param = -3; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; param = 9; },
			{ com = constants.AnimComRealY; },
			{ dur = 100; num = 5; },
			{ com = constants.AnimComPushInt; param = 36; },
			{ com = constants.AnimComPushInt; param = -2; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; param = 3; },
			{ com = constants.AnimComRealY; },
			{ dur = 100; num = 6; },
			{ com = constants.AnimComRealX; param = -5; },
			{ com = constants.AnimComJump; param = 10; }
		}
	},
	{
		name = "gunaimdown";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "idle"; }
		}
	},
	{
		name = "gunliftaimdown";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "idle"; }
		}
	},
	{
		name = "gunaimdownshoot";
		frames = 
		{

		}
	},
	{
		name = "walkgunaimdown";
		frames = 
		{
			{ com = constants.AnimComRealX; param = -5; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 74; },
			{ com = constants.AnimComShootBeh; param = 1; },
			{ com = constants.AnimComPushInt; param = 2; },
			{ com = constants.AnimComJumpIfXSpeedGreater; param = 28; },
			{ com = constants.AnimComPushInt; param = -32; },
			{ com = constants.AnimComPushInt; param = -58; },
			{ com = constants.AnimComPushInt; param = 1; },
			{ com = constants.AnimComEnvSprite; },
			{ com = constants.AnimComPushInt; param = 38; },
			{ com = constants.AnimComPushInt; param = -1; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComEnvSound; },
			{ dur = 100; num = 7; },
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComPushInt; param = 39; },
			{ com = constants.AnimComPushInt; param = -3; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 8; },
			{ com = constants.AnimComRealX; param = 5; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComPushInt; param = 41; },
			{ com = constants.AnimComPushInt; param = -4; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 9; },
			{ dur = 0 },
			{ com = constants.AnimComRealX; param = 7; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComPushInt; param = 42; },
			{ com = constants.AnimComPushInt; param = -4; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 10; },
			{ com = constants.AnimComPushInt; param = 43; },
			{ com = constants.AnimComPushInt; param = -2; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; param = 2; },
			{ com = constants.AnimComRealY; },
			{ dur = 100; num = 11; },
			{ com = constants.AnimComRealX; param = -5; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComPushInt; param = 42; },
			{ com = constants.AnimComPushInt; param = -1; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComEnvSound; param = 1; },
			{ dur = 100; num = 12; },
			{ com = constants.AnimComPushInt; param = 40; },
			{ com = constants.AnimComPushInt; param = -1; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ dur = 100; num = 14; },
			{ com = constants.AnimComPushInt; param = 37; },
			{ com = constants.AnimComPushInt; param = -3; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; param = 4; },
			{ com = constants.AnimComRealY; },
			{ dur = 100; num = 13; },
			{ com = constants.AnimComShootX; param = 36; },
			{ com = constants.AnimComPushInt; param = 40; },
			{ com = constants.AnimComPushInt; param = -3; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; param = 9; },
			{ com = constants.AnimComRealY; },
			{ dur = 100; num = 5; },
			{ com = constants.AnimComPushInt; param = 36; },
			{ com = constants.AnimComPushInt; param = -2; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; param = 3; },
			{ com = constants.AnimComRealY; },
			{ dur = 100; num = 6; },
			{ com = constants.AnimComRealX; param = -5; },
			{ com = constants.AnimComJump; param = 10; }
		}
	},
	{
		name = "jumpgunaimup";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "jump"; }
		}
	},
	{
		name = "jumpgunliftaimup";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "jump"; }
		}
	},
	{
		name = "jumpgunaimupshoot";
		frames = 
		{

		}
	},
	{
		name = "jumpgunaimdown";
		frames = 
		{

		}
	},
	{
		name = "jumpgunliftaimdown";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "jump"; }
		}
	},
	{
		name = "jumpgunaimdownshoot";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "jump"; }
		}
	},
	{
		name = "stop";
		frames = 
		{
			{ com = constants.AnimComEnvSound; param = 2; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 71; },
			{ com = constants.AnimComPushInt; param = 48; },
			{ com = constants.AnimComPushInt; param = -25; },
			{ com = constants.AnimComPushInt; param = 7; },
			{ com = constants.AnimComEnvSprite; param = 2; },
			{ com = constants.AnimComRealX; txt = "gunaimup"; },
			{ param = -1; txt = "gunaimdown"; },
			{ dur = 100; num = 4; },
			{ com = constants.AnimComSetAnim; txt = "idle"; }
		}
	},
	{
		name = "morph_out";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 56; },
			{ com = constants.AnimComRealH; param = 73; },
			{ com = constants.AnimComSetBulletCollidable; param = 1; },
			{ param = 1; },
			{ dur = 100; num = 34; },
			{ dur = 100; num = 35; },
			{ dur = 100; num = 36; },
			{ dur = 100; num = 37; },
			{ dur = 100; num = 38; },
			{ dur = 100; num = 39; },
			{ dur = 100; num = 40; },
			{ dur = 100; num = 41; },
			{ com = constants.AnimComSetAnim; txt = "idle"; }
		}
	},
	{
		name = "morph_in";
		frames = 
		{
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 73; },
			{ com = constants.AnimComSetBulletCollidable; param = 1 },
			{ com = constants.AnimComSetShadow; param = 1 },
			{ dur = 100; num = 34 },
			{ dur = 100; num = 35 },
			{ dur = 100; num = 36 },
			{ dur = 100; num = 37 },
			{ dur = 100; num = 38 },
			{ dur = 100; num = 39 },
			{ dur = 100; num = 40 },
			{ dur = 100; num = 41 },
			{ com = constants.AnimComStopMorphing },
			{ com = constants.AnimComSetAnim; txt = "idle"; }
		}
	}
}
