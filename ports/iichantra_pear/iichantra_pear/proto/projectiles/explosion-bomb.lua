--forbidden
name = "explosion-bomb";

physic = 1;
phys_ghostlike = 1;
push_force = 4.0;
damage_type = 3;

reload_time = 500;
bullets_per_shot = 0;
multiple_targets = 1;
hurts_same_type = 1;

-- Описание пули
bullet_damage = 15;
bullet_vel = 0;

-- Описание спрайта пули
texture = "heli";

image_width = 256;
image_height = 64;
frame_width = 64;
frame_height = 64;
frames_count = 4;
z = 0;

bounce = 0;

local explosion_x = 8;
local explosion_y = 8;

animations = 
{
	{
		-- Пуля, летящая прямо
		name = "straight";
		frames = 
		{
			{ com = constants.AnimComPlaySound; txt = "grenade-explosion" },
			{ com = constants.AnimComRealW; param = 37 },
			{ com = constants.AnimComRealH; param = 37 },
			{ com = constants.AnimComRealX; param = -explosion_x },
			{ com = constants.AnimComRealY; param = -explosion_y },
			{ dur = 100; num = 3 },
			{ com = constants.AnimComRealW; param = 24+2*explosion_x },
			{ com = constants.AnimComRealH; param = 19+2*explosion_y },
			{ dur = 100; num = 4 },
			{ com = constants.AnimComRealW; param = 47+2*explosion_x },
			{ com = constants.AnimComRealH; param = 31+2*explosion_y },
			{ dur = 100; num = 5 },
			{ com = constants.AnimComRealW; param = 38+2*explosion_x },
			{ com = constants.AnimComRealH; param = 32+2*explosion_y },
			{ dur = 100; num = 6 },
			{ com = constants.AnimComRealW; param = 40+2*explosion_x },
			{ com = constants.AnimComRealH; param = 35+2*explosion_y },
			{ dur = 100; num = 7 },
			{ com = constants.AnimComRealW; param = 37+2*explosion_x },
			{ com = constants.AnimComRealH; param = 35+2*explosion_y },
			{ dur = 100; num = 8 },
			{ com = constants.AnimComRealW; param = 36+2*explosion_x },
			{ com = constants.AnimComRealH; param = 36+2*explosion_y },
			{ dur = 100; num = 9 },
			{ com = constants.AnimComRealW; param = 36+2*explosion_x },
			{ com = constants.AnimComRealH; param = 36+2*explosion_y },
			{ dur = 100; num = 10 },
			{ com = constants.AnimComRealW; param = 25+2*explosion_x },
			{ com = constants.AnimComRealH; param = 32+2*explosion_y },
			{ dur = 100; num = 11 },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{
		-- Пуля, летящая по диагонали вниз
		name = "diagdown";
		frames = 
		{
			{ com = constants.AnimComSetAnim; txt = "straight" },
			{ dur = 100; num = 3 },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "diagup";
		frames = 
		{

			{ com = constants.AnimComSetAnim; txt = "straight" },
			{ dur = 100; num = 3 },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{
		name = "miss";
		frames =
		{
			{ com = constants.AnimComRealW; param = 37 },
			{ com = constants.AnimComRealH; param = 37 },
			{ com = constants.AnimComRealX; param = -explosion_x },
			{ com = constants.AnimComRealY; param = -explosion_y },
			{ dur = 100; num = 3 },
			{ com = constants.AnimComRealW; param = 24+2*explosion_x },
			{ com = constants.AnimComRealH; param = 19+2*explosion_y },
			{ dur = 100; num = 4 },
			{ com = constants.AnimComRealW; param = 47+2*explosion_x },
			{ com = constants.AnimComRealH; param = 31+2*explosion_y },
			{ dur = 100; num = 5 },
			{ com = constants.AnimComRealW; param = 38+2*explosion_x },
			{ com = constants.AnimComRealH; param = 32+2*explosion_y },
			{ dur = 100; num = 6 },
			{ com = constants.AnimComRealW; param = 40+2*explosion_x },
			{ com = constants.AnimComRealH; param = 35+2*explosion_y },
			{ dur = 100; num = 7 },
			{ com = constants.AnimComRealW; param = 37+2*explosion_x },
			{ com = constants.AnimComRealH; param = 35+2*explosion_y },
			{ dur = 100; num = 8 },
			{ com = constants.AnimComRealW; param = 36+2*explosion_x },
			{ com = constants.AnimComRealH; param = 36+2*explosion_y },
			{ dur = 100; num = 9 },
			{ com = constants.AnimComRealW; param = 36+2*explosion_x },
			{ com = constants.AnimComRealH; param = 36+2*explosion_y },
			{ dur = 100; num = 10 },
			{ com = constants.AnimComRealW; param = 25+2*explosion_x },
			{ com = constants.AnimComRealH; param = 32+2*explosion_y },
			{ dur = 100; num = 11 },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{
		--Уничтожение
		name = "die";
		frames =
		{
			{ com = constants.AnimComRealW; param = 37 },
			{ com = constants.AnimComRealH; param = 37 },
			{ com = constants.AnimComRealX; param = -explosion_x },
			{ com = constants.AnimComRealY; param = -explosion_y },
			{ dur = 100; num = 3 },
			{ com = constants.AnimComRealW; param = 24+2*explosion_x },
			{ com = constants.AnimComRealH; param = 19+2*explosion_y },
			{ dur = 100; num = 4 },
			{ com = constants.AnimComRealW; param = 47+2*explosion_x },
			{ com = constants.AnimComRealH; param = 31+2*explosion_y },
			{ dur = 100; num = 5 },
			{ com = constants.AnimComRealW; param = 38+2*explosion_x },
			{ com = constants.AnimComRealH; param = 32+2*explosion_y },
			{ dur = 100; num = 6 },
			{ com = constants.AnimComRealW; param = 40+2*explosion_x },
			{ com = constants.AnimComRealH; param = 35+2*explosion_y },
			{ dur = 100; num = 7 },
			{ com = constants.AnimComRealW; param = 37+2*explosion_x },
			{ com = constants.AnimComRealH; param = 35+2*explosion_y },
			{ dur = 100; num = 8 },
			{ com = constants.AnimComRealW; param = 36+2*explosion_x },
			{ com = constants.AnimComRealH; param = 36+2*explosion_y },
			{ dur = 100; num = 9 },
			{ com = constants.AnimComRealW; param = 36+2*explosion_x },
			{ com = constants.AnimComRealH; param = 36+2*explosion_y },
			{ dur = 100; num = 10 },
			{ com = constants.AnimComRealW; param = 25+2*explosion_x },
			{ com = constants.AnimComRealH; param = 32+2*explosion_y },
			{ dur = 100; num = 11 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}