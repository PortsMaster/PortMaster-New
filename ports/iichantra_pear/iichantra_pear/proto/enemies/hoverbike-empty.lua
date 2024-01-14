--forbidden

FunctionName = "CreateEnemy";

trajectory_type = constants.pttGlobalSine;
trajectory_param1 = 0.125;
trajectory_param2 = 0.05;

-- Описание спрайта

texture = "hoverbike";

z = -0.5;

animations = 
{
	{ 
		-- Создание
		name = "init";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 128 },
			{ com = constants.AnimComRealH; param = 128 },
			{ com = constants.AnimComSetHealth; param = 100 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 65 },
			{ com = constants.AnimComMPSet; param = 0; },
			{ com = constants.AnimComMirror; param = 1; },
			{ com = constants.AnimComSetAnim; txt = "move" }	
		}
	},
	{ 
		-- Создание
		name = "move";
		frames = 
		{
			{ dur = 100; num = 3},
		}
	}
}



