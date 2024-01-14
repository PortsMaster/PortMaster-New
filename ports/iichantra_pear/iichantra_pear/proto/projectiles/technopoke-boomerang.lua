--forbidden

bullets_per_shot = 0;
damage_type = 2;

local diff = (difficulty-1)/5+1;

-- Описание пули
bullet_damage = 30;
bullet_vel = 4;

-- Описание спрайта пули
texture = "technopoke_projectiles";

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
			{ com = constants.AnimComSetAccX; param = 0 },
			{ com = constants.AnimComRealW; param = 17 },
			{ com = constants.AnimComRealH; param = 17 },
			{ com = constants.AnimComSetRelativeVelX; param = 4000 },
			{ dur = 500; num = 7 },
			{ com = constants.AnimComSetRelativeVelX; param = 2000 },
			{ dur = 300; num = 8 },
			{ com = constants.AnimComSetRelativeVelX; param = 0 },
			{ dur = 100; num = 8 },
			{ com = constants.AnimComMirror; },
			{ dur = 100; num = 8 },
			{ com = constants.AnimComSetRelativeVelX; param = 2000 },
			{ dur = 300; num = 8 },
			{ com = constants.AnimComSetRelativeVelX; param = 4000 },
			{ dur = 500; num = 7 },
			{ com = constants.AnimComDestroyObject }
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