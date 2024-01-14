parent = "enemies/btard"

texture = "btard-ny";

animations = 
{
	{
		name = "think";
		frames = 
		{
			{ dur = 0 },
			{ com = constants.AnimComEnemyClean; param = 20 },
			{ dur = 200; num = 0; com = constants.AnimComWaitForTarget; param = 100; txt = "move" },
			{ dur = 200; num = 1; com = constants.AnimComWaitForTarget; param = 100; txt = "move" },
			{ dur = 200; num = 2; com = constants.AnimComWaitForTarget; param = 100; txt = "move" },
			{ dur = 200; num = 3; com = constants.AnimComWaitForTarget; param = 100; txt = "move" },
			{ dur = 200; num = 4; com = constants.AnimComWaitForTarget; param = 100; txt = "move" },
			--Выходим после каждого цикла с вероятностью 0.5
			{ com = constants.AnimComPushInt; param = 128 },
			{ com = constants.AnimComJumpRandom; param = 0 },
			{ com = constants.AnimComJump; param = 13 },
			{ com = constants.AnimComSetAnim; txt = "move" },
			{ com = constants.AnimComLoop },
			{ dur = 0 },
			{ com = constants.AnimComFaceTarget },
			{ dur = 100; num = 11 },
			{ dur = 100; num = 12 },
			{ dur = 100; num = 13 },
			{ com = constants.AnimComPushInt; param = 50 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComAdjustAim },
			{ dur = 100; num = 14; com = constants.AnimComAimedShot; txt = "slowpoke-snowball" },
			{ dur = 100; num = 15 },
			{ dur = 400; num = 16 }, --Долго отходим
			{ com = constants.AnimComSetAnim; txt = "move" }
		}
	}	
}



