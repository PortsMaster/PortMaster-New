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
			{ com = constants.AnimComSetHealth; param = 300 },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{
		name = "idle";
		frames =
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 70 },
			{ com = constants.AnimComRealH; param = 153 },
			{ dur = 100; num = 0 },
		}
	},
	{
		name = "speak-start";
		frames =
		{
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 70 },
			{ com = constants.AnimComRealH; param = 153 },
			{ dur = 100; num = 8 },
			{ com = constants.AnimComSetAnim; txt = "speak-loop" },
		}
	},
	{
		name = "speak-loop";
		frames =
		{
			{ dur = 100; num = 9 },
			{ dur = 100; num = 10 },
			{ com = constants.AnimComLoop },
		}
	},
	{
		name = "speak-wait";
		frames =
		{
			{ dur = 100; num = 9 },
		}
	},
	{
		name = "speak-end";
		frames =
		{
			{ dur = 100; num = 9 },
			{ dur = 100; num = 8 },
			{ com = constants.AnimComSetAnim; txt = "move" },
		}
	},
	{ 
		-- Создание
		name = "pain";
		frames = 
		{
			{ com = constants.AnimComPop },
			{ com = constants.AnimComPop },
			{ com = constants.AnimComRecover }
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
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 1 },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 2 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 1 },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 2 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 1 },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 2 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 1 },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 2 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 1 },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 2 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 1 },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 2 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 1 },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 2 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 1 },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 2 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 1 },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 2 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 1 },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 2 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 1 },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 2 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 1 },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 2 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 1 },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 2 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 1 },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 2 },
			{ com = constants.AnimComRealX; param = 2 },
			{ dur = 100; num = 3 },
			{ com = constants.AnimComSetAnim; txt = "open" },
		}
	},
	{
		name = "open";
		frames =
		{
			{ com = constants.AnimComPushInt; param = 2+8+64 },
			{ com = constants.AnimComFlyToWaypoint; param = 0 },
			{ com = constants.AnimComStop },
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComPushInt; param = -56 },
			{ com = constants.AnimComPushInt; param = -154 },
			{ com = constants.AnimComCreateObject; txt = "2011btardisdoor" },
			{ num = 4; dur = 100; },
			{ num = 4; dur = 100; com = constants.AnimComCreateEnemy; txt = "btard" },
			{ num = 4; dur = 100; com = constants.AnimComCreateEnemy; txt = "btard" },
			{ num = 4; dur = 100; com = constants.AnimComCreateEnemy; txt = "btard" },
			{ num = 4; dur = 100; },
			{ com = constants.AnimComSetAnim; txt = "move" }
		}
	},
}



