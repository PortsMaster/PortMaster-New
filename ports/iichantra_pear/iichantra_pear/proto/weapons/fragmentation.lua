--forbidden

reload_time = 250;
bullets_per_shot = 20;
clip_reload_time = 150;
damage_type = 2;

push_force = 3.0;

-- Описание пули
bullet_damage = 40;
bullet_vel = 5;

-- Описание спрайта пули
texture = "fragmentation";

z = -0.002;

animations = 
{
	{
		-- Пуля, летящая прямо
		name = "straight";
		frames = 
		{
			{ com = constants.AnimComPlaySound; txt = "weapons/fragmentator.ogg"; param = 1 },
			{ com = constants.AnimComRealW; param = 13 },
			{ dur = 1; num = 0; com = constants.AnimComRealH; param = 13 },
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
			{ com = constants.AnimComPlaySound; txt = "weapons/fragmentator.ogg"; param = 1 },
			{ com = constants.AnimComRealW; param = 13 },
			{ dur = 1; num = 1; com = constants.AnimComRealH; param = 13 },
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
			{ com = constants.AnimComPlaySound; txt = "weapons/fragmentator.ogg"; param = 1 },
			{ com = constants.AnimComRealW; param = 13 },
			{ dur = 1; num = 2; com = constants.AnimComRealH; param = 13 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -10 },
			{ com = constants.AnimComCreateEffect; txt ="flash-angle-up"; param = 13 },
			{ com = constants.AnimComSetAnim; txt = "fly" }
		}
	},
	{
		name = "fly";
		frames =
		{
			{ num = 1; dur = 100 },
			{ num = 2; dur = 100 },
			{ num = 3; dur = 100 },
			{ num = 4; dur = 100 },
			{ num = 5; dur = 100 },
			{ num = 0; dur = 100 },
			{ com = constants.AnimComLoop }
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
			{ dur = 100; num = 6 },
			{ com = constants.AnimComRealX; param = 2 },
			{ com = constants.AnimComRealY; param = 2 },
			{ dur = 100; num = 7 },
			{ com = constants.AnimComRealX; param = 4 },
			{ com = constants.AnimComRealY; param = 4 },
			{ dur = 100; num = 8 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 7 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAngledShot; txt = "fragmentation-fragment1" },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 3 },
			{ com = constants.AnimComPushInt; param = 3 },
			{ com = constants.AnimComPushInt; param = 45 },
			{ com = constants.AnimComPushInt; param = -2 },
			{ com = constants.AnimComAngledShot; txt = "fragmentation-fragment1" },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 3 },
			{ com = constants.AnimComPushInt; param = -3 },
			{ com = constants.AnimComPushInt; param = -45 },
			{ com = constants.AnimComPushInt; param = 2 },
			{ com = constants.AnimComAngledShot; txt = "fragmentation-fragment1" },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 7 },
			{ com = constants.AnimComPushInt; param = 90 },
			{ com = constants.AnimComPushInt; param = -4 },
			{ com = constants.AnimComAngledShot; txt = "fragmentation-fragment1" },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -7 },
			{ com = constants.AnimComPushInt; param = -90 },
			{ com = constants.AnimComPushInt; param = 4 },
			{ com = constants.AnimComAngledShot; txt = "fragmentation-fragment1" },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -7 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 180 },
			{ com = constants.AnimComPushInt; param = -9 },
			{ com = constants.AnimComAngledShot; txt = "fragmentation-fragment1" },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -3 },
			{ com = constants.AnimComPushInt; param = 3 },
			{ com = constants.AnimComPushInt; param = 135 },
			{ com = constants.AnimComPushInt; param = -7 },
			{ com = constants.AnimComAngledShot; txt = "fragmentation-fragment1" },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = -3 },
			{ com = constants.AnimComPushInt; param = -3 },
			{ com = constants.AnimComPushInt; param = -135 },
			{ com = constants.AnimComPushInt; param = 7 },
			{ com = constants.AnimComAngledShot; txt = "fragmentation-fragment1" },
			{ com = constants.AnimComDestroyObject },
		}
	}
}