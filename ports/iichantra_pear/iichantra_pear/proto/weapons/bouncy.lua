--forbidden
name = "bouncy";

physic = 1;

reload_time = 500;
bullets_per_shot = 10;

-- Описание пули
bullet_damage = 20;
bullet_vel = 1;

push_force = 1.0;

-- Описание спрайта пули
texture = "bouncy";

image_width = 256;
image_height = 64;
frame_width = 32;
frame_height = 32;
frames_count = 10;
z = -0.002;

bounce = 1.1;

animations = 
{
	{
		name = "fly";
		frames =
		{
			{ com = constants.AnimComSetAccY; param = 0 },
			{ dur = 50; num = 0 },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 2 },
			{ dur = 50; num = 1 },
			--{ com = constants.AnimComSetAccX; param = 2 },
			{ dur = 50; num = 0 },
			{ dur = 50; num = 1 },
			--{ com = constants.AnimComSetAccY; param = 0 },
			{ dur = 50; num = 2 },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 0 },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 2 },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 0 },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 2 },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 0 },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 2 },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 0 },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 2 },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 0 },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 2 },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 0 },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 2 },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 0 },
			{ dur = 50; num = 1 },
			{ dur = 50; num = 2 },
			{ dur = 50; num = 1 },
			{ com = constants.AnimComSetAnim; txt = "really_die" }
		}
	},
	{
		-- Пуля, летящая прямо
		name = "straight";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 600 },
			{ com = constants.AnimComSetGravity }, 
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 16 },
			{ com = constants.AnimComRealH; param = 16 },
			{ com = constants.AnimComSetMaxVelX; param = 10000 },
			{ com = constants.AnimComSetMaxVelY; param = 10000 },
			{ com = constants.AnimComSetLifetime; param = 500 },
			{ dur = 1; num = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -8 },
			{ com = constants.AnimComCreateEffect; txt ="flash-straight"; param = 13 },
			{ com = constants.AnimComPlaySound; txt = "weapons/grenade-launch.ogg"; param = 1 },
			{ com = constants.AnimComSetAnim; txt = "fly" }
		}
	},
	{
		-- Пуля, летящая по диагонали вниз
		name = "diagdown";
		frames = 
		{
			{ com = constants.AnimComAdjustY; param = -30 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 600 },
			{ com = constants.AnimComSetGravity }, 
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 30 },
			{ com = constants.AnimComRealW; param = 16 },
			{ com = constants.AnimComRealH; param = 16 },
			{ com = constants.AnimComSetMaxVelX; param = 10000 },
			{ com = constants.AnimComSetMaxVelY; param = 10000 },
			{ com = constants.AnimComSetVelY; param = 14142 },
			{ com = constants.AnimComSetLifetime; param = 500 },
			{ dur = 1; num = 0 },
			{ com = constants.AnimComPushInt; param = -3 },
			{ com = constants.AnimComPushInt; param = -34 },
			{ com = constants.AnimComCreateEffect; txt ="flash-angle-down"; param = 13 },
			{ com = constants.AnimComPlaySound; txt = "weapons/grenade-launch.ogg"; param = 1 },
			{ com = constants.AnimComSetAnim; txt = "fly" }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "diagup";
		frames = 
		{
			{ com = constants.AnimComAdjustY; param = 30 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 600 },
			{ com = constants.AnimComSetGravity }, 
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = -30 },
			{ com = constants.AnimComRealW; param = 16 },
			{ com = constants.AnimComRealH; param = 16 },
			{ com = constants.AnimComSetMaxVelX; param = 10000 },
			{ com = constants.AnimComSetMaxVelY; param = 10000 },
			{ com = constants.AnimComSetVelY; param = -14142 },
			{ com = constants.AnimComSetLifetime; param = 500 },
			{ dur = 1; num = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -10 },
			{ com = constants.AnimComCreateEffect; txt ="flash-angle-up"; param = 13 },
			{ com = constants.AnimComPlaySound; txt = "weapons/grenade-launch.ogg"; param = 1 },
			{ com = constants.AnimComSetAnim; txt = "fly" }
		}
	},
	{
		name = "miss";
		frames =
		{
			{ com = constants.AnimComPlaySound; txt = "weapons/grenade-bounce.ogg"; param = 1 },
			{ com = constants.AnimComRecover; txt = "fly" }
			--{ com = constants.AnimComSetAnim; txt = "fly" }
		}
	},
	{
		--Уничтожение
		name = "die";
		frames =
		{
			{ com = constants.AnimComStartDying },
			{ com = constants.AnimComPushInt; param = 4 },
			{ com = constants.AnimComLocalJumpIfIntEquals; param = 666},
			{ com = constants.AnimComStartDying; param = -1 },
			{ com = constants.AnimComRecover; txt = "fly" },
			{ com = constants.AnimComStop },
			{ com = constants.AnimComSetAccX; param = 0 },
			{ com = constants.AnimComSetAccY; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComSetGravity },
			{ com = constants.AnimComRealX; param = -1 },
			{ com = constants.AnimComRealY; param = -1 },
			{ num = 3; dur = 50 },
			{ com = constants.AnimComRealX; param = 1 },
			{ com = constants.AnimComRealY; param = 1 },
			{ num = 4; dur = 50 },
			{ com = constants.AnimComRealX; param = 2 },
			{ com = constants.AnimComRealY; param = 2 },
			{ num = 5; dur = 50 },
			{ com = constants.AnimComRealX; param = 1 },
			{ com = constants.AnimComRealY; param = 1 },
			{ num = 6; dur = 50 },
			{ num = 7; dur = 50 },
			{ com = constants.AnimComRealX; param = -1 },
			{ com = constants.AnimComRealY; param = -1 },
			{ num = 8; dur = 50 },
			{ num = 9; dur = 50 },
			{ com = constants.AnimComDestroyObject }
		}
	},
	{
		name = "really_die";
		frames =
		{ 
			{ com = constants.AnimComPushInt; param = 666 },
			{ com = constants.AnimComStartDying },
			{ com = constants.AnimComSetAnim; txt = "die" }
		}
	}
}