--forbidden
name = "spread-bullet";

push_force = 1.0;

-- Описание пули
bullet_damage = 10;
bullet_vel = 5;

-- Описание спрайта пули
texture = "bullets";
overlay = {0};

z = -0.002;

image_width = 256;
image_height = 64;
frame_width = 64;
frame_height = 32;
frames_count = 7;

-- просто переменая, такое тоже можно
local sound_shoot = "blaster_shot"
local delay = 20

animations = 
{
	{
		-- Пуля, летящая прямо
		name = "straight";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComControlledOverlayColor },
			{ com = constants.AnimComRealX; param = 38 },
			{ com = constants.AnimComRealY; param = 12 },
			{ com = constants.AnimComRealW; param = 11 },
			{ com = constants.AnimComRealH; param = 7 },
			{ dur = delay; num = 14 },
			{ dur = 100; num = 0; com = constants.AnimComRealH; param = 5 }
		}
	},
	{
		-- Пуля, летящая по диагонали вниз
		name = "diagdown";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComControlledOverlayColor },
			{ com = constants.AnimComRealX; param = 37 },
			{ com = constants.AnimComRealY; param = 21 },
			{ com = constants.AnimComRealW; param = 9 },
			{ com = constants.AnimComRealH; param = 7 },
			{ dur = delay; num = 14 },			
			{ dur = 100; num = 1; com = constants.AnimComRealH; param = 9 }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "diagup";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComControlledOverlayColor },
			{ com = constants.AnimComRealX; param = 37 },
			{ com = constants.AnimComRealY; param = 2 },
			{ com = constants.AnimComRealW; param = 9 },
			{ com = constants.AnimComRealH; param = 7 },
			{ dur = delay; num = 14 },
			{ dur = 100; num = 2; com = constants.AnimComRealH; param = 9 }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "slightlyup";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComControlledOverlayColor },
			{ com = constants.AnimComRealX; param = 31 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 9 },
			{ com = constants.AnimComRealH; param = 7 },
			{ dur = delay; num = 14 },
			{ dur = 100; num = 9; com = constants.AnimComRealH; param = 9 }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "slightlydown";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComControlledOverlayColor },
			{ com = constants.AnimComRealX; param = 31 },
			{ com = constants.AnimComRealY; param = 11 },
			{ com = constants.AnimComRealW; param = 9 },
			{ com = constants.AnimComRealH; param = 7 },
			{ dur = delay; num = 14 },
			{ dur = 100; num = 8; com = constants.AnimComRealH; param = 9 }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "highup";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComControlledOverlayColor },
			{ com = constants.AnimComRealX; param = 11 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 9 },
			{ com = constants.AnimComRealH; param = 7 },
			{ dur = delay; num = 14 },
			{ dur = 100; num = 11; com = constants.AnimComRealH; param = 9 }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "highdown";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComControlledOverlayColor },
			{ com = constants.AnimComRealX; param = 11 },
			{ com = constants.AnimComRealY; param = 27 },
			{ com = constants.AnimComRealW; param = 9 },
			{ com = constants.AnimComRealH; param = 7 },
			{ dur = delay; num = 14 },
			{ dur = 100; num = 10; com = constants.AnimComRealH; param = 9 }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "straightup";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComControlledOverlayColor },
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 32 },
			{ com = constants.AnimComRealW; param = 9 },
			{ com = constants.AnimComRealH; param = 7 },
			{ dur = delay; num = 14 },
			{ dur = 100; num = 13; com = constants.AnimComRealH; param = 9 }
		}
	},
	{
		-- Пуля, летящая по диагонали вверх
		name = "straightdown";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComPushInt; param = 255 },
			{ com = constants.AnimComControlledOverlayColor },
			{ com = constants.AnimComRealX; param = 0 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 9 },
			{ com = constants.AnimComRealH; param = 7 },
			{ dur = delay; num = 14 },
			{ dur = 100; num = 12; com = constants.AnimComRealH; param = 9 }
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
			{ com = constants.AnimComRealX; param = 38 },
			{ com = constants.AnimComRealY; param = 12 },
			{ com = constants.AnimComRealW; param = 11 },
			{ com = constants.AnimComRealH; param = 7 },
			{ dur = 100; num = 4 },
			{ dur = 100; num = 5 },
			{ dur = 100; num = 6 },
			{ dur = 100; num = 7 },
			{ com = constants.AnimComDestroyObject }
		}
	}
}