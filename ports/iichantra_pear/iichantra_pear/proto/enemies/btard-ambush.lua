parent = "enemies/btard"
--В отличие от простого битарда не останавливается подумать, отчего может легко атаковать сзади, догоняя игрока

animations =
{
	{ 
		-- Совсем не создание
		name = "move";
		frames = 
		{
			--{ com = constants.AnimComEnemyClean; param = 100 },
			{ dur = 0 },
			{ com = constants.AnimComRealX; param = 11 },
			{ com = constants.AnimComRealY; param = 0 },
			{ com = constants.AnimComRealW; param = 36 },
			{ com = constants.AnimComRealH; param = 75 },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComJumpIfTargetClose; param = 36 },
			{ com = constants.AnimComEnvSound; param = 1},
			{ dur = 100; num = 5; com = constants.AnimComMoveToTargetX; param = 500 },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComJumpIfTargetClose; param = 36 },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 6; com = constants.AnimComMoveToTargetX; param = 500 },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComJumpIfTargetClose; param = 36 },
			{ com = constants.AnimComRealX; param = 6 },
			{ dur = 100; num = 7; com = constants.AnimComMoveToTargetX; param = 500 },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComJumpIfTargetClose; param = 36 },
			{ com = constants.AnimComRealX; param = 18 },
			{ com = constants.AnimComEnvSound; },
			{ dur = 100; num = 8; com = constants.AnimComMoveToTargetX; param = 500 },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComJumpIfTargetClose; param = 36 },
			{ com = constants.AnimComRealX; param = 12 },
			{ dur = 100; num = 9; com = constants.AnimComMoveToTargetX; param = 500 },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComJumpIfTargetClose; param = 36 },
			{ com = constants.AnimComRealX; param = 4 },
			{ dur = 100; num = 10; com = constants.AnimComMoveToTargetX; param = 500 },
			{ com = constants.AnimComPushInt; param = 100 },
			{ com = constants.AnimComJumpIfTargetClose; param = 36 },
			--С некоторой вероятностью битард "задумывается"
			{ },
			{ },
			{ },
			{ com = constants.AnimComLoop },
			{ dur = 0 },
			{ com = constants.AnimComSetAnim; txt = "attack" }	
		}
	},

}