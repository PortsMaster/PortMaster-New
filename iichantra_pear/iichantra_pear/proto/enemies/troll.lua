physic = 1;
phys_solid = 0;
phys_bullet_collidable = 1;
phys_max_x_vel = 200;
phys_max_y_vel = 50;
phys_jump_vel = 20;
phys_walk_acc = 3;
mp_count = 1;
offscreen_distance = 640
offscreen_behavior = constants.offscreenNone

mass = -1; --Бесконечно большая масса.


drops_shadow = 1;

-- Описание спрайта

texture = "troll-main";

z = -0.1;

local health = 1000;

faction_id = 1
faction_hates = { -1, -2 }

animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComSetHealth; param = health },
			{ com = constants.AnimComRealW; param = 127 },
			{ com = constants.AnimComRealH; param = 88 },
			{ com = constants.AnimComMirror },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{
		name = "idle";
		frames =
		{
			{ com = constants.AnimComRealY; param = 0 },
			{ dur = 50; num = 0 },
	--		{ com = constants.AnimComRealX; param = 1 },
			{ com = constants.AnimComRealY; param = 1 },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 2 },
			{ com = constants.AnimComRealY; param = 1 },
			{ com = constants.AnimComRealX; param = -1 },
			{ dur = 50; num = 3 },
			{ dur = 50; num = 4 },
			{ dur = 150; num = 5 },
			{ dur = 50; num = 4 },
			{ dur = 50; num = 3 },
			{ com = constants.AnimComRealY; param = 0 },
			{ dur = 50; num = 2 },
			{ dur = 50; num = 1 },
			{ com = constants.AnimComLoop }
		}
	},
	{ 
		name = "pain";
		frames = 
		{
			{ com = constants.AnimComPlaySound; txt = "boss-hit.ogg" },
			{ com = constants.AnimComPop },
			{ com = constants.AnimComReduceHealth },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateParticles; txt = "pblood2" },
			{ com = constants.AnimComCallFunction; txt = "troll_hurt" },
			{ com = constants.AnimComRecover; }
		}
	},
	{ 
		name = "die";
		frames = 
		{
			{ com = constants.AnimComCallFunction; txt = "troll_death" },
			{ com = constants.AnimComSetHealth; param = health }
			
		}
	},
	{
		name = "respawn";
		frames =
		{
			{ com = constants.AnimComSetAnim; txt = "idle" }
		}
	},
	{
		name = "final_death";
		frames =
		{
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateParticles; txt = "pslime-troll" },
			{ com = constants.AnimComPushInt; param = -30 },
			{ com = constants.AnimComPushInt; param = -20 },
			{ com = constants.AnimComCreateParticles; txt = "pslime-troll" },
			{ com = constants.AnimComPushInt; param = 20 },
			{ com = constants.AnimComPushInt; param = -40 },
			{ com = constants.AnimComCreateParticles; txt = "pslime-troll" },
			{ com = constants.AnimComPushInt; param = 60 },
			{ com = constants.AnimComPushInt; param = 60 },
			{ com = constants.AnimComCreateParticles; txt = "pslime-troll" },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateParticles; txt = "pblood2" },
			{ com = constants.AnimComPushInt; param = -20 },
			{ com = constants.AnimComPushInt; param = 40 },
			{ com = constants.AnimComCreateParticles; txt = "pblood2" },
			{ com = constants.AnimComPushInt; param = -11 },
			{ com = constants.AnimComPushInt; param = 41 },
			{ com = constants.AnimComCreateParticles; txt = "pblood2" },
			{ com = constants.AnimComPushInt; param = -32 },
			{ com = constants.AnimComPushInt; param = 16 },
			{ com = constants.AnimComCreateParticles; txt = "pblood2" },
			{ com = constants.AnimComSetBulletCollidable; param = 0 },
			{ com = constants.AnimComSetInvisible; dur = 10000; param = 1 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}



