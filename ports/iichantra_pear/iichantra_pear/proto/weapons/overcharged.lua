	--forbidden
name = "overcharged";

reload_time = 500;
bullets_per_shot = 20;
damage_type = 2;

push_force = 6.0;

-- Описание пули
bullet_damage = 120;
bullet_vel = 2;

-- Описание спрайта пули
texture = "overcharged";

z = -0.001;

image_width = 256;
image_height = 64;
frame_width = 64;
frame_height = 32;
frames_count = 7;

-- просто переменая, такое тоже можно
local sound_shoot = "weapons/overcharged.ogg"

animations = 
{
	{
		-- Пуля, летящая прямо
		name = "straight";
		frames = 
		{
			{ com = constants.AnimComPlaySound; txt = sound_shoot; param = 1 },
			{ com = constants.AnimComRealW; param = 5 },
			{ com = constants.AnimComSetShielding; param = 1 },
			{ dur = 1; num = 0; com = constants.AnimComRealH; param = 5 },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComCreateParticles; txt = "povercharged2"; param = 2 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -8 },
			{ com = constants.AnimComCreateEffect; txt ="flash-straight"; param = 13 },
			{ com = constants.AnimComSetAnim; txt = "fly" }
		}
	},
	{
		-- Пуля, летящая по диагонали вниз
		name = "diagdown";
		frames = 
		{
			{ com = constants.AnimComPlaySound; txt = sound_shoot; param = 1 },
			{ com = constants.AnimComSetShielding; param = 1 },
			{ com = constants.AnimComRealW; param = 5 },
			{ dur = 1; num = 0; com = constants.AnimComRealH; param = 5 },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComCreateParticles; txt = "povercharged2"; param = 2 },
			{ com = constants.AnimComPushInt; param = -3 },
			{ com = constants.AnimComPushInt; param = -34 },
			{ com = constants.AnimComCreateEffect; txt ="flash-angle-down"; param = 13 },
			{ com = constants.AnimComSetAnim; txt = "fly" }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "diagup";
		frames = 
		{
			{ com = constants.AnimComPlaySound; txt = sound_shoot; param = 1 },
			{ com = constants.AnimComSetShielding; param = 1 },
			{ com = constants.AnimComRealW; param = 5 },
			{ dur = 1; num = 0; com = constants.AnimComRealH; param = 5 },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComPushInt; },
			{ com = constants.AnimComCreateParticles; txt = "povercharged2"; param = 2 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -10 },
			{ com = constants.AnimComCreateEffect; txt ="flash-angle-up"; param = 13 },
			{ com = constants.AnimComSetAnim; txt = "fly" }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "fly";
		frames = 
		{
			{ dur = 50; num = 0},
			{ com = constants.AnimComRealW; param = 9 },
			{ com = constants.AnimComInitH; param = 9 },
			{ dur = 50; num = 1},
			{ com = constants.AnimComRealW; param = 11 },
			{ com = constants.AnimComInitH; param = 11 },
			{ dur = 50; num = 2},
			{ com = constants.AnimComRealW; param = 23 },
			{ com = constants.AnimComInitH; param = 23 },
			{ dur = 50; num = 3},
			{ dur = 0 },
			{ com = constants.AnimComRealW; param = 56 },
			{ com = constants.AnimComInitH; param = 61 },
			{ dur = 100; num = 4},
			{ com = constants.AnimComRealW; param = 47 },
			{ com = constants.AnimComInitH; param = 53 },
			{ dur = 100; num = 5},
			{ dur = 100; num = 6},
			{ com = constants.AnimComJump; param = 10 }
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
			{ com = constants.AnimComPushInt; param = -21 },
			{ com = constants.AnimComPushInt; param = -24 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "explosion-twisted" },
			{ com = constants.AnimComDestroyObject }
		}
	}
}