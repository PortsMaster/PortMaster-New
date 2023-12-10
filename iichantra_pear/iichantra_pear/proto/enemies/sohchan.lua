--forbidden
name = "sohchan";

--main_weapon = "mikuru_beam";
main_weapon = "sfg9000";

--if difficulty < 1 then alt_weapon = "rocketlauncher"; end
--alt_weapon = "lol_wut";
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

faction_id = 0;

FunctionName = "CreatePlayer";

-- Описание спрайта

--LoadTexture("soh-chan1024.png")
texture = "soh-chan1024";
z = -0.001;

animations =
{
	{
		name = "init";
		frames = 
		{
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComPushInt; param = -50; },
			{ com = constants.AnimComMPSet; param = 1; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 74; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComPushInt; param = 40; },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; },
			{ com = constants.AnimComPushInt; param = 40; },
			{ com = constants.AnimComPushInt; param = -1; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 1; },
			{ com = constants.AnimComPushInt; param = 40; },
			{ com = constants.AnimComPushInt; param = -3; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 2; },
			{ com = constants.AnimComPushInt; param = 40; },
			{ com = constants.AnimComPushInt; param = -1; },
			{ com = constants.AnimComMPSet; },
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
			{ com = constants.AnimComRealH; param = 74; },
			{ com = constants.AnimComShootBeh; param = 1; },
			{ com = constants.AnimComPushInt; param = 2; },
			{ com = constants.AnimComJumpIfXSpeedGreater; param = 28; },
			{ com = constants.AnimComPushInt; param = -32; },
			{ com = constants.AnimComPushInt; param = -58; },
			{ com = constants.AnimComPushInt; param = 5; },
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
			{ dur = 100; num = 45; com = constants.AnimComRealH; param = 81; },
			{ dur = 100; num = 46; com = constants.AnimComRealH; param = 73; },
			{ dur = 100; num = 47; com = constants.AnimComRealH; param = 65; },
			{ com = constants.AnimComJumpIfYSpeedGreater; param = 10; },
			{ com = constants.AnimComJump; param = 7; },
			{ dur = 0 },
			{ com = constants.AnimComSetAnim; txt = "fly"; },
			{ com = constants.AnimComRealX; param = 6; },
			{ dur = 100; num = 48; com = constants.AnimComRealH; param = 73; },
			{ dur = 100; num = 49; com = constants.AnimComRealH; param = 81; },
			{ com = constants.AnimComSetAnim; txt = "jump"; }
		}
	},
	{
		name = "fly";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ dur = 100; num = 47; com = constants.AnimComRealH; param = 73; },
			{ com = constants.AnimComRealX; param = 6; },
			{ dur = 100; num = 48; com = constants.AnimComRealH; param = 81; },
			{ dur = 100; num = 49; com = constants.AnimComRealH; param = 81; }
		}
	},
	{
		name = "sit";
		frames = 
		{
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComPushInt; param = 42; },
			{ com = constants.AnimComPushInt; param = -4; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 24; com = constants.AnimComRealH; param = 59; }
		}
	},
	{
		name = "sitaimup";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 11; },
			{ com = constants.AnimComRealY; param = 10; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComPushInt; param = 24; },
			{ com = constants.AnimComPushInt; param = -39; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 88; com = constants.AnimComRealH; param = 59; }
		}
	},
	{
		name = "sitaimdown";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 3; },
			{ com = constants.AnimComRealY; param = -1; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComPushInt; param = 22; },
			{ com = constants.AnimComPushInt; param = 28; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 91; com = constants.AnimComRealH; param = 59; }
		}
	},
	{
		name = "land";
		frames = 
		{
			{ com = constants.AnimComRealX; param = -8 }, --16
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 58; },  --40
			{ com = constants.AnimComEnvSound; },
			{ com = constants.AnimComEnvSound; param = 1; },
			{ com = constants.AnimComPushInt; param = -128; },
			{ com = constants.AnimComPushInt; param = -58; },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComEnvSprite; param = 1; },
			{ com = constants.AnimComRealH; param = 57; },
			{ dur = 100; num = 43; },
			{ com = constants.AnimComRealW; param = 55; },
			{ com = constants.AnimComRealH; param = 74; },
			{ dur = 100; num = 44; },
			{ com = constants.AnimComSetAnim; txt = "init"; }
		}
	},
	{
		name = "pain";
		frames = 
		{
			{ com = constants.AnimComPop; }, -- pop damage type
			{ com = constants.AnimComReduceHealth; },
			{ com = constants.AnimComCallFunction; txt = "fake_soh_hurt" },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateParticles; txt = "pblood-player"; param = 2 },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealX; param = 5; },
			{ dur = 100; num = 28; com = constants.AnimComRealH; param = 73; },
			{ com = constants.AnimComRealX; param = 15; },
			{ dur = 100; num = 29; com = constants.AnimComRealH; param = 70; },
			{ com = constants.AnimComRealX; param = 5; },
			{ dur = 100; num = 28; com = constants.AnimComRealH; param = 73; },
			{ com = constants.AnimComSetAnim; txt = "init" }
		}
	},
	{
		name = "die";
		frames = 
		{
			{ com = constants.AnimComCallFunction; txt = "fake_soh_dead" },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 76; },
			{ dur = 100; num = 30; com = constants.AnimComRealY; param = -2; },
			{ dur = 100; num = 31; com = constants.AnimComRealY; param = -2; },
			{ com = constants.AnimComRealY; param = -7; },
			{ dur = 100; num = 32; com = constants.AnimComRealH; param = 81; },
			{ com = constants.AnimComRealY; param = -4; },
			{ dur = 100; num = 33; com = constants.AnimComRealH; param = 78; },
			{ com = constants.AnimComRealY; },
			{ dur = 100; num = 34; com = constants.AnimComRealH; param = 74; },
			{ dur = 100; num = 35; com = constants.AnimComRealH; param = 73; },
			{ dur = 100; num = 36; com = constants.AnimComRealH; param = 60; },
			{ dur = 100; num = 37; com = constants.AnimComRealH; param = 52; },
			{ dur = 100; num = 38; com = constants.AnimComRealH; param = 50; },
			{ dur = 100; num = 39; },
			{ dur = 100; num = 40; },
			{ dur = 100; num = 41; com = constants.AnimComRealH; param = 37; },
			{ dur = 100; num = 42; com = constants.AnimComRealH; param = 26; }
		}
	},
	{
		name = "aim";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealY; param = -1; },
			{ com = constants.AnimComRealX; },
			{ dur = 100; num = 21; com = constants.AnimComRealH; param = 74; }
		}
	},
	{
		name = "shoot";
		frames = 
		{
			{ com = constants.AnimComSetAnimIfWeaponNotReady; txt = "aim"; },
			{ com = constants.AnimComRealY; param = -2; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 75; },
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComPushInt; param = 40; },
			{ com = constants.AnimComPushInt; param = -11; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComShootDir; },
			{ dur = 100; num = 22; com = constants.AnimComShoot; },
			{ com = constants.AnimComSetAnim; txt = "aim"; }
		}
	},
	{
		name = "sitshoot";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 1; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 59; },
			{ com = constants.AnimComSetAnimIfWeaponNotReady; txt = "sit"; },
			{ com = constants.AnimComPushInt; param = 40; },
			{ com = constants.AnimComPushInt; param = -4; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComShootDir; },
			{ dur = 100; num = 25; com = constants.AnimComShoot; },
			{ com = constants.AnimComRealX; param = 2; },
			{ dur = 100; num = 26; }
		}
	},
	{
		name = "jumpshoot";
		frames = 
		{
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealH; param = 65; },
			{ com = constants.AnimComPushInt; param = 34; },
			{ com = constants.AnimComPushInt; param = -7; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComShootDir; },
			{ com = constants.AnimComShoot; },
			{ dur = 100; num = 47; com = constants.AnimComRealH; param = 65; },
			{ com = constants.AnimComSetAnim; txt = "fly"; }
		}
	},
	{
		name = "gunaimup";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 73; },
			{ com = constants.AnimComRealX; param = 11; },
			{ com = constants.AnimComRealY; param = 9; },
			{ com = constants.AnimComPushInt; param = 24; },
			{ com = constants.AnimComPushInt; param = -45; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100; num = 51; com = constants.AnimComRealH; param = 75; }
		}
	},
	{
		name = "gunliftaimup";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 73; },
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ dur = 100; num = 50; },
			{ com = constants.AnimComSetAnim; txt = "gunaimup"; }
		}
	},
	{
		name = "gunaimupshoot";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 73; },
			{ com = constants.AnimComRealX; param = 11; },
			{ com = constants.AnimComRealY; param = 8; },
			{ com = constants.AnimComPushInt; param = 22; },
			{ com = constants.AnimComPushInt; param = -43; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComShootDir; param = 1; },
			{ dur = 100; num = 52; com = constants.AnimComShoot; },
			{ com = constants.AnimComRealY; param = 11; },
			{ dur = 100; num = 53; },
			{ com = constants.AnimComSetAnim; txt = "gunaimup"; }
		}
	},
	{
		name = "situpshoot";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 11; },
			{ com = constants.AnimComRealY; param = 2; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 65; },
			{ com = constants.AnimComPushInt; param = 22; },
			{ com = constants.AnimComPushInt; param = -33; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComShootDir; param = 1; },
			{ dur = 50; num = 89; com = constants.AnimComShoot; },
			{ com = constants.AnimComRealY; param = 4; },
			{ dur = 100; num = 90; },
			{ com = constants.AnimComSetAnim; txt = "sitaimup"; }
		}
	},
	{
		name = "sitdownshoot";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 3; },
			{ com = constants.AnimComRealY; param = -1; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 59; },
			{ com = constants.AnimComPushInt; param = 20; },
			{ com = constants.AnimComPushInt; param = 23; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComShootDir; param = 2; },
			{ dur = 50; num = 92; com = constants.AnimComShoot; },
			{ com = constants.AnimComSetAnim; txt = "sitaimdown"; }
		}
	},
	{
		name = "walkgunaimup";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 45; },
			{ com = constants.AnimComRealH; param = 75; },
			{ com = constants.AnimComRealX; param = 15; },
			{ com = constants.AnimComRealY; param = 7; },
			{ com = constants.AnimComShootBeh; param = 1; },
			{ com = constants.AnimComPushInt; param = 26; },
			{ com = constants.AnimComPushInt; param = -41; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 61; },
			{ com = constants.AnimComRealX; param = 9; },
			{ com = constants.AnimComRealY; param = 4; },
			{ com = constants.AnimComPushInt; param = 25; },
			{ com = constants.AnimComPushInt; param = -40; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 62; },
			{ com = constants.AnimComRealX; param = 10; },
			{ com = constants.AnimComRealY; param = 6; },
			{ com = constants.AnimComPushInt; param = 28; },
			{ com = constants.AnimComPushInt; param = -43; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 63; },
			{ com = constants.AnimComRealX; param = 13; },
			{ com = constants.AnimComRealY; param = 7; },
			{ com = constants.AnimComPushInt; param = 28; },
			{ com = constants.AnimComPushInt; param = -43; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 64; },
			{ com = constants.AnimComRealX; param = 22; },
			{ com = constants.AnimComRealY; param = 10; },
			{ com = constants.AnimComPushInt; param = 27; },
			{ com = constants.AnimComPushInt; param = -46; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 65; },
			{ com = constants.AnimComRealX; param = 13; },
			{ com = constants.AnimComRealY; param = 7; },
			{ com = constants.AnimComPushInt; param = 28; },
			{ com = constants.AnimComPushInt; param = -43; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 66; },
			{ com = constants.AnimComRealX; param = 7; },
			{ com = constants.AnimComRealY; param = 4; },
			{ com = constants.AnimComPushInt; param = 28; },
			{ com = constants.AnimComPushInt; param = -40; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 67; },
			{ com = constants.AnimComRealX; param = 11; },
			{ com = constants.AnimComRealY; param = 5; },
			{ com = constants.AnimComPushInt; param = 27; },
			{ com = constants.AnimComPushInt; param = -41; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 68; },
			{ com = constants.AnimComRealX; param = 13; },
			{ com = constants.AnimComRealY; param = 5; },
			{ com = constants.AnimComPushInt; param = 28; },
			{ com = constants.AnimComPushInt; param = -41; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 69; },
			{ com = constants.AnimComRealX; param = 21; },
			{ com = constants.AnimComRealY; param = 5; },
			{ com = constants.AnimComPushInt; param = 25; },
			{ com = constants.AnimComPushInt; param = -41; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 60; },
			{ com = constants.AnimComLoop; }
		}
	},
	{
		name = "gunaimdown";
		frames = 
		{
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ dur = 100; num = 81; com = constants.AnimComRealH; param = 72; }
		}
	},
	{
		name = "gunliftaimdown";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealX; param = 3; },
			{ com = constants.AnimComRealY; },
			{ dur = 100; num = 80; com = constants.AnimComRealH; param = 71; },
			{ com = constants.AnimComSetAnim; txt = "gunaimdown"; }
		}
	},
	{
		name = "gunaimdownshoot";
		frames = 
		{
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 72; },
			{ com = constants.AnimComPushInt; param = 23; },
			{ com = constants.AnimComPushInt; param = 14; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComShootDir; param = 2; },
			{ dur = 100; num = 82; com = constants.AnimComShoot; },
			{ com = constants.AnimComSetAnim; txt = "gunaimdown"; }
		}
	},
	{
		name = "walkgunaimdown";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 73; },
			{ com = constants.AnimComRealX; param = 10; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComShootBeh; param = 1; },
			{ com = constants.AnimComPushInt; param = 27; },
			{ com = constants.AnimComPushInt; param = 15; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 70; },
			{ com = constants.AnimComRealX; param = 4; },
			{ com = constants.AnimComRealY; },
			{ com = constants.AnimComPushInt; param = 27; },
			{ com = constants.AnimComPushInt; param = 15; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 71; },
			{ com = constants.AnimComRealX; param = -5; },
			{ com = constants.AnimComRealY; param = -3; },
			{ com = constants.AnimComPushInt; param = 32; },
			{ com = constants.AnimComPushInt; param = 21; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 72; },
			{ com = constants.AnimComRealX; param = -1; },
			{ com = constants.AnimComRealY; param = -2; },
			{ com = constants.AnimComPushInt; param = 31; },
			{ com = constants.AnimComPushInt; param = 19; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 73; },
			{ com = constants.AnimComPushInt; param = 30; },
			{ com = constants.AnimComPushInt; param = 15; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; param = 5; },
			{ com = constants.AnimComRealY; },
			{ dur = 100/diff; num = 74; },
			{ com = constants.AnimComRealX; param = 8; },
			{ com = constants.AnimComRealY; param = -1; },
			{ com = constants.AnimComPushInt; param = 28; },
			{ com = constants.AnimComPushInt; param = 17; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 75; },
			{ com = constants.AnimComRealX; param = 1; },
			{ com = constants.AnimComRealY; param = -2; },
			{ com = constants.AnimComPushInt; param = 30; },
			{ com = constants.AnimComPushInt; param = 19; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 76; },
			{ com = constants.AnimComPushInt; param = 29; },
			{ com = constants.AnimComPushInt; param = 19; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; param = -5; },
			{ com = constants.AnimComRealY; param = -3; },
			{ dur = 100/diff; num = 77; },
			{ com = constants.AnimComRealX; param = -2; },
			{ com = constants.AnimComRealY; param = -3; },
			{ dur = 100/diff; num = 78; },
			{ com = constants.AnimComRealX; param = 6; },
			{ com = constants.AnimComRealY; param = -2; },
			{ com = constants.AnimComPushInt; param = 30; },
			{ com = constants.AnimComPushInt; param = 19; },
			{ com = constants.AnimComMPSet; },
			{ dur = 100/diff; num = 79; },
			{ com = constants.AnimComLoop; }
		}
	},
	{
		name = "jumpgunaimup";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealY; param = 24; },
			{ com = constants.AnimComRealX; param = 10; },
			{ dur = 100; num = 85; com = constants.AnimComRealH; param = 62; }
		}
	},
	{
		name = "jumpgunliftaimup";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealY; param = 15; },
			{ com = constants.AnimComRealX; },
			{ dur = 100; num = 84; com = constants.AnimComRealH; param = 62; },
			{ com = constants.AnimComSetAnim; txt = "jumpgunaimup"; }
		}
	},
	{
		name = "jumpgunaimupshoot";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 62; },
			{ com = constants.AnimComRealX; param = 13; },
			{ com = constants.AnimComRealY; param = 28; },
			{ com = constants.AnimComPushInt; param = 21; },
			{ com = constants.AnimComPushInt; param = -58; },
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
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; param = 17; },
			{ dur = 100; num = 56; com = constants.AnimComRealH; param = 62; }
		}
	},
	{
		name = "jumpgunliftaimdown";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComPushInt; param = 27; },
			{ com = constants.AnimComPushInt; param = 28; },
			{ com = constants.AnimComMPSet; },
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; param = 17; },
			{ dur = 100; num = 55; com = constants.AnimComRealH; param = 62; },
			{ com = constants.AnimComSetAnim; txt = "jumpgunaimdown"; }
		}
	},
	{
		name = "jumpgunaimdownshoot";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealX; },
			{ com = constants.AnimComRealY; param = 17; },
			{ com = constants.AnimComRealH; param = 62; },
			{ com = constants.AnimComPushInt; param = 24; },
			{ com = constants.AnimComPushInt; param = 3; },
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
			--{ com = constants.AnimComRealW; param = 68; },
			--{ com = constants.AnimComRealH; param = 74; },
			{ com = constants.AnimComEnvSound; param = 2; },
			{ com = constants.AnimComRealW; param = 40; },
			{ com = constants.AnimComRealH; param = 75; },
			{ com = constants.AnimComPushInt; param = 48; },
			{ com = constants.AnimComPushInt; param = -25; },
			{ com = constants.AnimComPushInt; param = 7; },
			{ com = constants.AnimComEnvSprite; param = 2; },
			{ com = constants.AnimComSetAnimIfGunDirection; txt = "gunaimup"; param = 1 },
			{ com = constants.AnimComSetAnimIfGunDirection; txt = "gunaimdown"; param = -1 },
			{ dur = 100; num = 7; },
			{ com = constants.AnimComSetAnim; txt = "idle"; }
		}
	},
	{
		name = "morph_out";
		frames =
		{
			{ com = constants.AnimComSetShadow; param = 0 },
			{ com = constants.AnimComPlaySound; txt = "morph.ogg" },
			{ com = constants.AnimComRealW; param = 56; },
			{ com = constants.AnimComRealH; param = 74; },
			{ com = constants.AnimComRealX; param = -10; },
			{ com = constants.AnimComRealY; param = 0; },
			{ dur = 50; num = 93 },
			{ dur = 50; num = 94 },
			{ dur = 50; num = 93 },
			{ dur = 50; num = 94 },
			{ com = constants.AnimComSetBulletCollidable; param = 0 },
			{ dur = 50; num = 93 },
			{ dur = 50; num = 94 }
		}
	},
	{
		name = "morph_in";
		frames =
		{
			{ com = constants.AnimComRealW; param = 56; },
			{ com = constants.AnimComRealH; param = 74; },
			{ com = constants.AnimComRealX; param = -10; },
			{ com = constants.AnimComRealY; param = 0; },
			{ dur = 50; num = 94 },
			{ dur = 50; num = 93 },
			{ com = constants.AnimComSetBulletCollidable; param = 1 },
			{ com = constants.AnimComSetShadow; param = 1 },
			{ dur = 50; num = 94 },
			{ dur = 50; num = 93 },
			{ dur = 50; num = 94 },
			{ dur = 50; num = 93 },
			{ com = constants.AnimComSetShadow; param = 1 },
			{ com = constants.AnimComStopMorphing },
			{ com = constants.AnimComSetAnim; txt = "idle" }
		}
	}
}
