--forbidden
physic = 1;
phys_solid = 0;
phys_bullet_collidable = 1;
phys_max_x_vel = 5;
phys_max_y_vel = 50;
phys_jump_vel = 20;
phys_walk_acc = 3;
phys_one_sided = 0;
mp_count = 1;
offscreen_distance = 640
offscreen_behavior = constants.offscreenNone

drops_shadow = 1;
shadow_width = 0.5;

gravity_x = 0;
gravity_y = 0;

mass = -1;

faction_id = 3;
faction_hates = { -1, -2 };

-- Описание спрайта

texture = "btardis";

z = -0.1;

facing = constants.facingFixed

animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComMirror },
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 70 },
			{ com = constants.AnimComRealH; param = 153 },
			{ com = constants.AnimComSetHealth; param = 500 },
			{ com = constants.AnimComSetAnim; txt = "move" }	
		}
	},
	{ 
		-- Создание
		name = "move";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 2+8+64 },
			{ com = constants.AnimComFlyToWaypoint; param = 1600 },
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 70 },
			{ com = constants.AnimComRealH; param = 153 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 1 },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 2 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComSetAnim; txt = "aimed"; param = 128 },
			{ com = constants.AnimComSetAnim; txt = "homing"; param = 128 },
			{ com = constants.AnimComSetAnim; txt = "spread"; },
		}
	},
	{
		name = "spread";
		frames =
		{
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = 90 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile" },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = 45 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile" },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = 68 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile" },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = 135 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile" },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComPushInt; param = dx },
			{ com = constants.AnimComPushInt; param = dy },
			{ com = constants.AnimComPushInt; param = 158 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "troll-projectile" },
			{ com = constants.AnimComSetAnim; txt = "move" }
		}
	},
	{
		name = "aimed";
		frames =
		{
			{ com = constants.AnimComAdjustAim; param = 4 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAimedShot; txt = "troll-projectile" },
			{ com = constants.AnimComSetAnim; txt = "move" }
		}
	},
	{ 
		-- Создание
		name = "pain";
		frames = 
		{
			{ com = constants.AnimComPop },
			{ com = constants.AnimComReduceHealth },
			{ com = constants.AnimComCallFunction; txt = "btardis_hurt" },
			{ com = constants.AnimComRecover }
		}
	},
	{
		name = "die";
		frames = 
		{
			{ com = constants.AnimComCallFunction; txt = "btardis_dead" },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{
		name = "homing";
		frames =
		{
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "slowpoke-homing-projectile" },
			{ com = constants.AnimComSetAnim; txt = "move" }
		}
	}
}



