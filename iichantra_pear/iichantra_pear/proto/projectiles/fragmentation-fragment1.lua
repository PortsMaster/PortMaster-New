--forbidden
name = "fragmentation-fragment1";
texture = "fragmentation";
FunctionName = "CreateSprite";

z = -0.002;
bullet_damage = 25;
bullet_vel = 8;

local dx = 0;
local dy = 12;

animations = 
{
	{
		name = "straight";
		frames =
		{
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComRealW; param = 5 },
			{ com = constants.AnimComRealH; param = 7 },
			{ num = 10; dur = 1 },
		}
	},
	{
		name = "diagup";
		frames =
		{
			{ com = constants.AnimComPushInt; param = 1 },
			{ com = constants.AnimComRealW; param = 5 },
			{ com = constants.AnimComRealH; param = 5 },
			{ num = 13; dur = 1 }
		}

	},
	{
		name = "straightup";
		frames =
		{
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComRealW; param = 7 },
			{ com = constants.AnimComRealH; param = 5 },
			{ num = 12; dur = 1 }
		}

	},
	{
		name = "diagdown";
		frames =
		{
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComRealW; param = 5 },
			{ com = constants.AnimComRealH; param = 5 },
			{ num = 15; dur = 1 },
		}

	},
	{
		name = "straightdown";
		frames =
		{
			{ com = constants.AnimComPushInt; param = 1 },
			{ com = constants.AnimComRealW; param = 7 },
			{ com = constants.AnimComRealH; param = 5 },
			{ num = 25; dur = 1 },
		}

	},
	{
		name = "miss";
		frames =
		{
			{ com = constants.AnimComStartDying },
			{ com = constants.AnimComSetAnim; txt = "die" }
		}
	},
	{
		name = "die";
		frames = 
		{
			{ com = constants.AnimComStop },
			{ com = constants.AnimComPushInt; param = 8 },
			{ com = constants.AnimComLocalJumpIfIntEquals; param = 1},
			{ com = constants.AnimComRealW; param = 7 },
			{ com = constants.AnimComRealH; param = 7 },
			{ num = 17; dur = 100 },
			{ num = 18; dur = 100 },
			{ com = constants.AnimComDestroyObject },
			{ dur = 0 },
			{ com = constants.AnimComRealW; param = 5 },
			{ com = constants.AnimComRealH; param = 5 },
			{ num = 23; dur = 100 },
			{ num = 24; dur = 100 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}
