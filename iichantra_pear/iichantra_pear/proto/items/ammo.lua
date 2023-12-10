name = "ammo";

physic = 1;
phys_solid = 0;
phys_bullet_collidable = 0;
phys_max_x_vel = 0;
phys_max_y_vel = 4;

FunctionName = "CreateItem";

-- Описание спрайта

--LoadTexture("vegetable1.png");
texture = "ammo";
z = -0.001;

image_width = 256;
image_height = 32;
frame_width = 32;
frame_height = 32;
frames_count = 6;

animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealX; param = 10 },
			{ com = constants.AnimComRealY; param = 9 },
			{ com = constants.AnimComRealW; param = 14 },
			{ com = constants.AnimComRealH; param = 20 },
			--{ dur = 100; num = 20; com = constants.AnimComCreateParticles; txt = "pteleport" },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 800 },
			{ com = constants.AnimComSetGravity },
			{ com = constants.AnimComSetTouchable; param = 1 },
			{ dur = 1; num = 0 },
			{ com = constants.AnimComSetAnim; txt = "idle" }	
		}
	},
	{ 
		-- Вращение
		name = "idle";
		frames = 
		{
	
			{ dur = 100; num = 0 },
			{ dur = 100; num = 1 },
			{ dur = 100; num = 2 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 4 },
			{ dur = 100; num = 5 },
			{ dur = 100; num = 4 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 2 },
			{ dur = 100; num = 1 },
			{ com = constants.AnimComLoop }	
		}
	},
	{ 
		-- Бонус
		name = "touch";
		frames = 
		{
			{ com = constants.AnimComGiveAmmo; param = 100 },
			{ com = constants.AnimComJumpIfPlayerId; param = 3 },
			{ com = constants.AnimComDestroyObject },
			{ dur = 100 },
			{ com = constants.AnimComPlaySound; txt = "ammo-pickup.ogg" },
			{ com = constants.AnimComCallFunction; txt = "StabilizeSync"; param = 1 },
			{ com = constants.AnimComDestroyObject }
		}
	}
	
}



