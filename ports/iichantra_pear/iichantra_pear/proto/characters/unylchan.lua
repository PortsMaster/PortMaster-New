--forbidden
name = "unylchan";

local diff = (difficulty-1)/5+1;

main_weapon = "sfg5000";
--alt_weapon = "sfg5000";
--if difficulty < 1 then alt_weapon = "rocketlauncher"; end
health = 80 / difficulty;

physic = 1;
phys_solid = 0;
phys_bullet_collidable = 1;
phys_max_x_vel = 2.5;
phys_max_y_vel = 50;
phys_jump_vel = 12;
phys_walk_acc = 2.5;
mp_count = 2;
gravity_x = 0;
gravity_y = 0.3;

FunctionName = "CreatePlayer";

-- &#206;&#239;&#232;&#241;&#224;&#237;&#232;&#229; &#241;&#239;&#240;&#224;&#233;&#242;&#224;

texture = "unyl1024";
z = -0.0015;

image_width = 1024;
image_height = 2048;
frame_width = 128;
frame_height = 128;
frames_count = 86;

drops_shadow = 1;

faction_id = -1;

animations =
{
	{
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComPushInt; param = -50; },
			{ com = constants.AnimComMPSet; param = 1; },
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComPushInt; param = 37; },
			{ com = constants.AnimComPushInt; param = 3; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; com = constants.AnimComRealH; param = 71; },
			{ com = constants.AnimComPushInt; param = 37; },
			{ com = constants.AnimComPushInt; param = -2; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 1; com = constants.AnimComRealH; param = 72; },
			{ com = constants.AnimComPushInt; param = 37; },
			{ com = constants.AnimComPushInt; param = -5; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 2; com = constants.AnimComRealH; param = 73; },
			{ dur = 100; num = 3; com = constants.AnimComRealH; param = 74; },
			{ com = constants.AnimComPushInt; param = 37; },
			{ com = constants.AnimComPushInt; param = -2; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 2; com = constants.AnimComRealH; param = 73; },
			{ com = constants.AnimComPushInt; param = 37; },
			{ com = constants.AnimComPushInt; param = 3; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 1; com = constants.AnimComRealH; param = 72; },
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
			{ dur = 100/diff; num = 12; },
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComPushInt; param = 39; },
			{ com = constants.AnimComPushInt; param = -3; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 13; },
			{ com = constants.AnimComRealX; param = 4; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComPushInt; param = 41; },
			{ com = constants.AnimComPushInt; param = -4; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 14; },
			{ dur = 0 },
			{ com = constants.AnimComRealX; param = 7; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComPushInt; param = 42; },
			{ com = constants.AnimComPushInt; param = -4; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 15; },
			{ com = constants.AnimComPushInt; param = 43; },
			{ com = constants.AnimComPushInt; param = -2; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; param = 4; },
			{ com = constants.AnimComRealY; },
			{ dur = 100/diff; num = 16; },
			{ com = constants.AnimComRealX; param = -5; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComPushInt; param = 42; },
			{ com = constants.AnimComPushInt; param = -1; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComEnvSound; param = 1; },
			{ dur = 100/diff; num = 17; },
			{ com = constants.AnimComPushInt; param = 40; },
			{ com = constants.AnimComPushInt; param = -1; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ dur = 100/diff; num = 18; },
			{ com = constants.AnimComPushInt; param = 37; },
			{ com = constants.AnimComPushInt; param = -3; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; param = 5; },
			{ com = constants.AnimComRealY; },
			{ dur = 100/diff; num = 19; },
			{ com = constants.AnimComShootX; param = 36; },
			{ com = constants.AnimComPushInt; param = 40; },
			{ com = constants.AnimComPushInt; param = -3; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; param = 9; },
			{ com = constants.AnimComRealY; },
			{ dur = 100/diff; num = 10; },
			{ com = constants.AnimComPushInt; param = 36; },
			{ com = constants.AnimComPushInt; param = -2; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; param = 3; },
			{ com = constants.AnimComRealY; },
			{ dur = 100/diff; num = 11; },
			{ com = constants.AnimComRealX; param = -5; },
			{ com = constants.AnimComJump; param = 10; }
		}
	},
	{
		name = "jump";
		frames = 
		{
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ num = 45; com = constants.AnimComPushInt; param = -1; },
			{ com = constants.AnimComJumpIfYSpeedGreater; param = 10; },
			{ dur = 100; num = 45; com = constants.AnimComRealH; param = 61; },
			{ dur = 100; num = 46; com = constants.AnimComRealH; param = 53; },
			{ dur = 100; num = 47; com = constants.AnimComRealH; param = 65; },
			{ com = constants.AnimComJumpIfYSpeedGreater; param = 10; },
			{ com = constants.AnimComJump; param = 7; },
			{ dur = 0 },
			{ com = constants.AnimComSetAnim; txt = "fly"; },
			{ dur = 100; num = 48; com = constants.AnimComRealH; param = 73; },
			{ com = constants.AnimComSetAnim; txt = "jump"; }
		}
	},
	{
		name = "fly";
		frames = 
		{
			{ num = 47; com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ dur = 100; num = 47; com = constants.AnimComRealH; param = 63; },
			{ dur = 100; num = 48; com = constants.AnimComRealH; param = 73; },
			{ com = constants.AnimComJump; param = 4; }
		}
	},
	{
		name = "sit";
		frames = 
		{
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ dur = 100; num = 24; com = constants.AnimComRealH; param = 62; }
		}
	},
	{
		name = "land";
		frames = 
		{
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComPlaySound; txt = "foot-left"; },
			{ com = constants.AnimComPlaySound; txt = "foot-right"; },
			{ com = constants.AnimComPushInt; param = -128; },
			{ com = constants.AnimComPushInt; param = -58; },
			{ com = constants.AnimComCreateObject; txt = "dust-land"; },
			{ dur = 100; num = 49; com = constants.AnimComRealH; param = 62; },
			{ dur = 100; num = 43; },
			{ com = constants.AnimComSetAnimIfGunDirection; txt = "gunaimup"; param = 1 },
			{ com = constants.AnimComSetAnimIfGunDirection; txt = "gunaimdown"; param = -1 },
			{ com = constants.AnimComSetAnim; txt = "idle"; }
		}
	},
	{
		name = "aim";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 2; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ dur = 100; num = 21; com = constants.AnimComRealH; param = 71; }
		}
	},
	{
		name = "shoot";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 2; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 71; },
			{ com = constants.AnimComPushInt; param = 40; },
			{ com = constants.AnimComPushInt; param = -14; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComShootDir; },
			{ com = constants.AnimComRealX; },
			{ dur = 100; num = 22; com = constants.AnimComShoot; },
			{ com = constants.AnimComPushInt; param = 38; },
			{ com = constants.AnimComPushInt; param = -16; },
			{ com = constants.AnimComMPSet; },
			{ dur = 50; num = 23; com = constants.AnimComRealY; },
			{ com = constants.AnimComPushInt; param = 36; },
			{ com = constants.AnimComPushInt; param = -18; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealY; param = 1; },
			{ dur = 100; num = 20; },
			{ com = constants.AnimComPushInt; param = 33; },
			{ com = constants.AnimComPushInt; param = -23; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 23; com = constants.AnimComRealY; },
			{ com = constants.AnimComSetAnim; txt = "aim"; }
		}
	},
	{
		name = "sitshoot";
		frames = 
		{
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 59; },
			{ com = constants.AnimComPushInt; param = 42; },
			{ com = constants.AnimComPushInt; param = -9; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComShootDir; },
			{ dur = 100; num = 25; com = constants.AnimComShoot; },
			{ dur = 100; num = 26; com = constants.AnimComRealY; param = 1; }
		}
	},
	{
		name = "pain";
		frames = 
		{
			{ com = constants.AnimComPlaySound; txt = "ouch.ogg" },
			{ com = constants.AnimComPop; }, -- pop damage type
			{ com = constants.AnimComReduceHealth; },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateParticles; txt = "pblood-player"; param = 2 },
			{ com = constants.AnimComRealX; param = 3; },
			{ com = constants.AnimComRealY; param = -4; },
			{ com = constants.AnimComRealW; param = 40; },
			{ dur = 100; num = 28; com = constants.AnimComRealH; param = 75; },
			{ com = constants.AnimComRealX; param = 6; },
			{ dur = 100; num = 29; com = constants.AnimComRealY; param = -3; },
			{ com = constants.AnimComRealX; param = 3; },
			{ dur = 100; num = 28; com = constants.AnimComRealY; param = -4; },
			{ com = constants.AnimComRecover; }
		}
	},
	{
		name = "jumpshoot";
		frames = 
		{
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 65; },
			{ com = constants.AnimComPushInt; param = 46; },
			{ com = constants.AnimComPushInt; param = 17; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComShootDir; },
			{ dur = 100; num = 47; com = constants.AnimComShoot; },
			{ com = constants.AnimComSetAnim; txt = "fly"; }
		}
	},
	{
		name = "gunaimup";
		frames = 
		{
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; param = 6; },
			{ com = constants.AnimComRealW; param = 40; },
			{ dur = 100; num = 51; com = constants.AnimComRealH; param = 75; }
		}
	},
	{
		name = "gunliftaimup";
		frames = 
		{
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; param = -2; },
			{ com = constants.AnimComRealW; param = 40; },
			{ dur = 100; num = 50; com = constants.AnimComRealH; param = 73; },
			{ com = constants.AnimComRealY; param = 8; },
			{ dur = 100; num = 51; },
			{ com = constants.AnimComSetAnim; txt = "gunaimup"; }
		}
	},
	{
		name = "gunaimupshoot";
		frames = 
		{
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; param = 8; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 73; },
			{ com = constants.AnimComPushInt; param = 25; },
			{ com = constants.AnimComPushInt; param = -43; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComShootDir; param = 1; },
			{ dur = 100; num = 51; com = constants.AnimComShoot; },
			{ com = constants.AnimComRealY; param = 12; },
			{ dur = 100; num = 53; },
			{ com = constants.AnimComPushInt; param = 25; },
			{ com = constants.AnimComPushInt; param = -42; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComSetAnim; txt = "gunaimup"; }
		}
	},
	{
		name = "walkgunaimup";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 7; },
			{ com = constants.AnimComRealY; param = 7; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 75; },
			{ com = constants.AnimComShootBeh; param = 1; },
			{ com = constants.AnimComPushInt; param = 22; },
			{ com = constants.AnimComPushInt; param = -43; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 60; param = 10; },
			{ com = constants.AnimComPushInt; param = 30; },
			{ com = constants.AnimComPushInt; param = -43; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 61; com = constants.AnimComRealX; },
			{ dur = 100/diff; num = 62; com = constants.AnimComRealX; param = -2; },
			{ com = constants.AnimComPushInt; param = 34; },
			{ com = constants.AnimComPushInt; param = -43; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 63; com = constants.AnimComRealX; },
			{ dur = 100/diff; num = 64; com = constants.AnimComRealX; param = 5; },
			{ dur = 100/diff; num = 65; com = constants.AnimComRealX; param = 7; },
			{ com = constants.AnimComPushInt; param = 32; },
			{ com = constants.AnimComPushInt; param = -43; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 66; com = constants.AnimComRealX; param = 5; },
			{ com = constants.AnimComPushInt; param = 34; },
			{ com = constants.AnimComPushInt; param = -43; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 67; com = constants.AnimComRealX; param = -5; },
			{ com = constants.AnimComPushInt; param = 34; },
			{ com = constants.AnimComPushInt; param = -43; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 68; com = constants.AnimComRealX; },
			{ dur = 100/diff; num = 69; com = constants.AnimComRealX; param = 5; },
			{ com = constants.AnimComLoop; }
		}
	},
	{
		name = "gunaimdown";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 3; },
			{ com = constants.AnimComRealY; param = -2; },
			{ com = constants.AnimComRealW; param = 40; },
			{ dur = 100; num = 81; com = constants.AnimComRealH; param = 73; }
		}
	},
	{
		name = "gunliftaimdown";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 2; },
			{ com = constants.AnimComRealY; param = -2; },
			{ com = constants.AnimComRealW; param = 40; },
			{ dur = 100; num = 80; com = constants.AnimComRealH; param = 73; },
			{ com = constants.AnimComSetAnim; txt = "gunaimdown"; }
		}
	},
	{
		name = "gunaimdownshoot";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 2; },
			{ com = constants.AnimComRealY; param = -2; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 73; },
			{ com = constants.AnimComPushInt; param = 23; },
			{ com = constants.AnimComPushInt; param = 16; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComShootDir; param = 2; },
			{ com = constants.AnimComRealX; param = 3; },
			{ dur = 100; num = 82; com = constants.AnimComShoot; },
			{ com = constants.AnimComSetAnim; txt = "gunaimdown"; }
		}
	},
	{
		name = "walkgunaimdown";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 7; },
			{ com = constants.AnimComRealY; param = -5; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 75; },
			{ com = constants.AnimComShootBeh; param = 1; },
			{ com = constants.AnimComPushInt; param = 32; },
			{ com = constants.AnimComPushInt; param = 21; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 70; },
			{ com = constants.AnimComPushInt; param = 29; },
			{ com = constants.AnimComPushInt; param = 22; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 71; com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; param = -6; },
			{ com = constants.AnimComPushInt; param = 35; },
			{ com = constants.AnimComPushInt; param = 23; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 72; com = constants.AnimComRealX; param = -5; },
			{ dur = 100/diff; num = 73; com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; param = -5; },
			{ com = constants.AnimComPushInt; param = 37; },
			{ com = constants.AnimComPushInt; param = 21; },
			{ dur = 0 },
			{ dur = 100/diff; num = 74; com = constants.AnimComRealX; param = 5; },
			{ com = constants.AnimComPushInt; param = 36; },
			{ com = constants.AnimComPushInt; param = 21; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 75; com = constants.AnimComRealX; param = 7; },
			{ com = constants.AnimComRealY; param = -7; },
			{ com = constants.AnimComPushInt; param = 34; },
			{ com = constants.AnimComPushInt; param = 26; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 76; com = constants.AnimComRealX; param = 5; },
			{ dur = 100/diff; num = 77; com = constants.AnimComRealX; param = -3; },
			{ com = constants.AnimComRealY; param = -6; },
			{ com = constants.AnimComPushInt; param = 36; },
			{ com = constants.AnimComPushInt; param = 24; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 78; com = constants.AnimComRealX; },
			{ com = constants.AnimComPushInt; param = 36; },
			{ com = constants.AnimComPushInt; param = 21; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealY; param = -5; },
			{ com = constants.AnimComPushInt; param = 35; },
			{ com = constants.AnimComPushInt; param = 22; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 79; com = constants.AnimComRealX; param = 6; },
			{ com = constants.AnimComLoop; }
		}
	},
	{
		name = "jumpgunaimup";
		frames = 
		{
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ dur = 100; num = 85; com = constants.AnimComRealH; param = 62; }
		}
	},
	{
		name = "jumpgunliftaimup";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "jumpgunaimup"; }
		}
	},
	{
		name = "jumpgunaimupshoot";
		frames = 
		{
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 62; },
			{ com = constants.AnimComPushInt; param = 39; },
			{ com = constants.AnimComPushInt; param = -23; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComShootDir; param = 1; },
			{ dur = 100; num = 86; com = constants.AnimComShoot; },
			{ com = constants.AnimComSetAnim; txt = "jumpgunaimup"; }
		}
	},
	{
		name = "jumpgunaimdown";
		frames = 
		{
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ dur = 100; num = 56; com = constants.AnimComRealH; param = 62; }
		}
	},
	{
		name = "jumpgunliftaimdown";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "jumpgunaimdown"; }
		}
	},
	{
		name = "jumpgunaimdownshoot";
		frames = 
		{
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 62; },
			{ com = constants.AnimComPushInt; param = 34; },
			{ com = constants.AnimComPushInt; param = 26; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComShootDir; param = 2; },
			{ dur = 100; num = 57; com = constants.AnimComShoot; },
			{ com = constants.AnimComSetAnim; txt = "jumpgunaimdown"; }
		}
	},
	{
		name = "stop";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 4; },
			{ com = constants.AnimComRealY; param = -1; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 71; },
			{ com = constants.AnimComPlaySound; txt = "stop"; },
			{ com = constants.AnimComPushInt; param = 37; },
			{ com = constants.AnimComPushInt; param = -28; },
			{ com = constants.AnimComCreateObject; param = 7; txt = "dust-stop"; },
			{ com = constants.AnimComSetAnimIfGunDirection; txt = "gunaimup"; param = 1 },
			{ com = constants.AnimComSetAnimIfGunDirection; txt = "gunaimdown"; param = -1 },
			{ dur = 100; num = 7; },
			{ com = constants.AnimComSetAnim; txt = "idle"; }
		}
	},
	{
		name = "sitaimup";
		frames = 
		{
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; param = 13; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComPushInt; param = 24; },
			{ com = constants.AnimComPushInt; param = -28; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 88; com = constants.AnimComRealH; param = 62; }
		}
	},
	{
		name = "sitaimdown";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 3; },
			{ com = constants.AnimComRealY; param = -1; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComPushInt; param = 24; },
			{ com = constants.AnimComPushInt; param = 22; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 91; com = constants.AnimComRealH; param = 62; }
		}
	},
	{
		name = "situpshoot";
		frames = 
		{
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; param = 10; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 65; },
			{ com = constants.AnimComPushInt; param = 24; },
			{ com = constants.AnimComPushInt; param = -28; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComShootDir; param = 1; },
			{ dur = 50; num = 88; com = constants.AnimComShoot; },
			{ com = constants.AnimComPushInt; param = 20; },
			{ com = constants.AnimComPushInt; param = -41; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 89; },
			{ com = constants.AnimComSetAnim; txt = "sitaimup"; }
		}
	},
	{
		name = "sitdownshoot";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 3; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 61; },
			{ com = constants.AnimComPushInt; param = 22; },
			{ com = constants.AnimComPushInt; param = 18; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComShootDir; param = 2; },
			{ dur = 50; num = 91; com = constants.AnimComShoot; },
			{ com = constants.AnimComSetAnim; txt = "sitaimdown"; }
		}
	},
	{
		name = "die";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 76; },
			{ dur = 100; num = 31; com = constants.AnimComRealY; param = -5; },
			{ com = constants.AnimComRealY; param = -10; },
			{ dur = 100; num = 32; com = constants.AnimComRealH; param = 81; },
			{ com = constants.AnimComRealY; param = -7; },
			{ dur = 100; num = 33; com = constants.AnimComRealH; param = 78; },
			{ com = constants.AnimComRealY; param = -3; },
			{ dur = 100; num = 34; com = constants.AnimComRealH; param = 74; },
			{ com = constants.AnimComRealY; param = -2; },
			{ dur = 100; num = 35; com = constants.AnimComRealH; param = 73; },
			{ dur = 100; num = 36; com = constants.AnimComRealH; param = 60; },
			{ com = constants.AnimComRealY; param = -3; },
			{ dur = 100; num = 37; com = constants.AnimComRealH; param = 52; },
			{ dur = 100; num = 38; com = constants.AnimComRealH; param = 50; },
			{ dur = 100; num = 39; },
			{ dur = 100; num = 40; },
			{ dur = 100; num = 41; },
			{ dur = 100; num = 42; },
			{ dur = 100; num = 41; },
			{ dur = 100; num = 40; },
			{ dur = 100; num = 41; },
			{ dur = 100; num = 42; },
			{ dur = 100; num = 41; },
			{ dur = 100; num = 40; },
			{ dur = 100; num = 41; },
			{ dur = 100; num = 42; },
			{ dur = 100; num = 41; }
		}
	},
	{
		name = "morph_out";
		frames =
		{
			{ com = constants.AnimComSetShadow; param = 0 },
			{ com = constants.AnimComPlaySound; txt = "morph.ogg" },
			{ com = constants.AnimComRealW; param = 52; },
			{ com = constants.AnimComRealH; param = 71; },
			{ com = constants.AnimComRealX; param = -5; },
			{ com = constants.AnimComRealY; param = -1; },
			{ dur = 50; num = 92 },
			{ dur = 50; num = 93 },
			{ dur = 50; num = 92 },
			{ dur = 50; num = 93 },
			{ com = constants.AnimComSetBulletCollidable; param = 0 },
			{ dur = 50; num = 92 },
			{ dur = 50; num = 93 }
		}
	},
	{
		name = "morph_in";
		frames =
		{
			{ com = constants.AnimComRealW; param = 52; },
			{ com = constants.AnimComRealH; param = 71; },
			{ com = constants.AnimComRealX; param = -5; },
			{ com = constants.AnimComRealY; param = -1; },
			{ dur = 50; num = 93 },
			{ dur = 50; num = 92 },
			{ com = constants.AnimComSetBulletCollidable; param = 1 },
			{ dur = 50; num = 93 },
			{ dur = 50; num = 92 },
			{ dur = 50; num = 93 },
			{ dur = 50; num = 92 },
			{ com = constants.AnimComSetShadow; param = 1 },
			{ com = constants.AnimComStopMorphing },
			{ com = constants.AnimComSetAnim; txt = "idle" }
		}
	}
}
