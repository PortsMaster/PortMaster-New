--forbidden
name = "grenade";

physic = 1;

reload_time = 500;
bullets_per_shot = 20;

push_force = 2.0;

-- Описание пули
bullet_damage = 0;
bullet_vel = 3;

-- Описание спрайта пули
texture = "wave_weapon";

image_width = 256;
image_height = 64;
frame_width = 32;
frame_height = 32;
frames_count = 10;
z = -0.002;

bounce = 0;
local sound_shoot = "weapons/wave.ogg";

animations = 
{
	{
		name = "fly";
		frames =
		{
			{ com = constants.AnimComSetAccX; param = 0 },
			{ com = constants.AnimComSetAccY; param = 0 },
			{ dur = 30; num = 0 },
			{ dur = 30; num = 1 },
			{ dur = 30; num = 2 },
			{ dur = 30; num = 3 },
			{ dur = 30; num = 4 },
			{ dur = 30; num = 5 },
			{ dur = 30; num = 6 },
			{ dur = 30; num = 7 },
			{ dur = 30; num = 8 },
			{ dur = 30; num = 9 },
			{ dur = 30; num = 10 },
			{ dur = 30; num = 11 },
			{ dur = 30; num = 12 },
			{ dur = 30; num = 13 },
			{ dur = 30; num = 14 },
			{ dur = 30; num = 15 },
			{ dur = 30; num = 16 },
			{ dur = 30; num = 17 },
			{ dur = 30; num = 18 },
			{ dur = 30; num = 19 },
			{ dur = 30; num = 20 },
			{ dur = 30; num = 21 },
			{ dur = 30; num = 22 },
			{ dur = 30; num = 23 },
			{ dur = 30; num = 24 },
			{ com = constants.AnimComJump; param = 6 }
		}
	},
	{
		-- Пуля, летящая прямо
		name = "straight";
		frames = 
		{
			{ com = constants.AnimComSetVelY; param = -2000 },
			{ com = constants.AnimComSetRelativeVelX; param = 3000 },
			{ com = constants.AnimComPlaySound; txt = sound_shoot; param = 1 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 600 },
			{ com = constants.AnimComSetGravity }, 
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 13 },
			{ com = constants.AnimComRealH; param = 13 },
			{ com = constants.AnimComSetMaxVelX; param = 5000 },
			{ com = constants.AnimComSetMaxVelY; param = 10000 },
			{ dur = 1; num = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -8 },
			{ com = constants.AnimComCreateEffect; txt ="flash-straight"; param = 13 },
			{ com = constants.AnimComPlaySound; txt = "grenade-launch.ogg" },
			{ com = constants.AnimComSetAnim; txt = "fly" }
		}
	},
	{
		-- Пуля, летящая по диагонали вниз
		name = "diagdown";
		frames = 
		{
			{ com = constants.AnimComSetVelY; param = 4242 },
			{ com = constants.AnimComPlaySound; txt = sound_shoot; param = 1 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 600 },
			{ com = constants.AnimComSetGravity }, 
			{ com = constants.AnimComRealX; param = 10 },
			{ com = constants.AnimComRealY; param = 10 },
			{ com = constants.AnimComRealW; param = 11 },
			{ com = constants.AnimComRealH; param = 11 },
			{ com = constants.AnimComSetMaxVelX; param = 5000 },
			{ com = constants.AnimComSetMaxVelY; param = 10000 },
			{ dur = 1; num = 0 },
			{ com = constants.AnimComPushInt; param = -3 },
			{ com = constants.AnimComPushInt; param = -34 },
			{ com = constants.AnimComCreateEffect; txt ="flash-angle-down"; param = 13 },
			{ com = constants.AnimComPlaySound; txt = "grenade-launch.ogg" },
			{ com = constants.AnimComSetAnim; txt = "fly" }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "diagup";
		frames = 
		{
			{ com = constants.AnimComSetVelY; param = -4242 },
			{ com = constants.AnimComPlaySound; txt = sound_shoot; param = 1 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 600 },
			{ com = constants.AnimComSetGravity }, 
			{ com = constants.AnimComRealX; param = 10 },
			{ com = constants.AnimComRealY; param = 10 },
			{ com = constants.AnimComRealW; param = 11 },
			{ com = constants.AnimComRealH; param = 11 },
			{ com = constants.AnimComSetMaxVelX; param = 5000 },
			{ com = constants.AnimComSetMaxVelY; param = 10000 },
			{ dur = 1; num = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -10 },
			{ com = constants.AnimComCreateEffect; txt ="flash-angle-up"; param = 13 },
			{ com = constants.AnimComPlaySound; txt = "grenade-launch.ogg" },
			{ com = constants.AnimComSetAnim; txt = "fly" }
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
		--Уничтожение
		name = "die";
		frames =
		{
			{ com = constants.AnimComStop },
			{ com = constants.AnimComCreateEnemyBullet; txt = "explosion-wave" },
			{ com = constants.AnimComDestroyObject }
		}
	}
}