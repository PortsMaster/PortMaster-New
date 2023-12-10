--forbidden
name = "fireshot2";

reload_time = 200;
bullets_per_shot = 0;
damage_type = 2;

local diff = (difficulty-1)/5+1;

-- Описание пули
bullet_damage = 10;
bullet_vel = 2*diff;

-- Описание спрайта пули
texture = "fireshot";

z = -0.001;

image_width = 64;
image_height = 16;
frames_count = 4;

-- просто переменая, такое тоже можно
local sound_shoot = "blaster_shot"

animations = 
{
	{
		-- Пуля, летящая прямо
		name = "straight";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 12 },
			{ com = constants.AnimComRealH; param = 12 },
			{ dur = 100; num = 0 },
			{ com = constants.AnimComLoop }
		}
	},
	{
		-- Пуля, летящая по диагонали вниз
		name = "diagdown";
		frames = 
		{
			{ dur = 0 }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "diagup";
		frames = 
		{
			{ dur = 0 }
		}
	},
	{
		--Пуля попала в неподвижный объект.
		name = "miss";
		frames =
		{
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateParticles; txt = "pspark"; param = 2 },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{
		-- Уничтожение пули
		name = "die";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateParticles; txt = "pspark"; param = 2 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}