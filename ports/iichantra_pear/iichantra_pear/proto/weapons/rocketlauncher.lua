--forbidden
name = "rocketlauncher";

reload_time = 200;
bullets_per_shot = 20;
damage_type = 2;

push_force = 6.0;

-- Описание пули
bullet_damage = 20;
bullet_vel = 8;

-- Описание спрайта пули
texture = "rocket";

z = -0.001;

image_width = 256;
image_height = 64;
frame_width = 64;
frame_height = 32;
frames_count = 7;

-- просто переменая, такое тоже можно
local sound_shoot = "weapons/rocket.ogg"

animations = 
{
	{
		-- Пуля, летящая прямо
		name = "straight";
		frames = 
		{
			{ com = constants.AnimComPlaySound; txt = sound_shoot; param = 1 },
			{ com = constants.AnimComRealW; param = 17 },
			{ dur = 1; num = 0; com = constants.AnimComRealH; param = 7 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -8 },
			{ com = constants.AnimComCreateEffect; txt ="flash-straight"; param = 13 },
			{ dur = 100; num = 0},
			{ dur = 100; num = 1},
			{ dur = 100; num = 2},
			{ com = constants.AnimComJump; param = 6 }
		}
	},
	{
		-- Пуля, летящая по диагонали вниз
		name = "diagdown";
		frames = 
		{
			{ com = constants.AnimComPlaySound; txt = sound_shoot; param = 1 },
			{ com = constants.AnimComRealW; param = 10 },
			{ dur = 1; num = 3; com = constants.AnimComRealH; param = 10 },
			{ com = constants.AnimComPushInt; param = -3 },
			{ com = constants.AnimComPushInt; param = -34 },
			{ com = constants.AnimComCreateEffect; txt ="flash-angle-down"; param = 13 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 4 },
			{ com = constants.AnimComJump; param = 6 }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "diagup";
		frames = 
		{
			{ com = constants.AnimComPlaySound; txt = sound_shoot; param = 1 },
			{ com = constants.AnimComRealW; param = 10 },
			{ dur = 1; num = 5; com = constants.AnimComRealH; param = 10 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -10 },
			{ com = constants.AnimComCreateEffect; txt ="flash-angle-up"; param = 13 },
			{ dur = 100; num = 5},
			{ dur = 100; num = 6},
			{ com = constants.AnimComJump; param = 6 }
		}
	},
	{
		--Пуля попала в неподвижный объект.
		name = "miss";
		frames =
		{
			{ com = constants.AnimComStartDying },
			{ com = constants.AnimComSetAnim; txt = "die" }
		}
	},
	{
		-- Уничтожение пули
		name = "die";
		frames = 
		{
			{ com = constants.AnimComStop },
			{ com = constants.AnimComCreateEnemyBullet; txt = "explosion-rocket" },
			{ com = constants.AnimComDestroyObject }
		}
	}
}