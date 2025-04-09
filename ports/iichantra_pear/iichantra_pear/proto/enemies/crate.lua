texture = "crate";
facing = constants.facingFixed

z = -0.008;

physic = 1;
phys_solid = 1;
phys_one_sided = 0;
phys_bullet_collidable = 1;

mass = 5;

ghost_to = 16;

phys_one_sided = 0;

phys_max_x_vel = 5;
phys_max_y_vel = 20;

gravity_x = 0;
gravity_y = 0.8;

faction_id = 3;

animations =
{
	{
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealH; param = 64 },
			{ com = constants.AnimComRealW; param = 64 },
			{ com = constants.AnimComRealX; param = 13 },
			{ com = constants.AnimComRealY; param = 13 },
			{ com = constants.AnimComSetAnim; txt = "crate4"; param = 232 },
			{ com = constants.AnimComSetAnim; txt = "crate1"; param = 232 },
			{ com = constants.AnimComSetAnim; txt = "crate2"; param = 232 },
			{ com = constants.AnimComSetAnim; txt = "crate3" }
		}
	},
	{
		name = "crate1";
		frames =
		{
			{ dur = 50, num = 0 },
		}
	},
	{
		name = "crate2";
		frames =
		{
			{ dur = 50, num = 1 },
		}
	},
	{
		name = "crate3";
		frames =
		{
			{ dur = 50, num = 2 },
		}
	},
	{
		name = "crate4";
		frames =
		{
			{ dur = 50, num = 3 },
		}
	},
	{
		name = "pain",
		frames = 
		{
			{ com = AnimComPop },
			{ com = AnimComPop }
		}
	
	}
}